Include "AppVeyor.Functions.ps1"

function Get-BuildVersion {
    $BuildVersion = Get-AppVeyorBuildVersion

    if (-not $BuildVersion) {
        $BuildVersion = "0.0.0.0"
    }

    Write-Output $BuildVersion
}

function Update-AssemblyInfoVersion {
    Param(
        $Path,
        $Version
    )

    Write-Host "Updating $Path with $Version..." -NoNewline

    $AssemblyInfoContent = Get-Content $Path -Encoding UTF8

    $AssemblyInfoContent = $AssemblyInfoContent -replace 'AssemblyVersion\(".*"\)', "AssemblyVersion(""$Version"")"

    Set-Content $Path $AssemblyInfoContent -Encoding UTF8

    Write-Host "done!"
}
# Executes tests found in the specified DLLs.
function Run-Tests {
    Param(
        $PackagesPath,
        $ArtifactsPath,
        $TestDlls,
        $CodeCoveragePercentageRequired
    )

    $xUnitPath           = Join-Path $Env:ChocolateyInstall 'bin\xunit.console.exe'
    $openCoverPath       = Join-Path $PackagesPath 'OpenCover.4.6.519\tools\OpenCover.Console.exe'
    $openCoverOutputPath = Join-Path $ArtifactsPath "coverage.xml"

    $currentDir = Get-Location
    Set-Location $ArtifactsPath
    exec { . $openCoverPath -target:$xUnitPath -targetargs:$TestDlls -returntargetcode -register:user -output:$openCoverOutputPath -filter:'+[Hero.Toolbox.Common.Pcl]*' }
    Set-Location $currentDir

    if ($CodeCoveragePercentageRequired) {
        $reportGeneratorPath       = Join-Path $PackagesPath 'ReportGenerator.2.4.4.0\tools\ReportGenerator.exe'
        $reportGeneratorOutputPath = Join-Path $ArtifactsPath 'CoverageReport'

        exec { . $reportGeneratorPath $openCoverOutputPath $reportGeneratorOutputPath }

        $coverallsPath = Join-Path $PackagesPath 'coveralls.io.1.3.4\tools\coveralls.net.exe'

        exec { . $coverallsPath --opencover $openCoverOutputPath }

        # Check the percentage:
        $totalSequencePoints = (Select-Xml `
            -Path  $openCoverOutputPath `
            -XPath '//SequencePoint').Count

        $visitedSequencePoints = (Select-Xml `
            -Path  $openCoverOutputPath `
            -XPath "//SequencePoint[@vc!='0']").Count

        $coveragePercentage = ($visitedSequencePoints / $totalSequencePoints) * 100

        Write-Host "$visitedSequencePoints out of $totalSequencePoints sequence points covered: $coveragePercentage %"

        if ($coveragePercentage -lt $CodeCoveragePercentageRequired) {
            throw "$coveragePercentage% is not sufficient, $CodeCoveragePercentageRequired% must be covered."
        }
    }
}