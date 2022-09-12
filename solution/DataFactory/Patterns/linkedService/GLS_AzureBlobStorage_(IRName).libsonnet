function(shortIRName = "", fullIRName = "")
{
	"name": "GLS_AzureBlobStorage_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic Blob Storage",
		"parameters": {
			"StorageAccountEndpoint": {
				"type": "String",
				"defaultValue": ""
			}
		},
		"type": "AzureBlobStorage",
		"typeProperties": {
			"serviceEndpoint": "@{linkedService().StorageAccountEndpoint}"
		},
		"annotations": []
	}
}