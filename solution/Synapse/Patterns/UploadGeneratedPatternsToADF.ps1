Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder

if($tout.datafactory_name -eq "") {
    $tout.datafactory_name = Read-Host "Enter the name of the data factory"
}
if($tout.resource_group_name -eq "") {
    $tout.resource_group_name = Read-Host "Enter the name of the resource group"
}
if($tout.resource_group_id -eq "") {
    $tout.resource_group_id = Read-Host "Enter the id of the resource group"
}
if($tout.keyvault_name -eq "") {
    $tout.keyvault_name = Read-Host "Enter the name of the key vault"
}
if($tout.functionapp_name -eq "") {
    $tout.functionapp_name = Read-Host "Enter the name of the function app"
}


function UploadADFItem ($items) {
    if ($items.count -gt 0) {
        $items | Foreach-Object -Parallel {
            $_tout = $using:tout
            $guid = [guid]::NewGuid()
            $lsName = $_.BaseName 
            $fileName = $_.FullName
            $jsonobject = $_ | Get-Content | ConvertFrom-Json

            $uri = "https://" + $_tout.synapse_workspace_name + ".dev.azuresynapse.net/"  #+ "pipelines/"
            
            if ($jsonobject.type -eq "Microsoft.Synapse/workspaces/linkedservices") {
                #Swap out Key Vault Url for Function App Linked Service
                if ($lsName -eq "AdsGoFastKeyVault") {
                    $jsonobject.properties.typeProperties.baseUrl = "https://"+$_tout.keyvault_name+".vault.azure.net/"
                }

                #Swap out Function App Url
                if ($lsName -eq "SLS_AzureFunctionApp") {
                    $jsonobject.properties.typeProperties.functionAppUrl = "https://"+$_tout.functionapp_name+".azurewebsites.net"
                }
            
                $uri = $uri + "linkedservices/"
            }    

            if ($jsonobject.type -eq "Microsoft.Synapse/workspaces/pipelines") {            
                $uri = $uri + "pipelines/"
            }
        
            #ParseOut the Name Attribute
            $name = $jsonobject.name
            $uri = $uri + $name # + "/createRun?api-version=2020-12-01"
            #Persist File Back
            $jsonobject | ConvertTo-Json  -Depth 100 | set-content $_

            #Make a copy of the file for upload 
            Copy-Item  -Path $fileName -Destination "ffu$guid.json"

            Write-Verbose ($lsName) #-ForegroundColor Yellow -BackgroundColor DarkGreen
                        
            Write-Verbose $uri
            $rest = az rest --method put --uri $uri --headers '{\"Content-Type\":\"application/json\"}' --body "@ffu$guid.json" --uri-parameters 'api-version=2020-12-01' --resource 'https://dev.azuresynapse.net'         }
        Get-ChildItem -path "ffu*.json" | Remove-Item
    }
}


$UploadGDS = $false
$UploadGLS = $false

if($UploadGLS -eq $true)
{
    $items = (Get-ChildItem -Path "./output/" -Include "GLS*.json" -Verbose -recurse)
    UploadADFItem -items $items 
    $items = (Get-ChildItem -Path "./output/" -Include "SLS*.json" -Verbose -recurse)
    UploadADFItem -items $items 
}

if($UploadGDS -eq $true)
{
    $items = (Get-ChildItem -Path "./output/" -Include "GDS*.json" -Verbose -recurse)
    UploadADFItem -items $items
}



Write-Information "_____________________________"
Write-Information "Static Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "SPL_*.json"  -Verbose -recurse)
UploadADFItem -items $items
Write-Information "_____________________________"
Write-Information "Level 0 Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "GPL0_*.json"  -Verbose -recurse)
UploadADFItem -items $items
Write-Information "_____________________________"
Write-Information "Level 1 Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "GPL1_*.json"  -Verbose -recurse)
UploadADFItem -items $items
Write-Information "_____________________________"
Write-Information "Level 2 Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "GPL2_*.json" -Verbose -recurse)
UploadADFItem -items $items
Write-Information "_____________________________"
Write-Information "Top Level Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "GPL_*.json" -Verbose -recurse)
UploadADFItem -items $items
Write-Information "_____________________________"
Write-Information "Wrapper Pipelines"
Write-Information "_____________________________"
$items = (Get-ChildItem -Path "./output/" -Include "GPL-1_*.json" -Verbose -recurse)
UploadADFItem -items $items