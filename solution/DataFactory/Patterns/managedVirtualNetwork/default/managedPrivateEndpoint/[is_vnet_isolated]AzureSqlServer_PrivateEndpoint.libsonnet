function()
{
    local tout = import "../../../output/tout.json",
	"name": "AzureSqlServer_PrivateEndpoint",
	"properties": {
		"privateLinkResourceId": "/subscriptions/" + tout.subscription_id + "/resourceGroups/" + tout.resource_group_name + "/providers/Microsoft.Sql/servers/" + tout.sqlserver_name,
		"groupId": "sqlServer",
		"fqdns": [
			tout.sqlserver_name + ".database.windows.net"
		]
	}
}