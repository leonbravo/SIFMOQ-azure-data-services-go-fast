function(GenerateArm="false",GFPIR="IRA") 
[
    {
        local referenceName = "GDS_Rest_Basic_",
        "referenceName":if(GenerateArm=="false") 
            then referenceName + GFPIR
            else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",
        "type": "DatasetReference",
        "parameters": {
            "BaseUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.BaseUrl",
                "type": "Expression"
            },
            "KeyVaultBaseUrl": {
                "value": "@pipeline().parameters.TaskObject.KeyVaultBaseUrl",
                "type": "Expression"
            },
            "PasswordSecret": {
                "value": "@pipeline().parameters.TaskObject.Source.System.PasswordKeyVaultSecretName",
                "type": "Expression"
            },
            "RelativeUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.RelativeUrl",
                "type": "Expression"
            },
            "UserName": {
                "value": "@pipeline().parameters.TaskObject.Source.System.UserName",
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