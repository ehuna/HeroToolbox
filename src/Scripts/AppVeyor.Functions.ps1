function Get-AppVeyorBuildVersion {
	Write-Output $Env:APPVEYOR_BUILD_VERSION
}