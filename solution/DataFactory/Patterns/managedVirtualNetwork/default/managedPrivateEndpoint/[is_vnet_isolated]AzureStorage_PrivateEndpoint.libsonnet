function()
{
    local tout = import "../../../output/tout.json",
	"name": "AzureStorage_PrivateEndpoint",
	"properties": {
		"privateLinkResourceId": "/subscriptions/" + tout.subscription_id + "/resourceGroups/" + tout.resource_group_name + "/providers/Microsoft.Storage/storageAccounts/" + tout.blobstorage_name,
		"groupId": "blob",
		"fqdns": [
			tout.blobstorage_name + ".blob.core.windows.net"
		]
	}
}