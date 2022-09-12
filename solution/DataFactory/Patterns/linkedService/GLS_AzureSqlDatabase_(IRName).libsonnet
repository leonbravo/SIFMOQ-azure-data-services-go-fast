function(shortIRName = "", fullIRName = "")
{
	"name": "GLS_AzureSqlDatabase_" + shortIRName,
	"type": "Microsoft.DataFactory/factories/linkedservices",
	"properties": {
		"connectVia": {
			"referenceName": fullIRName,
			"type": "IntegrationRuntimeReference"
		},
		"description": "Generic Azure SQL Server",
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
		"type": "AzureSqlDatabase",
		"typeProperties": {
			"connectionString": "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=@{linkedService().Server};Initial Catalog=@{linkedService().Database}"
		},
		"annotations": []
	}
}