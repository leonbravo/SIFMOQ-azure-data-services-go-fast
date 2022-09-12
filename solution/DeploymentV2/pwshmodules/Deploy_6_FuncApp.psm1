function DeployFuncApp (
    [Parameter(Mandatory=$true)]
    [pscustomobject]$tout=$false,
    [Parameter(Mandatory=$true)]
    [string]$deploymentFolderPath="",
    [Parameter(Mandatory=$true)]
    [String]$PathToReturnTo=""
)
{
    #----------------------------------------------------------------------------------------------------------------
    #   Building & Deploy Function App
    #----------------------------------------------------------------------------------------------------------------
    $skipFunctionApp = if($tout.publish_function_app -and $tout.deploy_function_app) {$false} else {$true}
    if ($skipFunctionApp) {
        Write-Host "Skipping Building & Deploying Function Application"    
    }
    else {
        Write-Host "Building & Deploying Function Application"
        Set-Location $deploymentFolderPath
        Set-Location "..\FunctionApp\FunctionApp"
        dotnet restore
        dotnet publish --no-restore --configuration Release --output '..\..\DeploymentV2\bin\publish\unzipped\functionapp\'
        
        Set-Location $deploymentFolderPath
        Set-Location "./bin/publish"
        $Path = (Get-Location).Path + "/zipped/functionapp" 
        New-Item -ItemType Directory -Force -Path $Path
        $Path = $Path + "/Publish.zip"
        Compress-Archive -Path '.\unzipped\functionapp\*' -DestinationPath $Path -force
        
        $result = az functionapp deployment source config-zip --resource-group $tout.resource_group_name --name $tout.functionapp_name --src $Path --only-show-errors

        #Make sure we are running V6.0 --TODO: Move this to terraform if possible -- This is now done!
        $result = az functionapp config set --net-framework-version v6.0 -n $tout.functionapp_name -g $tout.resource_group_name --only-show-errors
        $result = az functionapp config appsettings set --name $tout.functionapp_name --resource-group $tout.resource_group_name --settings FUNCTIONS_EXTENSION_VERSION=~4 --only-show-errors

        Set-Location $deploymentFolderPath

        if([string]::IsNullOrEmpty($PathToReturnTo) -ne $true)
        {
            Write-Debug "Returning to $PathToReturnTo"
            Set-Location $PathToReturnTo
        }
        else {
            Write-Debug "Path to return to is null"
        }
    }
}
