#requires -RunAsAdministrator

# Taken from psake https://github.com/psake/psake
<#
.SYNOPSIS
  This is a helper function that runs a scriptblock and checks the PS variable $lastexitcode
  to see if an error occcured. If an error is detected then an exception is thrown.
  This function allows you to run command-line programs without having to
  explicitly check the $lastexitcode variable.
.EXAMPLE
  exec { svn info $repository_trunk } "Error executing SVN. Please verify SVN command-line client is installed"
#>
function Exec
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][scriptblock]$cmd,
        [Parameter(Position=1,Mandatory=0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}

# Make sure all the system level prerequisites that require Admin rights are installed.

# Chocolatey: Used to install subsequent dependencies.
if (-not ($env:Path -ilike "*chocolatey*")) {
    Write-Host "Chocolatey not found in PATH environment variable, installing..."
    iex ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# .NET 4.6 is the Framework that compiles and runs compiled code.
exec { cinst dotnet4.6         --version 4.6.00081.20150925 --confirm }

# Used to install .net packages.
exec { cinst nuget.commandline --version 2.8.6              --confirm }

# PSake is a tool that coordinates CI tasks.
exec { nuget install psake -version 4.4.2 }

# Install Azure PowerShell Cmdlets
exec { webpicmd /Install /Products:WindowsAzurePowerShell /AcceptEula }
