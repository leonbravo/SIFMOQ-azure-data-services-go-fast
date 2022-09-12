#----------------------------------------------------------------------------------------------------------------
# You must be logged into the Azure CLI to run this script
#----------------------------------------------------------------------------------------------------------------
# This script will: 
# - Deploy the required AAD objects (Application Registrations etc)
# 
# This is intended for creating a once off deployment from your development machine. You should setup the
# GitHub actions for your long term prod/non-prod environments
#
# Intructions
# - Ensure that you have run the Prepare.ps1 script first. This will prepare your azure subscription for deployment
# - Ensure that you have run az login and az account set
# - Ensure you have Contributor Access to the subscription you are deploying to. 
# - Ensure you have Application.ReadWrite.OwnedBy on the Azure AD. 
# - Run this script
# 
# You can run this script multiple times if needed.
# 
#----------------------------------------------------------------------------------------------------------------
param (
    [Parameter(Mandatory=$false)]
    [string]$FeatureTemplate=""
)

#------------------------------------------------------------------------------------------------------------
# Module Imports #Mandatory
#------------------------------------------------------------------------------------------------------------
import-Module ./../pwshmodules/GatherOutputsFromTerraform.psm1 -force
import-Module ./../pwshmodules/Deploy_0_Prep.psm1 -force
#------------------------------------------------------------------------------------------------------------
# Preparation #Mandatory
#------------------------------------------------------------------------------------------------------------
$PathToReturnTo = (Get-Location).Path
$deploymentFolderPath = Convert-Path -Path ((Get-Location).tostring() + './../')

$gitDeploy = ([System.Environment]::GetEnvironmentVariable('gitDeploy')  -eq 'true')
$skipTerraformDeployment = ([System.Environment]::GetEnvironmentVariable('skipTerraformDeployment')  -eq 'true')
$ipaddress = $env:TF_VAR_ip_address
$ipaddress2 = $env:TF_VAR_ip_address2

PrepareDeployment -gitDeploy $gitDeploy -deploymentFolderPath $deploymentFolderPath -FeatureTemplate $FeatureTemplate -PathToReturnTo $PathToReturnTo

#------------------------------------------------------------------------------------------------------------
# Get Outputs #Mandatory
#------------------------------------------------------------------------------------------------------------
$tout = GatherOutputsFromTerraform -TerraformFolderPath $PathToReturnTo

./database.ps1 -tout $tout -deploymentFolderPath $deploymentFolderPath -PathToReturnTo $PathToReturnTo -PublishSQLLogins $true
./app_service.ps1 -aad_webreg_id $tout.aad_webreg_id

#Flip Flag on deployment_layer3_complete
$envFolderPath = Convert-Path -Path ($deploymentFolderPath + "./environments/vars/$env:environmentName/")
$varsfile = $envFolderPath + "/common_vars_values.jsonc"
$common_vars_values = Get-Content $varsfile | ConvertFrom-Json -Depth 10
$common_vars_values.FeatureTemplateOverrides.deployment_layer3_complete = $true
$common_vars_values | Convertto-Json -Depth 10 | Set-Content $varsfile
        