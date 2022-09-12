function()
{
    local tout = import "../../../output/tout.json",
	"name": "AzureDataLake_PrivateEndpoint",
	"properties": {
		"privateLinkResourceId": "/subscriptions/" + tout.subscription_id + "/resourceGroups/" + tout.resource_group_name + "/providers/Microsoft.Storage/storageAccounts/" + tout.adlsstorage_name,
        "groupId": "dfs",
		"fqdns": [
			tout.adlsstorage_name + ".dfs.core.windows.net"
		]
	}
}