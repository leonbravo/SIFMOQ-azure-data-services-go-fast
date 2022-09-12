function(GenerateArm="false",GFPIR="IRA") 
[
    {
        local referenceName = "GDS_Rest_Anonymous_",
        "referenceName":if(GenerateArm=="false") 
            then referenceName + GFPIR
            else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",
        "type": "DatasetReference",
        "parameters": {
            "BaseUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.System.BaseUrl",
                "type": "Expression"
            },
            "RelativeUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.RelativeUrl",
                "type": "Expression"
            },
            "RequestBody": {
                "value": "@pipeline().parameters.TaskObject.Source.RequestBody",
                "type": "Expression"
            },
            "RequestMethod": {
                "value": "@pipeline().parameters.TaskObject.Source.RequestMethod",
                "type": "Expression"
            }
        }
    }
]