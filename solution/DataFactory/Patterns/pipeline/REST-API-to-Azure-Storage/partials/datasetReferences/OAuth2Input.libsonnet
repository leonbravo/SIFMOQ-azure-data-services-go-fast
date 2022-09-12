function(GenerateArm="false",GFPIR="IRA") 
[
    {
        local referenceName = "GDS_Rest_OAuth2_",
        "referenceName":if(GenerateArm=="false") 
            then referenceName + GFPIR
            else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",
        "type": "DatasetReference",
        "parameters": {
            "BaseUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.System.BaseUrl",
                "type": "Expression"
            },
            "ClientId": {
                "value": "@pipeline().parameters.TaskObject.Source.System.ClientId",
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
            "Resource": {
                "value": "@pipeline().parameters.TaskObject.Source.Resource",
                "type": "Expression"
            },
            "Scope": {
                "value": "@pipeline().parameters.TaskObject.Source.Scope",
                "type": "Expression"
            },
            "TokenEndpoint": {
                "value": "@pipeline().parameters.TaskObject.Source.System.TokenEndpoint",
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