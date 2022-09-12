function GatherOutputsFromTerraform($TerraformFolderPath)
{

    $currentPath = (Get-Location).Path 
    Set-Location $TerraformFolderPath 
    $environmentName = $env:TFenvironmentName
    #$environmentName = "local" # currently supports (local, staging)
    $myIp = (Invoke-WebRequest ifconfig.me/ip).Content

    #$CurrentFolderPath = $PWD
    $env:TF_VAR_ip_address = $myIp

    #------------------------------------------------------------------------------------------------------------
    # Get all the outputs from terraform so we can use them in subsequent steps
    #------------------------------------------------------------------------------------------------------------
    Write-Debug "-------------------------------------------------------------------------------------------------"
    Write-Debug "Reading Terraform Outputs - Started"

    $tout = New-Object PSObject

    $tout0 = (terraform output -json | ConvertFrom-Json -Depth 10).PSObject.Properties 
    $tout0 | Foreach-Object {                    
        $tout | Add-Member  -MemberType NoteProperty -Name $_.Name -Value $_.Value.value
    }

    $rgid = (az group show -n $tout.resource_group_name | ConvertFrom-Json -Depth 10).id
    $tout | Add-Member  -MemberType NoteProperty -Name "resource_group_id" -Value $rgid

    #Set-Location $CurrentFolderPath
    Write-Debug "Reading Terraform Outputs - Finished"
    Write-Debug "-------------------------------------------------------------------------------------------------"
    Set-Location $currentPath
    return $tout
}