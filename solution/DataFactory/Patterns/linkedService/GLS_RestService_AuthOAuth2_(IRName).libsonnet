function(shortIRName = "", fullIRName = "")
{
    "name": "GLS_RestService_AuthOAuth2_" + shortIRName,
    "properties": {
        "description": "Generic OAuth2 Rest Connection",
        "parameters": {
            "BaseUrl": {
                "type": "String"
            },
            "ClientId": {
                "type": "String"
            },
            "KeyVaultBaseUrl": {
                "type": "String"
            },
            "PasswordSecret": {
                "type": "String"
            },
            "Resource": {
                "type": "String"
            },
            "Scope": {
                "type": "String"
            },
            "TokenEndpoint": {
                "type": "String"
            }
        },
        "annotations": [],
        "type": "RestService",
        "typeProperties": {
            "url": "@{linkedService().BaseUrl}",
            "enableServerCertificateValidation": true,
            "authenticationType": "OAuth2ClientCredential",
            "clientId": "@{linkedService().ClientId}",
            "clientSecret": {
                "type": "AzureKeyVaultSecret",
                "store": {
                    "referenceName": "GLS_AzureKeyVault_" + shortIRName,
                    "type": "LinkedServiceReference",
                    "parameters": {
                        "KeyVaultBaseUrl": {
                            "value": "@linkedService().KeyVaultBaseUrl",
                            "type": "Expression"
                        }
                    }
                },
                "secretName": {
                    "value": "@linkedService().PasswordSecret",
                    "type": "Expression"
                }
            },
            "tokenEndpoint": "@{linkedService().TokenEndpoint}",
            "scope": "@{linkedService().Scope}",
            "resource": "@{linkedService().Resource}"
        },
        "connectVia": {
            "referenceName": fullIRName,
            "type": "IntegrationRuntimeReference"
        }
    },
    "type": "Microsoft.DataFactory/factories/linkedservices"
}