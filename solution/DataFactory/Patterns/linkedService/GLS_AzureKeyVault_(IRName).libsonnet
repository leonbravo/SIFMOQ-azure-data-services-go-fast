function(shortIRName = "", fullIRName = "")
{
    local tout = import "../output/tout.json",
	"name": "GLS_AzureKeyVault_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic Key Vault",
		"parameters": {
			"KeyVaultBaseUrl": {
				"type": "String",
				"defaultValue": tout.keyvault_url
			}
		},
		"type": "AzureKeyVault",
		"typeProperties": {
			"baseUrl": "@{linkedService().KeyVaultBaseUrl}"
		},
		"annotations": []
	}
}