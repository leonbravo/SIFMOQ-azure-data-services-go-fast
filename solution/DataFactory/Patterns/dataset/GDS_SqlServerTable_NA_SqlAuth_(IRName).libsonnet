function(shortIRName = "", fullIRName = "") 
{
    "name": "GDS_SqlServerTable_NA_SqlAuth_" + shortIRName,
    "properties": {
        "linkedServiceName": {
            "referenceName": "GLS_SqlServerDatabase_sqlauth_" + shortIRName,
            "type": "LinkedServiceReference",
            "parameters": {
                "Database": {
                    "value": "@dataset().Database",
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
                "Server": {
                    "value": "@dataset().Server",
                    "type": "Expression"
                },
                "UserName": {
                    "value": "@dataset().UserName",
                    "type": "Expression"
                }
            }
        },
        "parameters": {
            "Database": {
                "type": "String"
            },
            "KeyVaultBaseUrl": {
                "type": "String"
            },
            "PasswordSecret": {
                "type": "String"
            },
            "Server": {
                "type": "String"
            },
            "TableName": {
                "type": "String"
            },
            "TableSchema": {
                "type": "String"
            },
            "UserName": {
                "type": "String"
            }
        },
        "folder": {
            "name": "ADS Go Fast/Generic/" + fullIRName
        },
        "annotations": [],
        "type": "SqlServerTable",
        "schema": [],
        "typeProperties": {
            "schema": {
                "value": "@dataset().TableSchema",
                "type": "Expression"
            },
            "table": {
                "value": "@dataset().TableName",
                "type": "Expression"
            }
        }
    },
    "type": "Microsoft.DataFactory/factories/datasets"
}