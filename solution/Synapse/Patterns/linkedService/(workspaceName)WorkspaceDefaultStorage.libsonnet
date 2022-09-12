function()
{
	local tout = import "../output/tout.json",
	"name": tout.synapse_workspace_name + "-WorkspaceDefaultStorage",
	"type": "Microsoft.Synapse/workspaces/linkedservices",
	"properties": {
		"typeProperties": {
			"url": "https://" + tout.adlsstorage_name + ".dfs.core.windows.net"
		},
		"type": "AzureBlobFS",
		"connectVia": {
			"referenceName": "AutoResolveIntegrationRuntime",
			"type": "IntegrationRuntimeReference"
		},
		"annotations": []
	}
}