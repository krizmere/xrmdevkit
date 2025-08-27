# Dynamics 365 CE Technical Consultant Essentials
A starting kit for a new device for Dynamics 365 CRM development. Contains scripts to install the necessary tools to get started.

# How To Use
Copy and paste these commands into Powershell (administrator) on a fresh Windows instance.
```
# Install Git and refresh PATH. Comment out if Git is already installed
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if git is installed properly, create local Repo folder to clone repository then change directory
git --version
cd $HOME; mkdir -p Repos; cd Repos
git clone https://github.com/krizmere/d365-crm-technical-essentials.git
cd d365-crm-technical-essentials

# Enable winget configuration
winget configure --enable
winget configure -f d365-xrm-dev-kit.winget --accept-configuration-agreements

# Allow .ps1 scripts to run for this process only once then run the script
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
# .\d365-crm-technical-essentials.ps1
```

## Consulting
| Tool  | Description | Free/Paid |
| :-- | :-- | :-- |
| Microsoft Teams  | Intelligent Recap for transcribing and summarising client meetings during requirements gathering or analysis is crucial.  | Premium License |
| OneNote  | For note taking that can be synchronised across devices, tied to your account. | Free |

## Browser Tools/Extensions
Setup browser profiles per client for easier management of different environments and a bookmark library for easy access to common pages within D365, PP, Azure, DevOps, Teams etc.
| Tool  | Description | Type |
| :-- | :-- | :-- |
| LevelUp for Dynamics 365  | Allows you to play around with front end components, see hidden fields/data, and get more information from the entity record. | Free Extension |
| uBlock Origin  | Blocks ads. | Free Extension |
| DarkReader  | Reliable dark mode across all sites. | Free Extension |

## Developer Tools
* [Visual Studio (Latest) Professional/Enterprise](https://visualstudio.microsoft.com/downloads/)
* [Visual Studio Code](https://visualstudio.microsoft.com/downloads/)
* [Dataverse Core Tools](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/download-tools-nuget)
* [Power Platform CLI](https://learn.microsoft.com/en-us/power-platform/developer/cli/introduction?tabs=windows)
* [Node.js](https://nodejs.org/en/download/)
* [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)
* [Postman](https://www.postman.com/)
* [XrmToolBox](https://www.xrmtoolbox.com/)
  * Early Bound Generator
  * FetchXml Tester
  * Security Role
* [Fiddler](https://www.telerik.com/download/fiddler)
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&pivots=winget)


## Nuget
* FakeXrmEasy

## Visual Studio Code Extensions
* [Power Platform Tools](https://marketplace.visualstudio.com/items?itemName=microsoft-IsvExpTools.powerplatform-vscode)

## npm
* [jest](https://jestjs.io/)
* [xrm-mock](https://www.npmjs.com/package/xrm-mock)
