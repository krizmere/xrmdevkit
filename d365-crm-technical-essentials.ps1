# A PowerShell script to install all necessary tools for a D365 CE Developer
Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Green
Write-Host "`nInstalling Applications via Winget..." -ForegroundColor Yellow

# Git (Uncomment if not already installed)
# winget install --id=Git.Git --silent --accept-package-agreements --accept-source-agreements

# IDEs & Code Editors
winget install --id=Microsoft.VisualStudioCode --silent --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.VisualStudio.2022.Professional --silent --accept-package-agreements --accept-source-agreements
winget install --id=Notepad++.Notepad++ --silent --accept-package-agreements --accept-source-agreements

# Node.js (LTS version for Power Platform CLI)
winget install --id=OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements

# Browsers for cross-browser development and testing. Assume Microsoft Edge is automatically installed in Windows.
winget install --id=Google.Chrome --silent --accept-package-agreements --accept-source-agreements
winget install --id=Mozilla.Firefox --silent --accept-package-agreements --accept-source-agreements

# Power BI Desktop
winget install --id=Microsoft.PowerBI --silent --accept-package-agreements --accept-source-agreements

# Microsoft Teams
winget install --id=Microsoft.Teams --silent --accept-package-agreements --accept-source-agreements

# Azure
winget install --id=Microsoft.AzureCLI --silent --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.AzureDataStudio --silent --accept-package-agreements --accept-source-agreements

# Fiddler Classic + Postman for web debugging and testing
winget install --id=Telerik.Fiddler.Classic --silent --accept-package-agreements --accept-source-agreements
winget install --id=Postman.Postman --silent --accept-package-agreements --accept-source-agreements

# 7-Zip
winget install --id=7zip.7zip --silent --accept-package-agreements --accept-source-agreements

# .NET SDKs
winget install --id=Microsoft.DotNet.SDK.8 --silent --accept-package-agreements --accept-source-agreements

# XrmToolBox 
winget install --id=MscrmTools.XrmToolBox --silent --accept-package-agreements --accept-source-agreements
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
    Write-Host "Shortcut created: $shortcutPath"
} else {
    Write-Warning "XrmToolBox.exe not found under WinGet packages."
}

# Power Apps CLI
winget install --id Microsoft.PowerAppsCLI --silent --accept-package-agreements --accept-source-agreements

# Update Path Environment Variable (Refreshes so 'pac' command is recognized)
#$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$env:PATH += ";$([Environment]::GetFolderPath('LocalApplicationData'))\Microsoft\PowerAppsCLI"
Set-Location $env:USERPROFILE
# Initialize Power Apps CLI 
Write-Host "`nSetting up Power Apps CLI..." -ForegroundColor Yellow
pac install latest

# Helper function to pre-download Dataverse tools via pac (prevents UI sticking around)
function Ensure-PacTool {
    param([ValidateSet('prt','cmt','pd')]$Name)

    Write-Host "Ensuring pac tool '$Name' is downloaded/updated..."
    # --update forces grab of the latest from NuGet; first run downloads if missing
    $p = Start-Process -FilePath "pac.exe" -ArgumentList "tool $Name --update" -WindowStyle Hidden -PassThru
    $p.WaitForExit()

    # If a UI launched, close it quietly so the script continues unattended
    $uiMap = @{ prt='PluginRegistration'; cmt='Microsoft.Xrm.Tooling.ConfigurationMigration.WpfApp'; pd='PackageDeployer' }
    $ui = $uiMap[$Name]
    if ($ui) { Get-Process -Name $ui -ErrorAction SilentlyContinue | Stop-Process -Force }
}

# 5) Pre-download the usual Dataverse tools and list them to ensure they are installed correctly
Ensure-PacTool prt   # Plug-in Registration Tool
Ensure-PacTool cmt   # Configuration Migration Tool
Ensure-PacTool pd    # Package Deployer
pac tool list

# Install PowerApps modules. This might require enabling TLS1.2 for older PowerShell versions
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber
Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber

Write-Host "`nSetup Complete! Please restart your shell or machine for all changes to take full effect." -ForegroundColor Green
