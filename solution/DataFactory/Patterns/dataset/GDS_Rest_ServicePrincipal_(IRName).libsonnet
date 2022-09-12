function(shortIRName = "", fullIRName = "")
{
	"name": "GDS_Rest_ServicePrincipal_" + shortIRName,
	"properties": {
		"linkedServiceName": {
			"referenceName": "GLS_RestService_AuthServicePrincipal_" + shortIRName,
			"type": "LinkedServiceReference",
			"parameters": {
				"AadResourceId": {
					"value": "@dataset().AadResourceId",
					"type": "Expression"
				},
				"BaseUrl": {
					"value": "@dataset().BaseUrl",
					"type": "Expression"
				},
				"KeyVaultBaseUrl": {
					"value": "@dataset().KeyVaultBaseUrl",
					"type": "Expression"
				},
				"PasswordSecret": {
					"value": "@dataset().PasswordSecret",
					"type": "Expression"
				},
				"ServicePrincipalId": {
					"value": "@dataset().ServicePrincipalId",
					"type": "Expression"
				},
				"TenantId": {
					"value": "@dataset().TenantId",
					"type": "Expression"
				}
			}
		},
		"parameters": {
			"AadResourceId": {
				"type": "string"
			},
			"BaseUrl": {
				"type": "string"
			},
			"KeyVaultBaseUrl": {
				"type": "string"
			},
			"PasswordSecret": {
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
			},
			"ServicePrincipalId": {
				"type": "string"
			},
			"TenantId": {
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