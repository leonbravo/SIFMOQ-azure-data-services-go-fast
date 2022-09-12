

function DeploySampleFiles (    
    [Parameter(Mandatory = $true)]
    [pscustomobject]$tout = $false,
    [Parameter(Mandatory = $true)]
    [string]$deploymentFolderPath = "",
    [Parameter(Mandatory = $true)]
    [String]$PathToReturnTo = ""
) {
    #----------------------------------------------------------------------------------------------------------------
    #   Deploy Sample Files
    #----------------------------------------------------------------------------------------------------------------

    #----------------------------------------------------------------------------------------------------------------
    $skipSampleFiles = if ($tout.publish_sample_files) { $false } else { $true }
    if ($skipSampleFiles) {
        Write-Host "Skipping Sample Files"    
    }
    else {
        Set-Location $deploymentFolderPath
        Set-Location "../SampleFiles/"
        Write-Host "Deploying Sample files"
        if ($tout.is_vnet_isolated -eq $true) {
            $result = az storage account update --resource-group $tout.resource_group_name --name $tout.adlsstorage_name --default-action Allow --only-show-errors
        }

        $result = az storage container create --name "datalakelanding" --account-name $tout.adlsstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "datalakeraw" --account-name $tout.adlsstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "datalakeraw" --account-name $tout.blobstorage_name --auth-mode login --only-show-errors
        $result = az storage container create --name "transientin" --account-name $tout.blobstorage_name --auth-mode login --only-show-errors

        $result = az storage blob upload-batch --overwrite --destination "datalakeraw" --account-name $tout.adlsstorage_name --source ./ --destination-path samples/ --auth-mode login --only-show-errors
        $result = az storage blob upload-batch --overwrite --destination "datalakeraw" --account-name $tout.blobstorage_name --source ./ --destination-path samples/ --auth-mode login --only-show-errors

        if ($tout.is_vnet_isolated -eq $true) {
            $result = az storage account update --resource-group $tout.resource_group_name --name $tout.adlsstorage_name --default-action Deny --only-show-errors
        }

        Set-Location $deploymentFolderPath

        if ([string]::IsNullOrEmpty($PathToReturnTo) -ne $true) {
            Write-Debug "Returning to $PathToReturnTo"
            Set-Location $PathToReturnTo
        }
        else {
            Write-Debug "Path to return to is null"
        }

    }
}