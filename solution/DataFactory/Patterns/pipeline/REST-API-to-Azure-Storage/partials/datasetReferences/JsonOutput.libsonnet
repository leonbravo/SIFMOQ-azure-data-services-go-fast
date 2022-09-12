function(GenerateArm="false",GFPIR="IRA", TargetType = "AzureBlobFS" ) 
[
    {
        local referenceName = "GDS_"+TargetType+"_Json_",
        "referenceName":if(GenerateArm=="false") 
            then referenceName + GFPIR
            else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",
        "type": "DatasetReference",
        "parameters": {
            "RelativePath": {
                "value": "@pipeline().parameters.TaskObject.Target.RelativePath",
                "type": "Expression"
            },
            "FileName": {
                "value": "@pipeline().parameters.TaskObject.Target.DataFileName",
                "type": "Expression"
            },
            "StorageAccountEndpoint": {
                "value": "@pipeline().parameters.TaskObject.Target.System.SystemServer",
                "type": "Expression"
            },
            "StorageAccountContainerName": {
                "value": "@pipeline().parameters.TaskObject.Target.System.Container",
                "type": "Expression"
            }
        }
    }
]