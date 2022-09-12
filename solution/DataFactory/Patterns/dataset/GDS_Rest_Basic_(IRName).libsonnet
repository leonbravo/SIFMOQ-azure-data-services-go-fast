function(shortIRName = "", fullIRName = "")
{
    "name": "GDS_Rest_Basic_" + shortIRName,
    "properties": {
        "linkedServiceName": {
            "referenceName": "GLS_RestService_AuthBasic_" + shortIRName,
            "type": "LinkedServiceReference",
            "parameters": {
                "BaseUrl": {
                    "value": "@dataset().BaseUrl",
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
                "UserName": {
                    "value": "@dataset().UserName",
                    "type": "Expression"
                },
            }
        },
        "parameters": {
            "BaseUrl": {
                "type": "string"
            },
            "RelativeUrl": {
                "type": "string"
            },
            "KeyVaultBaseUrl": {
                "type": "string"
            },
            "PasswordSecret": {
                "type": "string"
            },
            "UserName": {
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