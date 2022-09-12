
function()
{
	local tout = import "../output/tout.json",
	"name": tout.synapse_workspace_name + "-WorkspaceDefaultSqlServer",
	"type": "Microsoft.Synapse/workspaces/linkedservices",
	"properties": {
		"typeProperties": {
			"connectionString": "Data Source=tcp:" + tout.synapse_workspace_name + ".sql.azuresynapse.net,1433;Initial Catalog=@{linkedService().DBName}"
		},
		"parameters": {
			"DBName": {
				"type": "String"
			}
		},
		"type": "AzureSqlDW",
		"connectVia": {
			"referenceName": "AutoResolveIntegrationRuntime",
			"type": "IntegrationRuntimeReference"
		},
		"annotations": []
	}
}



