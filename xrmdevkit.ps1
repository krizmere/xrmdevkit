# A PowerShell script to install all necessary tools for a D365 CE Developer
# Check PowerShell version (requires 5.0 or later)
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "This script requires PowerShell 5.0 or later. Please upgrade your PowerShell version."
    exit 1
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "This script requires administrator privileges. Please run PowerShell as Administrator."
    exit 1
}

Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Green

# XrmToolBox shortcut creation
Write-Host "Adding XrmToolBox shortcut to Start Menu" -ForegroundColor Green
$possiblePaths = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages",
    "${env:ProgramFiles(x86)}\MscrmTools",
    "${env:ProgramFiles}\MscrmTools"
)

$exe = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $foundExe = Get-ChildItem $path -Recurse -Include "XrmToolBox.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($foundExe) {
            $exe = $foundExe
            break
        }
    }
}

# Create shortcut
if ($exe) {
    $startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $shortcutPath = Join-Path $startMenu "XrmToolBox.lnk"
    $w = New-Object -ComObject WScript.Shell
    $sc = $w.CreateShortcut($shortcutPath)
    $sc.TargetPath = $exe.FullName
    $sc.WorkingDirectory = $exe.DirectoryName
    $sc.IconLocation = $exe.FullName
    $sc.Save()
    Write-Host "Shortcut created: $shortcutPath" -ForegroundColor Green
} else {
    Write-Warning "XrmToolBox.exe not found. Please install it manually if needed."
}

# Install Visual Studio Workloads and Packs
Write-Host "Modifying Visual Studio 2022 Professional. Adding Workloads and Packs from .config/.vsconfig" -ForegroundColor Green
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" --config ".config/.vsconfig" --passive --allowUnsignedExtensions
# winget install --id Microsoft.DotNet.Framework.DeveloperPack_4.6.2 --exact --accept-package-agreements --accept-source-agreements
# winget install --id Microsoft.DotNet.Framework.DeveloperPack_4.7.2 --exact --accept-package-agreements --accept-source-agreements

# Install Visual Studio Code extensions from extensions.json
Write-Host "Installing VS Code extensions..."
$extensions = (Get-Content ".\.config\extensions.json" | ConvertFrom-Json).recommendations
foreach ($ext in $extensions) {
    code --install-extension $ext --force
}

# Install Dataverse Core Tools, update Path Environment Variable permanently
Write-Host "Installing Dataverse Core Tools. Updating PATH environment variable." -ForegroundColor Green
$powerAppsCliPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\PowerAppsCLI"
if (Test-Path $powerAppsCliPath) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$powerAppsCliPath*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$powerAppsCliPath", "User")
        Write-Host "Added PowerAppsCLI to user PATH" -ForegroundColor Green
    }
    # Also update current session PATH
    $env:PATH += ";$powerAppsCliPath"
    pac tool prt
    pac tool cmt
    pac tool pd
    pac tool list
}

# Install PowerApps modules
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber -ErrorAction Stop -Scope CurrentUser
    Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber -ErrorAction Stop -Scope CurrentUser
    Write-Host "PowerApps modules installed successfully" -ForegroundColor Green
} catch {
    Write-Warning "Failed to install PowerApps modules: $($_.Exception.Message)"
}

Write-Host "`nSetup Complete! Please restart your Windows machine for all changes to take full effect." -ForegroundColor Green
