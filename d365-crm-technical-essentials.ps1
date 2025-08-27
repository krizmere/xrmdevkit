# A PowerShell script to install all necessary tools for a D365 CE Developer
Write-Host "Starting D365 Developer Machine Setup..." -ForegroundColor Green

# 1. Install GUI Applications using Winget
Write-Host "`nInstalling Applications via Winget..." -ForegroundColor Yellow

# Visual Studio Code
winget install --id=Microsoft.VisualStudioCode --silent --accept-package-agreements

# XrmToolBox 
winget install --id=MscrmTools.XrmToolBox --silent --accept-package-agreements

# Node.js (LTS version for Power Platform CLI)
winget install --id=OpenJS.NodeJS.LTS --silent --accept-package-agreements

# Google Chrome
winget install --id=Google.Chrome --silent --accept-package-agreements

# Azure Data Studio (Great for DB-related tasks)
winget install --id=Microsoft.AzureDataStudio --silent --accept-package-agreements

# Git (If not already installed)
winget install --id=Git.Git --silent --accept-package-agreements

# 7-Zip
winget install --id=7zip.7zip --silent --accept-package-agreements

# 2. Install PowerShell Modules
Write-Host "`nInstalling PowerShell Modules..." -ForegroundColor Yellow

# Microsoft's Power Apps CLI
# This might require enabling TLS1.2 for older PowerShell versions
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber
Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber

# 3. Install .NET SDKs
winget install --id=Microsoft.DotNet.SDK.8 --silent --accept-package-agreements

# 4. Update Path Environment Variable (Refreshes so 'pac' command is recognized)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 5. Initialize Power Apps CLI 
Write-Host "`nSetting up Power Apps CLI..." -ForegroundColor Yellow
pac install latest

Write-Host "`nSetup Complete! Please restart your shell or machine for all changes to take full effect." -ForegroundColor Green
