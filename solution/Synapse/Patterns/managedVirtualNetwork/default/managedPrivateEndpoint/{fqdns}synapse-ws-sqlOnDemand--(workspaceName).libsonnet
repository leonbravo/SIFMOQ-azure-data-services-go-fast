function()
{
	local tout = import "../../../output/tout.json",
	"name": "synapse-ws-sqlOnDemand--" + tout.synapse_workspace_name,
	"properties": {
		"privateLinkResourceId": "/subscriptions/" + tout.subscription_id + "/resourceGroups/" + tout.resource_group_name +"/providers/Microsoft.Synapse/workspaces/" + tout.synapse_workspace_name,
		"groupId": "sqlOnDemand",
		"fqdns": [
			tout.synapse_workspace_name + "-ondemand.1e7afd3c-47db-4647-8ee0-be6197386800.sql.azuresynapse.net"
		]
	}
}