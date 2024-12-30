#Requires -Version 3.0
<#
.SYNOPSIS
Requires PS 5.1 and Administrator rights.

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
Website: https://lj-sec.github.io/
#>

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "`nYou must run this script as an administrator."
    Exit 1
}

# Creating a log file to note changes made to the system
$scyllaDir = "$env:HOMEDRIVE\Scylla"
$scyllaLogsDir = "$scyllaDir\Logs"

mkdir -ErrorAction SilentlyContinue $scyllaDir | Out-Null
mkdir -ErrorAction SilentlyContinue $scyllaLogsDir | Out-Null
$curTime = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "$scyllaLogsDir\log_$curTime.txt"
Out-File $logFile

# Write-Log Function to write logs to $logFile
function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        [switch]$NoDate,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$Echo = $null
    )

    if($Echo)
    {
        Write-Host -ForegroundColor $Echo "`n$Message`n"
    }

    if($NoDate.IsPresent)
    {
        Write-Output "// $Message" | Out-File $logFile -Append
    }
    else
    {
        $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss K"
        Write-Output "$currentTime - $Message" | Out-File $logFile -Append   
    }
}

function Write-Menu
{
    param (
        [Parameter(Mandatory)]
        [string]$Header,
        [Parameter(Mandatory)]
        [string]$Directory,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$Color=$null
    )
    while ($true)
    {
        if($Color)
        {
            Write-Host -ForegroundColor $Color "`n--- $Header ---`n"
        }
        else
        {
            Write-Host "`n- - - $Header - - -`n"
        }
        $index = 1
        $directories = Get-ChildItem -Path $Directory | Where-Object {$_.PSIsContainer}
        $scripts = Get-ChildItem -Path $Directory | Where-Object {($_.Extension -ieq ".ps1") -and ($_.Name -ne "scylla_core.ps1")}
        $directories | ForEach-Object -Process {
            Write-Host -ForegroundColor Blue "$($index): $($_.Name)"
            $index++
        }
        $scripts | ForEach-Object -Process {
            Write-Host -ForegroundColor Cyan "$($index): $($_.Name)"
            $index++
        }

        if($Directory -ne $PSScriptRoot)
        {
            Write-Host -ForegroundColor DarkYellow "$($index): Parent Directory"
            $index++
            if((Get-Location | Split-Path -Parent) -ne $PSScriptRoot)
            {
                Write-Host -ForegroundColor DarkYellow "$($index): Scylla Root"
                $index++
            }
        }
        Write-Host -ForegroundColor Red "$($index): Exit"

        $selection = Read-Host "`nYour selection"
        if(($selection -as [int]) -and ($selection -gt 0))
        {
            if($selection -le $directories.Count)
            {
                return $directories[$selection - 1].FullName
            }
            elseif (($selection -gt $directories.Count) -and ($selection -le ($directories.Count + $scripts.Count)))
            {
                return $scripts[$selection - $directories.Count - 1].FullName
            }
            elseif ($selection -eq ($index - 2))
            {
                return Get-Location | Split-Path -Parent
            }
            elseif ($selection -eq ($index - 1))
            {
                return $PSScriptRoot
            }
            Write-Log -Echo Red "User terminating Scylla!"
            Exit 0
        }

        Write-Host -ForegroundColor Red "`nInvalid selection!"
    }
}

function Get-RelativeToRoot
{
    param (
        [Parameter(Mandatory)]
        [string]$FilePath
    )
    $fullPath = Resolve-Path -Path $FilePath
    return ($fullPath -replace [regex]::Escape("$($PSScriptRoot)"), "$($PSScriptRoot | Split-Path -Leaf)")
}

Write-Log "Core script begins!"

Clear-Host

Write-Host -ForegroundColor Red @"
`n`n
      ████████████ ███████╗ ██████╗██╗   ██╗██╗     ██╗      █████╗ 
     █  █████████  ██╔════╝██╔════╝╚██╗ ██╔╝██║     ██║     ██╔══██╗
    ███  ███████   ███████╗██║      ╚████╔╝ ██║     ██║     ███████║
   █████  █████     ════██║██║       ╚██╔╝  ██║     ██║     ██╔══██║
 ████   ███  █     ███████║╚██████╗   ██║   ███████╗███████╗██║  ██║
█████████████      ╚══════╝ ╚═════╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
`n`n
"@

Write-Host -ForegroundColor DarkYellow "Established a log file at $logFile"

try
{
    $ErrorActionPreference = "Stop"
    $initDir = Get-Location
    $curDir = $PSScriptRoot
    while($true)
    {
        do
        {
            Set-Location $curDir
            $curDir = Write-Menu -Header "$(Get-Location | Split-Path -Leaf)" -Directory $curDir -Color Magenta
        } until (Test-Path -Path $curDir -PathType Leaf)
        $relToRoot = Get-RelativeToRoot $curDir
        Write-Log -Echo Green "Executing the following script: $($relToRoot)"
        . $curDir
        Write-Log -Echo Green "$($relToRoot) has successfully executed!"
        $curDir = Get-Location
        Write-Host -ForegroundColor Red "Returning to menu..."
    }
}
catch
{
    Write-Log -Echo Red "Terminating error: $_"
}
finally
{
    Set-Location $initDir
    Write-Log "Script ends!"
}