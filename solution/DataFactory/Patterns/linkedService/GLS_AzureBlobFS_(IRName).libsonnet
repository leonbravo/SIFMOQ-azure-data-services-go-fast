function(shortIRName = "", fullIRName = "")
{
	"name": "GLS_AzureBlobFS_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic Data Lake",
		"parameters": {
			"StorageAccountEndpoint": {
				"type": "String",
				"defaultValue": ""
			}
		},
		"type": "AzureBlobFS",
		"typeProperties": {
			"url": "@{linkedService().StorageAccountEndpoint}"
		},
		"annotations": []
	}
}