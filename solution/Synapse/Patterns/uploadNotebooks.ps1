Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder

Write-Information "_____________________________"
Write-Information " Uploading Synapse Notebooks " 
Write-Information "_____________________________"

$tests = (Get-ChildItem -Path ("../../Synapse/Patterns/notebook") -Verbose -Filter "*.ipynb")

foreach ($test in $tests)
{
    ($test | Get-Content) | Set-Content('FileForUpload.json')
    $result = az synapse notebook import --workspace-name $tout.synapse_workspace_name --name $test.BaseName --file '@FileForUpload.json' --folder-path 'FrameworkNotebooks' --only-show-errors
    Remove-Item FileForUpload.json
}


#SIF
if ($tout.publish_sif_database)
{
    $tests = (Get-ChildItem -Path ("../../Synapse/Patterns/notebook/sif") -Verbose -Filter "*.ipynb")
    foreach ($test in $tests)
    {
        ($test | Get-Content) | Set-Content('FileForUpload.json')
        $result = az synapse notebook import --workspace-name $tout.synapse_workspace_name --name $test.BaseName --file '@FileForUpload.json' --folder-path 'FrameworkNotebooks/sif' --only-show-errors
        Remove-Item FileForUpload.json
    }
}

