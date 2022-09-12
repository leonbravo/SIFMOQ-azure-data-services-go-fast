function(shortIRName = "", fullIRName = "")
{
    "name": "GDS_Rest_OAuth2_" + shortIRName,
    "properties": {
        "linkedServiceName": {
            "referenceName": "GLS_RestService_AuthOAuth2_" + shortIRName,
            "type": "LinkedServiceReference",
            "parameters": {
                "BaseUrl": {
                    "value": "@dataset().BaseUrl",
                    "type": "Expression"
                },
                "ClientId": {
                    "value": "@dataset().ClientId",
                    "type": "Expression"
                },
                "KeyVaultBaseUrl": {
                    "value": "@dataset().KeyVaultBaseUrl",
                    "type": "Expression"
                },
                "PasswordSecret": {
                    "value": "@dataset().PasswordSecret",
                    "type": "Expression"
                },
                "Resource": {
                    "value": "@dataset().Resource",
                    "type": "Expression"
                },
                "Scope": {
                    "value": "@dataset().Scope",
                    "type": "Expression"
                },
                "TokenEndpoint": {
                    "value": "@dataset().TokenEndpoint",
                    "type": "Expression"
                }
            }
        },
        "parameters": {
            "BaseUrl": {
                "type": "string"
            },
            "ClientId": {
                "type": "string"
            },
            "KeyVaultBaseUrl": {
                "type": "string"
            },
            "PasswordSecret": {
                "type": "string"
            },
            "Resource": {
                "type": "string"
            },
            "Scope": {
                "type": "string"
            },
            "TokenEndpoint": {
                "type": "string"
            },
            "RelativeUrl": {
                "type": "string"
            },
            "RequestMethod": {
                "type": "string"
            },
            "RequestBody": {
                "type": "string"
            }
        },
        "folder": {
            "name": "ADS Go Fast/Generic/" + fullIRName
        },
        "annotations": [],
        "type": "RestResource",
        "typeProperties": {
            "relativeUrl": {
                "value": "@dataset().RelativeUrl",
                "type": "Expression"
            },
            "requestMethod": {
                "value": "@dataset().RequestMethod",
                "type": "Expression"
            },
            "requestBody": {
                "value": "@dataset().RequestBody",
                "type": "Expression"
            }
        }
    },
    "type": "Microsoft.DataFactory/factories/datasets"
}