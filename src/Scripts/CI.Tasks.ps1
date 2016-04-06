# Include additional scripts
Include "CI.Functions.ps1"

# Define path parameters
$BasePath = "Uninitialized" # Caller must specify.

# Define the input properties and their default values.
properties {
    $ProductName           = "Hero.Toolbox"
    $SourcePath            = Join-Path $BasePath "src"
    $ArtifactsPath         = Join-Path $BasePath "Artifacts"
    $LogsPath              = Join-Path $ArtifactsPath "Logs"
    $ScriptsPath           = Join-Path $ArtifactsPath "Scripts"
    $SolutionFileName      = "$ProductName.sln"
    $SolutionPath          = Join-Path $SourcePath $SolutionFileName
    $PackagesPath          = Join-Path $SourcePath "packages"
}

# Define the Task to call when none was specified by the caller.
Task Default -depends Build

Task InstallDependencies -description "Installs all dependencies required to execute the tasks in this script." {
    exec { 
        cinst xunit         --version 2.0.0  --confirm
    }
}

Task Clean -depends InstallDependencies -description "Removes any artifacts that may be present from prior runs of the CI script." {
    if (Test-Path $ArtifactsPath) {
        Write-Host "Deleting $ArtifactsPath..." -NoNewline
        Remove-Item $ArtifactsPath -Recurse -Force
        Write-Host "done!"
    }

    Write-Host "Cleaning solution $SolutionPath..." -NoNewline

    exec { msbuild $SolutionPath /t:Clean /verbosity:minimal /m /nologo }
    
    Write-Host "done!"
}

Task Build -depends Clean -description "Compiles all source code." {
    $BuildVersion = Get-BuildVersion

    exec { nuget restore $SolutionPath }

    Write-Host "Building $ProductName $BuildVersion from $SolutionPath"
    
    # Make sure the path exists, or the logs won't be written.
    New-Item `
        -ItemType Directory `
        -Path $LogsPath |
            Out-Null

    # Update the AssemblyInfo file with the version #.
    $AssemblyInfoFilePath = Join-Path $SourcePath 'AssemblyInfo.cs'
    Update-AssemblyInfoVersion `
        -Path    $AssemblyInfoFilePath `
        -Version $BuildVersion

    Write-Host "Compiling solution $SolutionPath..."

    # Compile the whole solution according to how the solution file is configured.
    exec { msbuild $SolutionPath /p:OutDir=$ArtifactsPath\ /verbosity:minimal /m /nologo }

    Write-Host "done!"

    # Unit test the built code
    $TestDlls = @(
        (Join-Path $ArtifactsPath "$ProductName.Tests.Unit.dll")
    )

    Write-Host
    Write-Host "Unit testing $TestDlls..."

    Run-Tests `
        -PackagesPath  $PackagesPath `
        -ArtifactsPath $ArtifactsPath `
        -TestDlls      $TestDlls `
        -CodeCoveragePercentageRequired 100

    Write-Host "done!"
    Write-Host
}

Task Pull -description "Pulls the latest source from master to the local repo." {
    exec { git pull origin master }
}

Task Push -depends Pull -description "Performs pre-push actions before actually pushing to the remote repo." {
    exec { git push }
}
