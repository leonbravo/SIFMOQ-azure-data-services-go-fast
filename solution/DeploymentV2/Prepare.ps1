# ------------------------------------------------------------------------------------------------------------
# You must be logged into the Azure CLI to run this script
# ------------------------------------------------------------------------------------------------------------
# 
# The purpose of this script is to set your Azure environment ready for the deployment
# - This should be run once per environment.
# - To run it, provide the request parameters
# - resource group name to be created. If you skip this, only the providers will be registered
# - storage account name to store your terraform state. If you skip this, no storage account will be created
# 
# At the end of the execution, you will be provided the outputs from the preparation steps.
# These are pre-loaded into environment variables so that you can directly run the ./Deploy.ps1 script
# to create a new environment using local terraform state. 
# 
# To save you double handling and finding them later, I recommend that you copy them down and update
# the values directly into the following file:
#
# /azure-data-services-go-fast-codebase/solution/DeploymentV2/terraform/vars/local/terragrunt.hcl
#
# This file is used by the ./Deploy.ps1 script by default and will be used if no enviroment vars are available
#
# Once this script has finished, you then run Deploy.ps1 to create your environment
# ------------------------------------------------------------------------------------------------------------



#by default $gitDeploy will not be true, only being set by the git environment - meaning if not using a runner it will default to a standard execution.
$gitDeploy = ([System.Environment]::GetEnvironmentVariable('gitDeploy')  -eq 'true')
$deploymentFolderPath = (Get-Location).Path 
$envlist = (Get-ChildItem -Directory -Path ./environments/vars | Select-Object -Property Name).Name

if ($gitDeploy)
{
    Write-Host "Git Deployment"
    $environmentName = [System.Environment]::GetEnvironmentVariable('environmentName')
    $resourceGroupName = [System.Environment]::GetEnvironmentVariable('resource_group_name')
    $stateStorageName = [System.Environment]::GetEnvironmentVariable('state_storage_account_name')
}
else
{
    Write-Host "Standard Deployment"
    Import-Module ./pwshmodules/GetSelectionFromUser.psm1 -Force   
    $environmentName = Get-SelectionFromUser -Options ($envlist) -Prompt "Select deployment environment"
    [System.Environment]::SetEnvironmentVariable('environmentName', $environmentName)
}


if ($environmentName -eq "Quit")
{
    Exit
}


