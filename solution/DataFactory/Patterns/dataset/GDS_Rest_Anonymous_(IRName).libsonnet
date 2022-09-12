function(shortIRName = "", fullIRName = "")
{
	"name": "GDS_Rest_Anonymous_" + shortIRName,
	"properties": {
		"linkedServiceName": {
			"referenceName": "GLS_RestService_AuthAnonymous_" + shortIRName,
			"type": "LinkedServiceReference",
			"parameters": {
				"BaseUrl": {
					"value": "@dataset().BaseUrl",
					"type": "Expression"
				}
			}
		},
		"parameters": {
			"BaseUrl": {
				"type": "string"
			},
			"RelativeUrl": {
				"type": "string"
			},
			"RequestBody": {
				"type": "string"
			},
			"RequestMethod": {
				"type": "string"
			}
		},
		"folder": {
			"name": "ADS Go Fast/Generic/" + fullIRName
		},
		"annotations": [],
		"type": "RestResource",
		"typeProperties": {
			"relativeUrl": {
				"value": "@dataset().RelativeUrl",
				"type": "Expression"
			},
			"requestMethod": {
				"value": "@dataset().RequestMethod",
				"type": "Expression"
			},
			"requestBody": {
				"value": "@dataset().RequestBody",
				"type": "Expression"
			}
		}
	},
	"type": "Microsoft.DataFactory/factories/datasets"
}