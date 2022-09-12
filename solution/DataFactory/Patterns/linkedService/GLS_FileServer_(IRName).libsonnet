function(shortIRName = "", fullIRName = "")
{
	"name": "GLS_FileServer_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic File Server",
		"parameters": {
			"Host": {
				"type": "String",
				"defaultValue": ""
			},
			"KeyVaultBaseUrl": {
				"type": "String",
				"defaultValue": ""
			},
			"Secret": {
				"type": "String",
				"defaultValue": ""
			},
			"UserId": {
				"type": "String",
				"defaultValue": ""
			}
		},
		"type": "FileServer",
		"typeProperties": {
			"host": "@{linkedService().Host}",
			"userId": "@{linkedService().UserId}",
			"password": {
				"secretName": {
					"type": "Expression",
					"value": "@linkedService().Secret"
				},
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
			}
		},
		"annotations": []
	}
}