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

Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Yellow

# XrmToolBox shortcut creation
Write-Host "Adding XrmToolBox shortcut to Start Menu" -ForegroundColor Yellow
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
Write-Host "Modifying Visual Studio 2022 Professional using .vsconfig. Please wait for the installer to finish before the next step." -ForegroundColor Yellow
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" `
    modify `
    --installPath "C:\Program Files\Microsoft Visual Studio\2022\Professional" `
    --config ".config\.vsconfig" `
    --passive `
    --allowUnsignedExtensions `
    2>&1 | Where-Object { $_ -match "error" -or $_ -match "failed" }
Write-Host "Completed adding workloads and packages to Visual Studio 2022 Professional." -ForegroundColor Green

# Install PowerApps modules
Write-Host "Installing PowerApps modules..." -ForegroundColor Yellow
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber -ErrorAction Stop -Scope CurrentUser
    Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber -ErrorAction Stop -Scope CurrentUser
    Write-Host "PowerApps modules installed successfully." -ForegroundColor Green
} catch {
    Write-Warning "Failed to install PowerApps modules: $($_.Exception.Message)"
}
   
# Install Visual Studio Code extensions from extensions.json
Write-Host "Installing VS Code extensions..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$extensions = (Get-Content ".\.config\extensions.json" | ConvertFrom-Json).recommendations
foreach ($ext in $extensions) {
    code --install-extension $ext --force
}

# Install Dataverse Core Tools, update Path Environment Variable permanently
Write-Host "Installing Dataverse Core Tools..." -ForegroundColor Yellow
$powerAppsCliPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\PowerAppsCLI"
if (Test-Path $powerAppsCliPath) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$powerAppsCliPath*") {
        # Add PowerAppsCLI to user PATH
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$powerAppsCliPath", "User")
    }
    # Also update current session PATH
    $env:PATH += ";$powerAppsCliPath"
    Write-Host "Please close the PRT window after launch to continue with the installation" -ForegroundColor Yellow
    pac tool prt
    Write-Host "Please close the CMT window after launch to continue with the installation" -ForegroundColor Yellow
    pac tool cmt
    Write-Host "Please close the PD window after launch to continue with the installation" -ForegroundColor Yellow
    pac tool pd
    pac tool list
    Write-Host "Dataverse Core Tool installation completed successfully." -ForegroundColor Green
}

Write-Host "`nSetup complete! Please restart your machine for all changes to take full effect." -ForegroundColor Green
