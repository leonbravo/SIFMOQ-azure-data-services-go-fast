function(shortIRName = "", fullIRName = "")
{
    "name": "GLS_RestService_AuthServicePrincipal_" + shortIRName,
    "type": "Microsoft.DataFactory/factories/linkedservices",
    "properties": {
        "connectVia": {
            "referenceName": fullIRName,
            "type": "IntegrationRuntimeReference"
        },
        "description": "Generic Service Principal Rest Connection",
        "parameters": {
            "AadResourceId": {
                "type": "String",
                "defaultValue": ""
            },
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
            "ServicePrincipalId": {
                "type": "String",
                "defaultValue": ""
            },
            "TenantId": {
                "type": "String",
                "defaultValue": ""
            }
        },
        "type": "RestService",
        "typeProperties": {
            "url": "@{linkedService().BaseUrl}",
            "enableServerCertificateValidation": true,
            "authenticationType": "AadServicePrincipal",
            "servicePrincipalId": "@{linkedService().ServicePrincipalId}",
            "servicePrincipalKey": {
                "secretName": "@linkedService().PasswordSecret",
                "store": {
                    "parameters": {
                        "KeyVaultBaseUrl": {
                            "type": "Expression",
                            "value": "@linkedService().KeyVaultBaseUrl"
                        }
                    },
                    "referenceName": "GLS_AzureKeyVault_" + shortIRName,
                    "type": "LinkedServiceReference"
                },
                "type": "AzureKeyVaultSecret"
            },
            "tenant": "@linkedService().TenantId",
            "aadResourceId": "@linkedService().AadResourceId"
        },
        "annotations": []
    }
}