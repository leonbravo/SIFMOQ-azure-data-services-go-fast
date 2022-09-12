function()
{
    local tout = import "../output/tout.json",
	"name": "SLS_AzureKeyVault",
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"description": "Default Key Vault (Non-Dynamic)",
		"type": "AzureKeyVault",
		"typeProperties": {
			"baseUrl": tout.keyvault_url
		},
		"annotations": []
	}
}