az config set extension.use_dynamic_install=yes_without_prompt

Import-Module ./GatherOutputsFromTerraform_DataFactoryFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_DataFactoryFolder

if($tout.datafactory_name -eq "") {
    $tout.datafactory_name = Read-Host "Enter the name of the data factory"
}
if($tout.resource_group_name -eq "") {
    $tout.resource_group_name = Read-Host "Enter the name of the resource group"
}

$patterns = ((Get-Content "Patterns.json") | ConvertFrom-Json).Folder | Sort-Object | Get-Unique

foreach ($folder in $patterns)
{   
    Write-Verbose "_____________________________"
    Write-Verbose  $folder
    Write-Verbose "_____________________________" 
    
    $tests = (Get-ChildItem -Path ("./pipeline/"+$folder+"/tests/") -Verbose -recurse)
    foreach ($test in $tests)
    {
        $testfromjson = $test | Get-Content | ConvertFrom-Json    
        ($test | Get-Content) | Set-Content('FileForUpload.json')
        if ($testfromjson.Active -eq $true)
        {
            echo az datafactory pipeline create-run --factory-name $tout.datafactory_name --parameters '@FileForUpload.json' --name $testfromjson.TaskObject.DataFactory.ADFPipeline --resource-group $tout.resource_group_name 
            az datafactory pipeline create-run --factory-name $tout.datafactory_name --parameters '@FileForUpload.json' --name $testfromjson.TaskObject.DataFactory.ADFPipeline --resource-group $tout.resource_group_name
        }
    }
}