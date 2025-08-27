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

# Check if Winget is available
try {
    $wingetCheck = winget --version
    Write-Host "Winget version: $wingetCheck" -ForegroundColor Green
} catch {
    Write-Error "Winget is not installed or not in PATH. Please install Winget first: https://docs.microsoft.com/windows/package-manager/winget/"
    exit 1
}

Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Green
Write-Host "`nInstalling Applications via Winget (Parallel)..." -ForegroundColor Yellow

# List of winget packages to install
$wingetPackages = @(
    #"Microsoft.VisualStudioCode",
    #"Microsoft.VisualStudio.2022.Professional",
    # "Microsoft.DotNet.SDK.8",
    #"OpenJS.NodeJS.LTS",
    #"Google.Chrome",
    #"Mozilla.Firefox",
    #"Microsoft.PowerBI",
    #"Microsoft.Teams",
    #"Microsoft.AzureCLI",
    #"Microsoft.AzureDataStudio",
    "Notepad++.Notepad++",
    "Telerik.Fiddler.Classic",
    "Postman.Postman",
    "7zip.7zip",
    "MscrmTools.XrmToolBox",
    "Microsoft.PowerAppsCLI"
)

# Function to install a single package
function Install-WingetPackage {
    param($packageId)
    try {
        Write-Host "Installing $packageId..." -ForegroundColor Cyan
        winget install --id=$packageId --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to install $packageId (Exit code: $LASTEXITCODE)"
            return $false
        }
        Write-Host "✓ $packageId installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Warning "Failed to install $packageId : $($_.Exception.Message)"
        return $false
    }
}

# Install packages in parallel with limited concurrency
$maxConcurrent = 4 # Adjust based on your system capabilities
$jobs = @()
$completed = 0
$total = $wingetPackages.Count

foreach ($package in $wingetPackages) {
    # Wait if we have too many concurrent jobs
    while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -ge $maxConcurrent) {
        Start-Sleep -Seconds 2
        # Check for completed jobs and output their results
        $completedJobs = $jobs | Where-Object { $_.State -eq 'Completed' }
        foreach ($job in $completedJobs) {
            $result = Receive-Job $job
            if ($result) { $completed++ }
            Remove-Job $job
            $jobs = $jobs | Where-Object { $_.Id -ne $job.Id }
        }
    }
    
    $job = Start-Job -ScriptBlock ${function:Install-WingetPackage} -ArgumentList $package -Name "Install-$package"
    $jobs += $job
    Write-Progress -Activity "Installing Packages" -Status "Queued: $package" -PercentComplete (($jobs.Count / $total) * 100)
}

# Wait for all jobs to complete and collect results
Write-Host "`nWaiting for installations to complete..." -ForegroundColor Yellow
while (($jobs | Where-Object { $_.State -eq 'Running' }).Count -gt 0) {
    $running = ($jobs | Where-Object { $_.State -eq 'Running' }).Count
    $done = $total - $running
    Write-Progress -Activity "Installing Packages" -Status "$done of $total completed ($running running)" -PercentComplete (($done / $total) * 100)
    Start-Sleep -Seconds 5
}

# Process results
$successCount = 0
foreach ($job in $jobs) {
    $result = Receive-Job $job
    if ($result) { $successCount++ }
    Remove-Job $job
}

Write-Host "`nInstallation completed: $successCount of $total packages installed successfully" -ForegroundColor Green

# XrmToolBox shortcut creation (must run sequentially)
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

if ($exe) {
    $startMenu = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $shortcutPath = Join-Path $startMenu "XrmToolBox.lnk"
    
    # Create shortcut
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

# Update Path Environment Variable permanently
$powerAppsCliPath = "$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\PowerAppsCLI"
if (Test-Path $powerAppsCliPath) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$powerAppsCliPath*") {
        [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$powerAppsCliPath", "User")
        Write-Host "Added PowerAppsCLI to user PATH" -ForegroundColor Green
    }
    
    # Also update current session PATH
    $env:PATH += ";$powerAppsCliPath"
}

Set-Location $env:USERPROFILE

# Check execution policy for module installation
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "Execution policy set to RemoteSigned" -ForegroundColor Yellow
}

# Initialize Power Apps CLI 
Write-Host "`nSetting up Power Apps CLI..." -ForegroundColor Yellow
try {
    pac install latest
} catch {
    Write-Warning "Failed to install latest Power Apps CLI: $($_.Exception.Message)"
}

# Helper function to pre-download Dataverse tools via pac
function Ensure-PacTool {
    param([ValidateSet('prt','cmt','pd')]$Name)
    Write-Host "Ensuring pac tool '$Name' is downloaded/updated..." -ForegroundColor Cyan
    try {
        $process = Start-Process -FilePath "pac.exe" -ArgumentList "tool $Name --update" -WindowStyle Hidden -PassThru -Wait
        if ($process.ExitCode -ne 0) {
            Write-Warning "pac tool $Name update failed with exit code $($process.ExitCode)"
        }
    } catch {
        Write-Warning "Failed to update pac tool $Name : $($_.Exception.Message)"
    }
    
    $uiMap = @{ prt='PluginRegistration'; cmt='Microsoft.Xrm.Tooling.ConfigurationMigration.WpfApp'; pd='PackageDeployer' }
    $ui = $uiMap[$Name]
    if ($ui) { 
        Get-Process -Name $ui -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue 
    }
}

# Pre-download Dataverse tools
Ensure-PacTool prt
Ensure-PacTool cmt
Ensure-PacTool pd

try {
    pac tool list
} catch {
    Write-Warning "Failed to list pac tools: $($_.Exception.Message)"
}

# Install PowerApps modules
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber -ErrorAction Stop
    Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber -ErrorAction Stop
    Write-Host "PowerApps modules installed successfully" -ForegroundColor Green
} catch {
    Write-Warning "Failed to install PowerApps modules: $($_.Exception.Message)"
}

Write-Host "`nSetup Complete! Please restart your shell or machine for all changes to take full effect." -ForegroundColor Green
