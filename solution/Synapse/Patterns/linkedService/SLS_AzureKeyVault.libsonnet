function()
{
	local tout = import "../output/tout.json",
	"name": "SLS_AzureKeyVault",
	"type": "Microsoft.Synapse/workspaces/linkedservices",
	"properties": {
		"type": "AzureKeyVault",
		"typeProperties": {
			"baseUrl": tout.keyvault_url
		},
		"annotations": []
	}
}
