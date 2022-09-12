function(shortIRName = "", fullIRName = "")
{
	"name": "GLS_AzureSqlDW_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic Azure Synapse Connection",
		"parameters": {
			"Database": {
				"type": "String",
				"defaultValue": ""
			},
			"Server": {
				"type": "String",
				"defaultValue": ""
			}
		},
		"type": "AzureSqlDW",
		"typeProperties": {
			"connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=@{linkedService().Server};Initial Catalog=@{linkedService().Database}"
		},
		"annotations": []
	}
}