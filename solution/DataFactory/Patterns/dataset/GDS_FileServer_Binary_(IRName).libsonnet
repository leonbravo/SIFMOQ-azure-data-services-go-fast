function(shortIRName = "", fullIRName = "")
{
	"name": "GDS_FileServer_Binary_" + shortIRName,
	"properties": {
		"linkedServiceName": {
			"referenceName": "GLS_FileServer_" + shortIRName,
			"type": "LinkedServiceReference",
			"parameters": {
				"Host": {
					"value": "@dataset().Host",
					"type": "Expression"
				},
				"KeyVaultBaseUrl": {
					"value": "@dataset().KeyVaultBaseUrl",
					"type": "Expression"
				},
				"Secret": {
					"value": "@dataset().Secret",
					"type": "Expression"
				},
				"UserId": {
					"value": "@dataset().UserId",
					"type": "Expression"
				}
			}
		},
		"parameters": {
			"Directory": {
				"type": "string"
			},
			"File": {
				"type": "string"
			},
			"Host": {
				"type": "string"
			},
			"KeyVaultBaseUrl": {
				"type": "string"
			},
			"Secret": {
				"type": "string"
			},
			"UserId": {
				"type": "string"
			}
		},
		"folder": {
			"name": "ADS Go Fast/Generic/" + fullIRName
		},
		"annotations": [],
		"type": "Binary",
		"typeProperties": {
			"location": {
				"type": "FileServerLocation",
				"fileName": {
					"value": "@dataset().File",
					"type": "Expression"
				},
				"folderPath": {
					"value": "@dataset().Directory",
					"type": "Expression"
				}
			}
		}
	},
	"type": "Microsoft.DataFactory/factories/datasets"
}