
function(GenerateArm="false",GFPIR="IRA",SourceType="Rest",SourceFormat="Basic",TargetType="AzureBlobFS",TargetFormat="Json")
local generateArmAsBool = GenerateArm == "true";
local typeProperties = import './partials/RESTAPI_CopyActivity_TypeProperties_InputOutput.libsonnet';
local BasicInput = import './partials/datasetReferences/BasicInput.libsonnet';
local OAuth2Input = import './partials/datasetReferences/OAuth2Input.libsonnet';
local AnonymousInput = import './partials/datasetReferences/AnonymousInput.libsonnet';
local ServicePrincipalInput = import './partials/datasetReferences/ServicePrincipalInput.libsonnet';
local JsonOutput = import './partials/datasetReferences/JsonOutput.libsonnet';

local Wrapper = import '../static/partials/wrapper.libsonnet';
local name =  if(!generateArmAsBool) 
			then "GPL_"+SourceType+"_"+SourceFormat+"_"+TargetType+"_"+TargetFormat+"_" + "Primary_" + GFPIR 
			else "[concat(parameters('dataFactoryName'), '/','GPL_"+SourceType+"_"+SourceFormat+"_"+TargetType+"_"+TargetFormat+"_Primary_" + "', parameters('integrationRuntimeShortName'))]";
local pipeline = 
{
    "name": name,
    "properties": {
        "activities": [
            {
                "name": "Copy RESTAPI to Storage",
                "type": "Copy",
                "dependsOn": [
                    {
                        "activity": "Copy RESTAPI to Storage Started",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": typeProperties(GenerateArm,GFPIR,SourceType, TargetType, TargetFormat),
                "inputs": (if(SourceFormat=="Anonymous") then AnonymousInput(GenerateArm,GFPIR) else if(SourceFormat=="Basic") then BasicInput(GenerateArm,GFPIR) else if(SourceFormat=="OAuth2") then OAuth2Input(GenerateArm,GFPIR) else if(SourceFormat=="ServicePrincipal") then ServicePrincipalInput(GenerateArm,GFPIR)),
                "outputs":JsonOutput(GenerateArm,GFPIR, TargetType)

            },
            {
                "name": "Copy RESTAPI to Storage Failed",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "Copy RESTAPI to Storage",
                        "dependencyConditions": [
                            "Failed"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "SPL_AzureFunction",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": false,
                    "parameters": {
                        "Body": {
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Copy RESTAPI to Blob\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"Comment\":\"', encodeUriComponent(string(activity('Copy RESTAPI to Storage').error.message)), '\",\"Status\":\"Failed\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            },
            {
                "name": "Copy RESTAPI to Storage Started",
                "type": "ExecutePipeline",
                "dependsOn": [],
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "SPL_AzureFunction",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": false,
                    "parameters": {
                        "Body": {
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":3,\"LogSource\":\"ADF\",\"ActivityType\":\"Copy RESTAPI to Blob\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"Status\":\"Started\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            },
            {
                "name": "Copy RESTAPI to Storage Succeed",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "Copy RESTAPI to Storage",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "pipeline": {
                        "referenceName": "SPL_AzureFunction",
                        "type": "PipelineReference"
                    },
                    "waitOnCompletion": false,
                    "parameters": {
                        "Body": {
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Copy RESTAPI to Blob\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"RowsInserted\":\"', string(activity('Copy RESTAPI to Storage').output.filesWritten), '\",\"Comment\":\"\",\"Status\":\"Complete\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            }
        ],
        "parameters": {
            "TaskObject": {
                "type": "object"
            }
        },
		"folder": {
			"name": if(GenerateArm=="false") 
					then "ADS Go Fast/Data Movement/REST-API-to-Azure-Storage/" + GFPIR
					else "[concat('ADS Go Fast/Data Movement/REST-API-to-Azure-Storage/', parameters('integrationRuntimeShortName'))]",
		},
		"annotations": [],
		"lastPublishTime": "2020-08-04T12:40:45Z"
    },
    "type": "Microsoft.DataFactory/factories/pipelines"
};
	
Wrapper(GenerateArm,pipeline)+{}