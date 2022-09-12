function(shortIRName = "", fullIRName = "")
{
	"name": "GDS_AzureSqlDWTable_NA_"  + shortIRName,
	"properties": {
		"linkedServiceName": {
			"referenceName": "GLS_AzureSqlDW_"  + shortIRName,
			"type": "LinkedServiceReference",
			"parameters": {
				"Database": {
					"value": "@dataset().Database",
					"type": "Expression"
				},
				"Server": {
					"value": "@dataset().Server",
					"type": "Expression"
				}
			}
		},
		"parameters": {
			"Database": {
				"type": "String"
			},
			"Schema": {
				"type": "String"
			},
			"Server": {
				"type": "String"
			},
			"Table": {
				"type": "String"
			}
		},
		"folder": {
			"name": "ADS Go Fast/Generic/" + fullIRName
		},
		"annotations": [],
		"type": "AzureSqlDWTable",
		"schema": [],
		"typeProperties": {
			"schema": {
				"value": "@dataset().Schema",
				"type": "Expression"
			},
			"table": {
				"value": "@dataset().Table",
				"type": "Expression"
			}
		}
	},
	"type": "Microsoft.DataFactory/factories/datasets"
}