function(fullIRName = "")
{
	"name": fullIRName,
	"properties": {
		"type": "Managed",
		"typeProperties": {
			"computeProperties": {
				"location": "Australia East",
				"dataFlowProperties": {
					"computeType": "General",
					"coreCount": 8,
					"timeToLive": 10,
					"cleanup": true
				}
			}
		}
	}
}