if ($gitDeploy)
{
    $providers = @('Microsoft.Storage',
    'Microsoft.Network',
    'Microsoft.Web',
    'microsoft.insights',
    'Microsoft.ManagedIdentity',
    'Microsoft.KeyVault',
    'Microsoft.OperationalInsights',
    'Microsoft.Purview',
    'Microsoft.EventHub',
    'Microsoft.Compute',
    'Microsoft.PolicyInsights',
    'Microsoft.OperationsManagement',
    'Microsoft.Synapse',
    'Microsoft.DataFactory',
    'Microsoft.Sql')
    
    ForEach ($provider in $providers) {
        az provider register --namespace $provider --only-show-errors
    }
    
    az storage account create --resource-group $resourceGroupName --name $stateStorageName --sku Standard_LRS --allow-blob-public-access false --https-only true --min-tls-version TLS1_2 --public-network-access Disabled --only-show-errors
    az storage container create --name tstate --account-name $stateStorageName --auth-mode login --only-show-errors
}
else 
{    
    $env:TF_VAR_resource_group_name = Read-Host "Enter the name of the resource group to create (enter to skip)"
    $env:TF_VAR_state_storage_account_name = Read-Host "Enter the name of the state storage account name to create. If you enter nothing the name will be set as 'resourcegroupname'+'state'. Note: All non valid characters will also be stripped"
    if([string]::IsNullOrEmpty($env:TF_VAR_state_storage_account_name) -eq $true) {
        $temp = $env:TF_VAR_resource_group_name + "state"
        $env:TF_VAR_state_storage_account_name = $temp -replace "\W"
        Write-Host "Auto applied state name:" $env:TF_VAR_state_storage_account_name
    }
    if($env:TF_VAR_state_storage_account_name.length -gt 24)
    {
        Write-Host "The state storage account name" $env:TF_VAR_state_storage_account_name "is invalid"
        do {
            $input = Read-Host "Please input a state storage account name that is less than 25 characters long (only letters and numbers, no spaces)"
            $input = $input -replace "\W"
        } until ($input.length -le 24)
        $env:TF_VAR_state_storage_account_name = $input
        Write-Host "Storage account name: " $env:TF_VAR_state_storage_account_name
    }


    $CONTAINER_NAME="tstate"
    # ------------------------------------------------------------------------------------------------------------
    # Ensure that you have all of the require Azure resource providers enabled before you begin deploying the solution.
    # ------------------------------------------------------------------------------------------------------------
    $RegRps = Get-SelectionFromUser -Options ('Yes','No') -Prompt "Do you want to register the Azure resource providers? (the recommended answer is 'Yes')"
    if ($RegRps -eq "Quit")
    {
        Exit
    }
    if ($RegRps -eq 'Yes')
    {
        $providers = @('Microsoft.Storage',
        'Microsoft.Network',
        'Microsoft.Web',
        'microsoft.insights',
        'Microsoft.ManagedIdentity',
        'Microsoft.KeyVault',
        'Microsoft.OperationalInsights',
        'Microsoft.Purview',
        'Microsoft.EventHub',
        'Microsoft.Compute',
        'Microsoft.PolicyInsights',
        'Microsoft.OperationsManagement',
        'Microsoft.Synapse',
        'Microsoft.DataFactory',
        'Microsoft.Sql')

        $progress = 0
        Write-Progress -Activity "Registering Azure Resource Providers" -Status "${progress}% Complete:" -PercentComplete $progress

        ForEach ($provider in $providers) {
            $progress += 5;
            az provider register --namespace $provider --only-show-errors
            Write-Progress -Activity "Registering Azure Resource Providers" -Status "${progress}% Complete:" -PercentComplete $progress
        }
    }

    # ------------------------------------------------------------------------------------------------------------
    # Save the current tenant/sub details for use bt TF later
    # ------------------------------------------------------------------------------------------------------------
    $currentAccount = az account show | ConvertFrom-Json
    $env:TF_VAR_tenant_id = $currentAccount.tenantId
    $env:TF_VAR_subscription_id = $currentAccount.id
    $env:TF_VAR_ip_address = (Invoke-WebRequest ifconfig.me/ip).Content

    $env:TF_VAR_domain = az account show --query 'user.name' --only-show-errors | cut -d '@' -f 2 | sed 's/\"//' 

    #------------------------------------------------------------------------------------------------------------
    # Create the resource group and terraform state store 
    #------------------------------------------------------------------------------------------------------------
    # Note that this will create the account without any firewall rules. Depending on your environment
    # You will potentially want to connect this to a Vnet via private link, Deny public internet access
    # and restrict it so that only GitHub / AzDO can access it.
    #------------------------------------------------------------------------------------------------------------
    if([string]::IsNullOrEmpty($env:TF_VAR_resource_group_name) -eq $false) {
        $rg = az group create -n $env:TF_VAR_resource_group_name -l australiaeast --only-show-errors

        if([string]::IsNullOrEmpty($env:TF_VAR_state_storage_account_name) -eq $false) {            
            $delay_private_access = $false
            $layer0_state = "remote"
            $deploy_state_storage_account = $false
            $deploy_cicd_vm = $false
            $uinput = Get-SelectionFromUser -Options ('Public','Isolated', 'Private') -Prompt "Please select Network Isolation Level"
            if($uinput -eq "Public")
            {
                $delay_private_access = $true
                Write-Host "Creating Public Storage"
                $storageId = az storage account create --resource-group $env:TF_VAR_resource_group_name --name $env:TF_VAR_state_storage_account_name --sku Standard_LRS --allow-blob-public-access false --public-network-access Enabled --default-action Allow --https-only true --min-tls-version TLS1_2 --query id -o tsv --only-show-errors           
            }

            if($uinput -eq "Isolated")
            {
                $delay_private_access = $true
                Write-Host "Creating Isolated Storage. In this deployment mode private networking will be established but the CICD agent will open firewalls to allow targeted public internet access to facilitate deployment. "      
                #Isolated 
                $storageId = az storage account create --resource-group $env:TF_VAR_resource_group_name --name $env:TF_VAR_state_storage_account_name --sku Standard_LRS --allow-blob-public-access false --public-network-access Enabled --default-action Deny --https-only true --min-tls-version TLS1_2 --query id -o tsv --only-show-errors
                $hiddenoutput =az storage account network-rule add --resource-group $env:TF_VAR_resource_group_name --account-name $env:TF_VAR_state_storage_account_name --ip-address $env:TF_VAR_ip_address --only-show-errors
                #wait for network rule 
                [System.Threading.Thread]::Sleep(5000)
            }
            if($uinput -eq "Private")
            {
                
                Write-Host "Configuring for fully private storage. In this deployment mode private networking will be established from the onset."      
                Write-Warning "This is a more complex deployment and will require appropriate connectivity to be established between deployment agent and all deployed resources."

                
                $delay_private_access = $false
                $layer0_state = "local"
                $deploy_state_storage_account = $true
                $deploy_cicd_vm =$ true
                #$storageId = az storage account create --resource-group $env:TF_VAR_resource_group_name --name $env:TF_VAR_state_storage_account_name --sku Standard_LRS --pr  --allow-blob-public-access false --public-network-access Disabled --https-only true --min-tls-version TLS1_2 --query id -o tsv --only-show-errors
                #$DeploymentVnet =  Read-Host "Please input the name of the spoke vnet for the deployment. If you leave it blank it will default to 'ads-stg-vnet-ads'"
                #if([string]::IsNullOrEmpty($DeploymentVnet))
                #{
                #    $DeploymentVnet = "ads-stg-vnet-ads"
                #}                       
                
                #Create the VNET 
                #$output = az network vnet create --name $DeploymentVnet --resource-group $env:TF_VAR_resource_group_name --address-prefixes "10.0.0.0/24"  --subnet-name ads-stg-snet-ads-vm --subnet-prefixes 10.0.0.192/26
                        
                #Create Private Endpoint for DFS
                #$output = az network private-endpoint create -g $env:TF_VAR_resource_group_name -n $env:TF_VAR_state_storage_account_name --vnet-name $DeploymentVnet --subnet ads-stg-snet-ads-vm --private-connection-resource-id "/subscriptions/$env:TF_VAR_subscription_id/resourceGroups/$env:TF_VAR_resource_group_name/providers/Microsoft.Storage/storageAccounts/$env:TF_VAR_state_storage_account_name" --connection-name "$env:TF_VAR_state_storage_account_name-dfs-plink" -l australiaeast --group-id dfs --zone-name "privatelink.dfs.core.windows.net"  
                                       
                
                #DFS Zone and Vnet Link
                #$output = az network private-dns zone create --resource-group $env:TF_VAR_resource_group_name --name "privatelink.dfs.core.windows.net"
                #$output = az network private-endpoint dns-zone-group create --endpoint-name "$env:TF_VAR_state_storage_account_name" -g $env:TF_VAR_resource_group_name -n "privatednszonegroupstoragedfs" --zone-name "privatelink.dfs.core.windows.net" --private-dns-zone "privatelink.dfs.core.windows.net"
                #$output = az network private-dns link vnet create --name "privatelink.dfs.core.windows.net" --registration-enabled false --resource-group $env:TF_VAR_resource_group_name --virtual-network "/subscriptions/$env:TF_VAR_subscription_id/resourceGroups/$env:TF_VAR_resource_group_name/providers/Microsoft.Network/virtualNetworks/$DeploymentVnet" --zone-name "privatelink.dfs.core.windows.net"
                
                #Add Resources to Zones
                #$storageip =  ((az network private-endpoint show --resource-group $env:TF_VAR_resource_group_name  --name $env:TF_VAR_state_storage_account_name) | ConvertFrom-Json -depth 10).customDnsConfigs.ipAddresses
                #az network private-dns record-set a create -g $env:TF_VAR_resource_group_name -z "privatelink.dfs.core.windows.net" -n "$env:TF_VAR_state_storage_account_name" --ttl 10
                #$output = az network private-dns record-set a add-record -g $env:TF_VAR_resource_group_name  -z "privatelink.dfs.core.windows.net" -n "$env:TF_VAR_state_storage_account_name" -a $storageip
            }
            
            
            if($uinput -ne "Private")
            {
                Write-Host "Creating Role Assignment"        
                $userObjectId = az ad signed-in-user show --query id -o tsv --only-show-errors            
                $assignment = az role assignment create --role "Storage Blob Data Contributor" --assignee-object-id $userObjectId --assignee-principal-type User --only-show-errors
                Write-Host "Creating State Container"        
                $container = az storage container create --name $CONTAINER_NAME --account-name $env:TF_VAR_state_storage_account_name --auth-mode login --only-show-errors
            }
        }

    }


    $assigneeobject = Read-Host "Enter the object id of the AAD account or Group that you would like to have ownership of the new resource group."
    $sqlAdmin = Read-Host "Enter the object id of the AAD account or Group that you would like to have SQL AAD Admin on the Azure SQL Server instances created."

    if([string]::IsNullOrEmpty($assigneeobject -eq $false)) {
        #Write-Host "Skipping Resource Group Ownership Assignment"        
        $output = az role assignment create --role "Owner" --scope "/subscriptions/${env:TF_VAR_subscription_id}/resourcegroups/${env:TF_VAR_resource_group_name}" --assignee-object-id $assigneeobject --only-show-errors
    }
    
    
   
    
    #------------------------------------------------------------------------------------------------------------
    # Print pretty output for user
    #------------------------------------------------------------------------------------------------------------
    Write-Host " ";
    Write-Host "Completed preparing subscription" -ForegroundColor green
    Write-Host " ";
    Write-Host "Tenant: " -NoNewline -ForegroundColor green
    Write-Host "$($currentAccount.tenantId)";
    Write-Host "Subscription: " -NoNewline -ForegroundColor green
    Write-Host "$($currentAccount.name) " -NoNewline
    Write-Host "$($currentAccount.id)"  -ForegroundColor yellow

    if($env:TF_VAR_resource_group_name -ne "") {
        Write-Host "Resource Group: " -NoNewline -ForegroundColor green
        Write-Host "'${env:TF_VAR_resource_group_name}'";
    }
    if($env:TF_VAR_state_storage_account_name -ne "") {
        Write-Host "Storage Account: " -NoNewline -ForegroundColor green
        Write-Host "${env:TF_VAR_state_storage_account_name}";
        Write-Host "Storage Account Container: " -NoNewline -ForegroundColor green
        Write-Host "${CONTAINER_NAME}";    
    }
    Write-Host "The following terraform environment variables have been set:";
    Write-Host " - resource_group_name = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_resource_group_name}";
    Write-Host " - state_storage_account_name = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_state_storage_account_name}";
    Write-Host " - subscription_id = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_subscription_id}";
    Write-Host " - tenant_id = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_tenant_id}";
    Write-Host " - ip_address = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_ip_address}";
    Write-Host " - domain = " -NoNewline -ForegroundColor green
    Write-Host "${env:TF_VAR_domain}";
    Write-Host " ";
    Write-Host "NOTE: It is recommended you copy these into your environment/vars/local/common_vars_values.jsonc file for future use" -ForegroundColor blue
    Write-Host "Press any key to continue...";
    #------------------------------------------------------------------------------------------------------------
    # Pause incase this was run directly
    #------------------------------------------------------------------------------------------------------------
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

    #------------------------------------------------------------------------------------------------------------
    # Persist into relevant environment file
    #------------------------------------------------------------------------------------------------------------
    $PersistEnv = Get-SelectionFromUser -Options ('Yes','No') -Prompt "Do you want to automatically persist the configuration information into the files in your environment folder? WARNING this will overwrite your existing configurations."
    if ($PersistEnv -eq "Quit")
    {
        ## Changed so the prepare does not close if you do not wish to persist.
        #this means you can still get a template even if you do not persist
        ##Exit
    }

    
    if ($PersistEnv -eq "Yes")
    {
       
        $common_vars_values = Get-Content ./environments/vars/$environmentName/common_vars_values.jsonc | ConvertFrom-Json -Depth 10
        $common_vars_values.resource_group_name = $env:TF_VAR_resource_group_name 
        $common_vars_values.domain =  $env:TF_VAR_domain
        $common_vars_values.subscription_id =  $env:TF_VAR_subscription_id 
        $common_vars_values.ip_address =  $env:TF_VAR_ip_address
        $common_vars_values.ip_address2 =  $env:TF_VAR_ip_address
        $common_vars_values.tenant_id =  $env:TF_VAR_tenant_id
        $common_vars_values.state_storage_account_name =  $env:TF_VAR_state_storage_account_name
 
        $common_vars_values.WEB_APP_ADMIN_USER = (az ad signed-in-user show --only-show-errors | ConvertFrom-Json).id
             
        $foundUser = $false
        $common_vars_values.resource_owners =  @()  
        $common_vars_values.synapse_administrators = @{}  

        $common_vars_values.FeatureTemplateOverrides.layer0_state = $layer0_state
        $common_vars_values.deploy_state_storage_account = $deploy_state_storage_account
        $common_vars_values.deploy_cicd_vm = $deploy_cicd_vm
        
        if([string]::IsNullOrEmpty($assigneeobject) -eq $false)
        {
            $common_vars_values.deployment_principal_layers1and3 = $assigneeobject             
            $userPrincipalName = (az ad signed-in-user show --only-show-errors | ConvertFrom-Json).userPrincipalName                  
            $common_vars_values.synapse_administrators.$userPrincipalName = (az ad signed-in-user show --only-show-errors | ConvertFrom-Json).id            
        }
        else 
        {
            $owner = (az ad signed-in-user show | ConvertFrom-Json).id
            $common_vars_values.resource_owners =  @("$owner")      
            $common_vars_values.deployment_principal_layers1and3 = ""
            #$assigneeobject = ((az ad user show --id $currentAccount.user.name) | ConvertFrom-Json -Depth 10).id
        }                  
        
        if([string]::IsNullOrEmpty($sqlAdmin) -eq $false)
        {
            $common_vars_values.azure_sql_aad_administrators = @{}     
            $userPrincipalName = "sql_aad_admin"                  
            $common_vars_values.azure_sql_aad_administrators.$userPrincipalName = $sqlAdmin          
        }
        

        $ResetFlags = Get-SelectionFromUser -Options ('Yes','No') -Prompt "Reset flags for is_onprem_datafactory_ir_registered and deployment_layer3_complete. For brand new deployment select 'Yes'."
        if ($ResetFlags -eq "Yes")
        {
            $common_vars_values.FeatureTemplateOverrides.is_onprem_datafactory_ir_registered = $false
            $common_vars_values.FeatureTemplateOverrides.deployment_layer3_complete = $false
        }
       
        $common_vars_values.FeatureTemplateOverrides.delay_private_access = $delay_private_access        

        $common_vars_values | Convertto-Json -Depth 10 | Set-Content ./environments/vars/$environmentName/common_vars_values.jsonc


        if($environmentName -eq "admz")
        {
            Exit
        }
        #------------------------------------------------------------------------------------------------------------
        # Templated Configurations
        #------------------------------------------------------------------------------------------------------------
        $fts = (Get-ChildItem -Path ./environments/featuretemplates | Select-Object -Property Name).Name.replace(".jsonc","")
        $templateName = Get-SelectionFromUser -Options ($fts) -Prompt "Select deployment fast start template"
        if ($templateName -eq "Quit")
        {
            Exit
        }
        else 
        {
            Set-Location ./environments/vars/
            ./PreprocessEnvironment.ps1 -Environment $environmentName -FeatureTemplate $templateName -gitDeploy $gitDeploy         
        }

    }
}
Write-Host "Prepare Complete...." 
Write-Host "If you are creating a local development instance only, you can run ./Deploy.ps1 now" -ForegroundColor green
Write-Host " " 
Set-Location $deploymentFolderPath







