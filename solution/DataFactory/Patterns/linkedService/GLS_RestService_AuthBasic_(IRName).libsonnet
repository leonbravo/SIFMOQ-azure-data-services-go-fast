function(shortIRName = "", fullIRName = "")
{
    "name": "GLS_RestService_AuthBasic_" + shortIRName,
    "type": "Microsoft.DataFactory/factories/linkedservices",
    "properties": {
        "connectVia": {
            "referenceName": fullIRName,
            "type": "IntegrationRuntimeReference"
        },
        "description": "Generic Basic Rest Connection",
        "parameters": {
            "BaseUrl": {
                "type": "String",
                "defaultValue": ""
            },
            "KeyVaultBaseUrl": {
                "type": "String",
                "defaultValue": ""
            },
            "PasswordSecret": {
                "type": "String",
                "defaultValue": ""
            },
            "UserName": {
                "type": "String",
                "defaultValue": ""
            }
        },
        "type": "RestService",
        "typeProperties": {
            "url": "@{linkedService().BaseUrl}",
            "enableServerCertificateValidation": true,
            "authenticationType": "Basic",
            "userName": "@linkedService().UserName",
            "password": {
                "secretName": {
                    "type": "Expression",
                    "value": "@linkedService().PasswordSecret"
                },
                "store": {
                    "parameters": {
                        "KeyVaultBaseUrl": "@linkedService().KeyVaultBaseUrl"
                    },
                    "referenceName": "GLS_AzureKeyVault_" + shortIRName,
                    "type": "LinkedServiceReference"
                },
                "type": "AzureKeyVaultSecret"
            }
        },
        "annotations": []
    }
}