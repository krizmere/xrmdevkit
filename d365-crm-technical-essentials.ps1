# A PowerShell script to install all necessary tools for a D365 CE Developer
Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Green
Write-Host "`nInstalling Applications via Winget (Parallel)..." -ForegroundColor Yellow

# List of winget packages to install
$wingetPackages = @(
    "Microsoft.VisualStudioCode",
    "Microsoft.VisualStudio.2022.Professional",
    "Notepad++.Notepad++",
    "PDFgear.PDFgear",
    "OpenJS.NodeJS.LTS",
    "Google.Chrome",
    "Mozilla.Firefox",
    "Microsoft.PowerBI",
    "Microsoft.Teams",
    "Microsoft.AzureCLI",
    "Microsoft.AzureDataStudio",
    "Telerik.Fiddler.Classic",
    "Postman.Postman",
    "7zip.7zip",
    "Microsoft.DotNet.SDK.8",
    "MscrmTools.XrmToolBox",
    "Microsoft.PowerAppsCLI"
)

# Function to install a single package
function Install-WingetPackage {
    param($packageId)
    try {
        Write-Host "Installing $packageId..." -ForegroundColor Cyan
        winget install --id=$packageId --silent --accept-package-agreements --accept-source-agreements
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
    while ((Get-Job -State Running).Count -ge $maxConcurrent) {
        Start-Sleep -Seconds 2
        # Check for completed jobs and output their results
        Get-Job -State Completed | ForEach-Object {
            $result = Receive-Job $_
            if ($result) { $completed++ }
            Remove-Job $_
        }
    }
    
    $jobs += Start-Job -ScriptBlock ${function:Install-WingetPackage} -ArgumentList $package -Name "Install-$package"
    Write-Progress -Activity "Installing Packages" -Status "Queued: $package" -PercentComplete (($jobs.Count / $total) * 100)
}

# Wait for all jobs to complete and collect results
Write-Host "`nWaiting for installations to complete..." -ForegroundColor Yellow
while (Get-Job -State Running) {
    $running = (Get-Job -State Running).Count
    $done = $total - $running
    Write-Progress -Activity "Installing Packages" -Status "$done of $total completed ($running running)" -PercentComplete (($done / $total) * 100)
    Start-Sleep -Seconds 5
}

# Process results
$successCount = 0
Get-Job | ForEach-Object {
    $result = Receive-Job $_
    if ($result) { $successCount++ }
    Remove-Job $_
}

Write-Host "`nInstallation completed: $successCount of $total packages installed successfully" -ForegroundColor Green

# XrmToolBox shortcut creation (must run sequentially)
$exe = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Include "XrmToolBox.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
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
    Write-Warning "XrmToolBox.exe not found under WinGet packages."
}

# Update Path Environment Variable
$env:PATH += ";$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\PowerAppsCLI"
Set-Location $env:USERPROFILE

# Initialize Power Apps CLI 
Write-Host "`nSetting up Power Apps CLI..." -ForegroundColor Yellow
pac install latest

# Helper function to pre-download Dataverse tools via pac
function Ensure-PacTool {
    param([ValidateSet('prt','cmt','pd')]$Name)
    Write-Host "Ensuring pac tool '$Name' is downloaded/updated..." -ForegroundColor Cyan
    $p = Start-Process -FilePath "pac.exe" -ArgumentList "tool $Name --update" -WindowStyle Hidden -PassThru
    $p.WaitForExit()
    
    $uiMap = @{ prt='PluginRegistration'; cmt='Microsoft.Xrm.Tooling.ConfigurationMigration.WpfApp'; pd='PackageDeployer' }
    $ui = $uiMap[$Name]
    if ($ui) { Get-Process -Name $ui -ErrorAction SilentlyContinue | Stop-Process -Force }
}

# Pre-download Dataverse tools
Ensure-PacTool prt
Ensure-PacTool cmt
Ensure-PacTool pd
pac tool list

# Install PowerApps modules
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber
Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber

Write-Host "`nSetup Complete! Please restart your shell or machine for all changes to take full effect." -ForegroundColor Green
