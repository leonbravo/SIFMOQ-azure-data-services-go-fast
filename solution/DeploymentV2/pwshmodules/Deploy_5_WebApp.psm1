function DeployWebApp (
    [Parameter(Mandatory=$true)]
    [pscustomobject]$tout=$false,
    [Parameter(Mandatory=$true)]
    [string]$deploymentFolderPath="",
    [Parameter(Mandatory=$true)]
    [String]$PathToReturnTo=""
)
{
    #----------------------------------------------------------------------------------------------------------------
    #   Building & Deploy Web App
    #----------------------------------------------------------------------------------------------------------------
    $skipWebApp = if($tout.publish_web_app -and $tout.deploy_web_app) {$false} else {$true}
    if ($skipWebApp) {
        Write-Host "Skipping Building & Deploying Web Application"    
    }
    else {
        Write-Host "Building & Deploying Web Application"
        #Move From Workflows to Function App
        Set-Location $deploymentFolderPath
        Set-Location "../WebApplication"
        dotnet restore
        dotnet publish --no-restore --configuration Release --output '..\DeploymentV2\bin\publish\unzipped\webapplication\'
        #Move back to workflows 
        Set-Location $deploymentFolderPath
        Set-Location "./bin/publish"
        $Path = (Get-Location).Path + "/zipped/webapplication" 
        New-Item -ItemType Directory -Force -Path $Path
        $Path = $Path + "/Publish.zip"
        Compress-Archive -Path '.\unzipped\webapplication\*' -DestinationPath $Path -force

        $result = az webapp deployment source config-zip --resource-group $tout.resource_group_name --name $tout.webapp_name --src $Path  --only-show-errors  

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