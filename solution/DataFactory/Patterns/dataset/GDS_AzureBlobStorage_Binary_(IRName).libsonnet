function(shortIRName = "", fullIRName = "") 
{
    "name": "GDS_AzureBlobStorage_Binary_" + shortIRName,
    "properties": {
        "linkedServiceName": {
            "referenceName": "GLS_AzureBlobStorage_" + shortIRName,
            "type": "LinkedServiceReference",
            "parameters": {
                "StorageAccountEndpoint": {
                    "value": "@dataset().StorageAccountEndpoint",
                    "type": "Expression"
                }
            }
        },
        "parameters": {
            "Directory": {
                "type": "String"
            },
            "File": {
                "type": "String"
            },
            "FileSystem": {
                "type": "String"
            },
            "StorageAccountEndpoint": {
                "type": "String"
            }
        },
        "folder": {
            "name": "ADS Go Fast/Generic/" + fullIRName
        },
        "annotations": [],
        "type": "Binary",
        "typeProperties": {
            "location": {
                "type": "AzureBlobStorageLocation",
                "fileName": {
                    "value": "@dataset().File",
                    "type": "Expression"
                },
                "folderPath": {
                    "value": "@dataset().Directory",
                    "type": "Expression"
                },
                "container": {
                    "value": "@dataset().FileSystem",
                    "type": "Expression"
                }
            }
        }
    },
    "type": "Microsoft.DataFactory/factories/datasets"
}


