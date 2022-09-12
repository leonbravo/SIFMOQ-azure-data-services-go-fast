function()
{
	local tout = import "../../../output/tout.json",
	"name": "AzureKeyVault_PrivateEndpoint",
	"properties": {
		"privateLinkResourceId": "/subscriptions/" + tout.subscription_id + "/resourceGroups/" + tout.resource_group_name + "/providers/Microsoft.KeyVault/vaults/" + tout.keyvault_name,
		"groupId": "vault",
		"fqdns": [
			tout.keyvault_name + ".vaultcore.azure.net"
		]
	}
}