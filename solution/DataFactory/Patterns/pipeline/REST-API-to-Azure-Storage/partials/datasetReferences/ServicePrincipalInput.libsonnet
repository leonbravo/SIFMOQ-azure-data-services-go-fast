function(GenerateArm="false",GFPIR="IRA") 
[
    {
        local referenceName = "GDS_Rest_ServicePrincipal_",
        "referenceName":if(GenerateArm=="false") 
            then referenceName + GFPIR
            else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",
        "type": "DatasetReference",
        "parameters": {
            "AadResourceId": {
                "value": "@pipeline().parameters.TaskObject.Source.System.AadResourceId",
                "type": "Expression"
            },
            "BaseUrl": {
                "value": "@pipeline().parameters.TaskObject.Source.System.BaseUrl",
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
            "ServicePrincipalId": {
                "value": "@pipeline().parameters.TaskObject.Source.System.ServicePrincipalId",
                "type": "Expression"
            },
            "TenantId": {
                "value": "@pipeline().parameters.TaskObject.Source.System.TenantId",
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