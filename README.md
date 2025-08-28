# Dynamics 365 XRM Developer Kit
A starting kit for a new device for Dynamics 365 CRM development. Contains scripts to install the necessary tools to get started.

# How To Use
Open Powershell (administrator) on a fresh Windows instance and copy + paste the commands below.
```
# Run command once independently
winget configure --enable
```
```
# Install Git and refresh PATH. Skip if Git is already installed.
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if git is installed properly, create local Repo folder to clone repository then change directory
git --version
cd $HOME
if (-not (Test-Path "Repos")) { mkdir Repos }
cd Repos
git clone https://github.com/krizmere/xrmdevkit.git
cd xrmdevkit

# Enable winget configuration
winget configure -f .config/xrmdevkit.winget --accept-configuration-agreements

# Allow .ps1 scripts to run for this process only once then run the script
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\scripts\xrmdevkit.ps1
```

## General
| Tool  | Description | Free/Paid |
| :-- | :-- | :-- |
| Microsoft Teams  | Intelligent Recap for transcribing and summarising client meetings during requirements gathering or analysis is crucial.  | Premium License |
| Microsoft Office  | For note taking that can be synchronised across devices, tied to your account. | Free |
| PDFgear  | Free tool for working with PDFs. | Free |

## Browser Tools/Extensions
Setup browser profiles per client for easier management of different environments and a bookmark library for easy access to common pages within D365, PP, Azure, DevOps, Teams etc.
| Tool  | Description | Type |
| :-- | :-- | :-- |
| LevelUp for Dynamics 365  | Allows you to play around with front end components, see hidden fields/data, and get more information from the entity record. | Free Extension |
| uBlock Origin  | Blocks ads. | Free Extension |
| DarkReader  | Reliable dark mode across all sites. | Free Extension |

## Developer Tools
* IDEs
  * [Visual Studio Professional/Enterprise](https://visualstudio.microsoft.com/downloads/)
  * [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)
* SDKs
  * [.NET SDK 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)
  * [.NET SDK 8](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
  * [.NET SDK 10](https://dotnet.microsoft.com/en-us/download/dotnet/10.0)
  * [Node.js](https://nodejs.org/en/download/)
  * [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
* CLIs
  * [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=winget)
  * [Power Platform CLI](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction?tabs=windows)
* XRM Tooling
  * [Dataverse Core Tools](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/download-tools-nuget)
  * [XrmToolBox](https://www.xrmtoolbox.com/)
* Web Debugging + Tooling
  * [Fiddler](https://www.telerik.com/download/fiddler)
  * [Postman](https://www.postman.com/)

## Visual Studio Code Extensions
| Name  | Description | Performance |
| :-- | :-- | :-- |
| [C#](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)  | Adds support for C# development, including IntelliSense, debugging, and project management for .NET applications. | Light, unless using large projects or Intellisense-heavy features |
| [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) | Adds support for Python development, including IntelliSense, debugging, refactoring, explorers and more. | Light, unless using large projects or Intellisense-heavy features |
| [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.powershell) | Provides syntax highlighting, IntelliSense, and debugging for PowerShell scripts. | Light |
| [Power Platform Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode)  | Integrates Power Apps, Power Automate, and Dataverse development into VS Code, including CLI and ALM support. | Light |
| [Azure Functions](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions) | Enables development, debugging, and deployment of serverless Azure Functions. | Moderate |
| [Azure Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-node-azure-pack) | Used for deploying, monitoring or managing Azure resources, includes multiple sub-extensions. | Heavy. Disable if not using frequently. |
| [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) | Lints JavaScript/TypeScript code to catch errors, enforce style rules, and improve code quality. | Moderate, actively analyzes JS/TS files |
| [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) | Automatically formats code for consistent style across files and projects. | Light |
| [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) | Useful for managing repos from Azure DevOps | Light |
| [Live Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server) | Allows preview of HTML, CSS, and JavaScript changes in real-time inside VS Code. | Light, mostly idle until previewing |
| [Azure Repos](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-repos) | Integrates Azure DevOps Git repositories for source control management inside. | Light |
| [GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) | Enhances Git capabilities with detailed history, blame annotations, and repository insights. | Light |
| [SQL Server](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql) | Connects to SQL Server or Azure SQL databases, allowing T-SQL queries, IntelliSense, and result exports. | Light, can disable if not writing SQL frequently. |
| [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) | Integrates Windows Subsystem for Linux into VS Code for Linux-based development workflows. | Moderate |
| [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) | Provides containerized development environments for reproducible and isolated setups. | Moderate |
  
## Nuget
* FakeXrmEasy
  
## npm
* [jest](https://jestjs.io/)
* [xrm-mock](https://www.npmjs.com/package/xrm-mock)
