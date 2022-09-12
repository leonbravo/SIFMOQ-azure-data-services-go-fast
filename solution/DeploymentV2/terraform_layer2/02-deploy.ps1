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
import-Module ./../pwshmodules/ProcessTerraformApply.psm1 -force
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
# Main Terraform - Layer1
#------------------------------------------------------------------------------------------------------------
Write-Host "Starting Terraform Deployment- Layer 2"
Write-Host "Expect this to take twenty to thirty minutes to complete the first time it is run. Subsequent, incremental builds should only take a few minutes."
if([string]::IsNullOrEmpty($env:TF_VAR_jumphost_password) -and ($gitDeploy -eq $false -or $null -eq $gitdeploy))
{
    $env:TF_VAR_jumphost_password = Read-Host "Enter the Jumphost Password"
}

if([string]::IsNullOrEmpty($env:TF_VAR_synapse_sql_password) -and ($gitDeploy -eq $false -or $null -eq $gitdeploy))
{
    $env:TF_VAR_synapse_sql_password = Read-Host "Enter the Synapse SQL Admin Password"
}

$output = terragrunt init --terragrunt-config vars/$env:environmentName/terragrunt.hcl -reconfigure 
$output = terragrunt apply -auto-approve --terragrunt-config vars/$env:environmentName/terragrunt.hcl -json #-var synapse_sql_password=$env:TF_VAR_synapse_sql_password  

ProcessTerraformApply -output $output -gitDeploy $gitDeploy


#Update Values for variables in Environment
#[Environment]::SetEnvironmentVariable("TF_VAR_state_storage_account_name", $Value) 
$tout_raw = ((az storage blob download -c "tstate" -n "terraform_layer2.tfstate" --account-name $env:TF_VAR_state_storage_account_name --auth-mode login) | ConvertFrom-Json).outputs


#conditional
if(-not (([string]::IsNullOrEmpty($tout_raw.adlsstorage_name.value)) -or ([string]::IsNullOrEmpty($tout_raw.keyvault_name.value)) -or([string]::IsNullOrEmpty($tout_raw.synapse_workspace_name.value)) ) )
{
    Write-Host "Writing ARM_DATALAKE_NAME / ARM_KEYVAULT_NAME / ARM_SYNAPSE_WORKSPACE_NAME to common vars environment file"
    $envFolderPath = Convert-Path -Path ($deploymentFolderPath + "./environments/vars/$env:environmentName/")
    $varsfile = $envFolderPath + "/common_vars_values.jsonc"
    $common_vars_values = Get-Content $varsfile | ConvertFrom-Json -Depth 10
    $common_vars_values.ARM_DATALAKE_NAME = $tout_raw.adlsstorage_name.value
    $common_vars_values.ARM_KEYVAULT_NAME = $tout_raw.keyvault_name.value
    $common_vars_values.ARM_SYNAPSE_WORKSPACE_NAME = $tout_raw.synapse_workspace_name.value
    $common_vars_values | Convertto-Json -Depth 10 | Set-Content $varsfile
}
else 
{
    Write-Host "Not writing ARM_DATALAKE_NAME / ARM_KEYVAULT_NAME / ARM_SYNAPSE_WORKSPACE_NAME to common vars environment file"
    Write-Host "ARM_DATALAKE_NAME =" $tout_raw.adlsstorage_name.value
    Write-Host "ARM_KEYVAULT_NAME =" $tout_raw.keyvault_name.value
    Write-Host "ARM_SYNAPSE_WORKSPACE_NAME =" $tout_raw.synapse_workspace_name.value
}

        
