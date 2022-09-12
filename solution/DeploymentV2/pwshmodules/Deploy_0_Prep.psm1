function PrepareDeployment (
    [Parameter(Mandatory = $true)]
    [System.Boolean]$gitDeploy = $false,
    [Parameter(Mandatory = $true)]
    [String]$deploymentFolderPath,
    [Parameter(Mandatory = $false)]
    [String]$FeatureTemplate="",
    [Parameter(Mandatory = $false)]
    [String]$PathToReturnTo = ""
) {
    Set-Location $deploymentFolderPath

    #Check for SQLServer Module
    $SqlInstalled = false
    try { 
        $SqlInstalled = Get-InstalledModule SqlServer
    }
    catch { "SqlServer PowerShell module not installed." }

    if ($null -eq $SqlInstalled) {
        write-host "Installing SqlServer Module"
        Install-Module -Name SqlServer -Scope CurrentUser -Force
    }

    #needed for git integration
    #az extension add --upgrade --name datafactory

    #accept custom image terms
    #https://docs.microsoft.com/en-us/cli/azure/vm/image/terms?view=azure-cli-latest

    #az vm image terms accept --urn h2o-ai:h2o-driverles-ai:h2o-dai-lts:latest



    if ($gitDeploy) {
        $resourceGroupName = [System.Environment]::GetEnvironmentVariable('ARM_RESOURCE_GROUP_NAME')
        $synapseWorkspaceName = [System.Environment]::GetEnvironmentVariable('ARM_RESOURCE_SYNAPSE_WORKSPACE_NAME')
        $env:TF_VAR_ip_address = (Invoke-WebRequest ifconfig.me/ip).Content 
    }
    else {
    
        #Prompt if Environment Variable has not been set
        if ($null -eq [System.Environment]::GetEnvironmentVariable('environmentName')) {        
            $envlist = (Get-ChildItem -Directory -Path ./environments/vars | Select-Object -Property Name).Name
            Import-Module ./pwshmodules/GetSelectionFromUser.psm1 -Force   
            $environmentName = Get-SelectionFromUser -Options ($envlist) -Prompt "Select deployment environment"
            [System.Environment]::SetEnvironmentVariable('environmentName', $environmentName)
        }

        $env:TF_VAR_ip_address2 = (Invoke-WebRequest ifconfig.me/ip).Content     

        #Prompt if Feature Template has not been set
        if ([string]::IsNullOrEmpty($FeatureTemplate) -eq $true) {   
            if ([string]::IsNullOrEmpty($env:ARM_FEATURE_TEMPLATE) -eq $false) {
               $FeatureTemplate =  $env:ARM_FEATURE_TEMPLATE
            }
            else {
                $fts = (Get-ChildItem -Path ./environments/featuretemplates | Select-Object -Property Name).Name.replace(".jsonc", "")
                $templateName = Get-SelectionFromUser -Options ($fts) -Prompt "Select feature template"
                if ($templateName -eq "Quit") {
                    Exit
                }
                else {
                    $FeatureTemplate = $templateName    
                    $env:ARM_FEATURE_TEMPLATE = $FeatureTemplate
                }
            }
            
        }

    }



    $environmentName = [System.Environment]::GetEnvironmentVariable('environmentName')

    if ($environmentName -eq "Quit" -or [string]::IsNullOrEmpty($environmentName)) {
        write-host "environmentName is currently: $environmentName"
        Write-Error "Environment is not set"
        Exit
    }


    #Re-process Environment Config Files. 
    Set-Location ./environments/vars/
    ./PreprocessEnvironment.ps1 -Environment $environmentName -FeatureTemplate $FeatureTemplate -gitDeploy $gitDeploy
    Set-Location $deploymentFolderPath

    [System.Environment]::SetEnvironmentVariable('TFenvironmentName', $environmentName)
    if ($env:TF_VAR_ip_address -ne "")
    {
        try {
            #state
            $resourcecheck = ((az storage account list --resource-group $env:TF_VAR_resource_group_name | ConvertFrom-Json -Depth 10) | Where-Object {$_.name -eq $env:TF_VAR_state_storage_account_name}).count
            if($resourcecheck -gt 0) 
            {
                $hiddenoutput = az storage account network-rule add --resource-group $env:TF_VAR_resource_group_name --account-name  $env:TF_VAR_state_storage_account_name --ip-address $env:TF_VAR_ip_address --only-show-errors
            }            

            #DataLake
            $resourcecheck = ((az storage account list --resource-group $env:TF_VAR_resource_group_name | ConvertFrom-Json -Depth 10) | Where-Object {$_.name -eq $env:datalakeName}).count
            if($resourcecheck -gt 0) {
                $hiddenoutput = az storage account network-rule add --resource-group $env:TF_VAR_resource_group_name --account-name  $env:datalakeName --ip-address $env:TF_VAR_ip_address --only-show-errors
            }

            #Key Vault
            $resourcecheck = ( (az keyvault list --resource-group gft7 | convertfrom-json -depth 10) | Where-Object {$_.name -eq $env:keyVaultName}).count
            if($resourcecheck -gt 0) {
                $hiddenoutput = az keyvault network-rule add -g $env:TF_VAR_resource_group_name --name $env:keyVaultName --ip-address $env:TF_VAR_ip_address/32 --only-show-errors
            }
              
            #Synapse
            $resourcecheck = ( (az synapse workspace list --resource-group gft7 | convertfrom-json -depth 10) | Where-Object {$_.name -eq $env:ARM_SYNAPSE_WORKSPACE_NAME}).count
            if($resourcecheck -gt 0) {
                $hiddenoutput = az synapse workspace firewall-rule create --name CICDAgent --resource-group $env:TF_VAR_resource_group_name --start-ip-address $env:TF_VAR_ip_address --end-ip-address $env:TF_VAR_ip_address --workspace-name $env:ARM_SYNAPSE_WORKSPACE_NAME --only-show-errors
            }
            
        }
        catch {
            Write-Warning 'Opening Firewalls for IP Address One Failed'
        }
    }

    if ($env:TF_VAR_ip_address2 -ne "")
    {
        try {
             #state
             $resourcecheck = ((az storage account list --resource-group $env:TF_VAR_resource_group_name | ConvertFrom-Json -Depth 10) | Where-Object {$_.name -eq $env:TF_VAR_state_storage_account_name}).count
             if($resourcecheck -gt 0) 
             {
                 $hiddenoutput = az storage account network-rule add --resource-group $env:TF_VAR_resource_group_name --account-name  $env:TF_VAR_state_storage_account_name --ip-address $env:TF_VAR_ip_address2 --only-show-errors
             }            
 
             #DataLake
             $resourcecheck = ((az storage account list --resource-group $env:TF_VAR_resource_group_name | ConvertFrom-Json -Depth 10) | Where-Object {$_.name -eq $env:datalakeName}).count
             if($resourcecheck -gt 0) {
                 $hiddenoutput = az storage account network-rule add --resource-group $env:TF_VAR_resource_group_name --account-name  $env:datalakeName --ip-address $env:TF_VAR_ip_address2 --only-show-errors
             }
 
             #Key Vault
             $resourcecheck = ( (az keyvault list --resource-group gft7 | convertfrom-json -depth 10) | Where-Object {$_.name -eq $env:keyVaultName}).count
             if($resourcecheck -gt 0) {
                 $hiddenoutput = az keyvault network-rule add -g $env:TF_VAR_resource_group_name --name $env:keyVaultName --ip-address $env:TF_VAR_ip_address2/32 --only-show-errors
             }
               
             #Synapse
             $resourcecheck = ( (az synapse workspace list --resource-group gft7 | convertfrom-json -depth 10) | Where-Object {$_.name -eq $env:ARM_SYNAPSE_WORKSPACE_NAME}).count
             if($resourcecheck -gt 0) {
                 $hiddenoutput = az synapse workspace firewall-rule create --name CICDAgent --resource-group $env:TF_VAR_resource_group_name --start-ip-address $env:TF_VAR_ip_address2 --end-ip-address $env:TF_VAR_ip_address2 --workspace-name $env:ARM_SYNAPSE_WORKSPACE_NAME --only-show-errors
             }
        }
        catch {
            Write-Warning 'Opening Firewalls for IP Address Two Failed'
        }    
    }


    if ([string]::IsNullOrEmpty($PathToReturnTo) -ne $true) {
        Write-Debug "Returning to $PathToReturnTo"
        Set-Location $PathToReturnTo
    }
    else {
        Write-Debug "Path to return to is null"
    }

}
