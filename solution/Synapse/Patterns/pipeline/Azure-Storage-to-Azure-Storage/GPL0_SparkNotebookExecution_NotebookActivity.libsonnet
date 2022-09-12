function(GenerateArm="false", SparkPoolName = "", GFPIR = "")

local generateArmAsBool = GenerateArm == "true";
local Wrapper = import '../static/partials/wrapper.libsonnet';

local typeProperties = import './partials/typeProperties/typeProperties.libsonnet';

local parameterDefaultValue = import './partials/parameterDefaultValue.libsonnet';

local name =  "GPL_SparkNotebookExecution_NotebookActivity_" + GFPIR;

local ActivityName = "CallSynapseNotebook";

local Folder =  if(GenerateArm=="false") 
					then "ADS Go Fast/Data Movement/ExecuteNotebook/" + GFPIR +"/"
					else "[concat('ADS Go Fast/Data Movement/ExecuteNotebook/', parameters('integrationRuntimeShortName'), '/')]";

local pipeline = 
{
    "name": name,
    "properties": {
        "activities": [
            {
                "name": "ExecuteNotebook",
                "type": "SynapseNotebook",
                "dependsOn": [],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "userProperties": [],
                "typeProperties": {
                    "notebook": {
                        "referenceName": {
                            "value": "@if(contains(string(pipeline().parameters.TaskObject), 'ExecuteNotebook'), string(json(string(pipeline().parameters.TaskObject)).TMOptionals.ExecuteNotebook), string(json(string(pipeline().parameters.TaskObject)).ExecutionEngine.JsonProperties.DeltaProcessingNotebook))",
                            "type": "Expression"
                        },
                        "type": "NotebookReference"
                    },
                    "parameters": {
                        "TaskObject": {
                            "value": {
                                "value": "@string(pipeline().parameters.TaskObject)",
                                "type": "Expression"
                            },
                            "type": "string"
                        }
                    },
                    "snapshot": true,
                    "sparkPool": {
                        "referenceName": SparkPoolName,
                        "type": "BigDataPoolReference"
                    }
                }
            },
            {
                "name": "IsPurviewEnabled",
                "type": "IfCondition",
                "dependsOn": [
                    {
                        "activity": "ExecuteNotebook",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "expression": {
                        "value": "@not(or(equals(string(json(string(pipeline().parameters.TaskObject)).ExecutionEngine.JsonProperties.PurviewAccountName), ''), equals(string(json(string(pipeline().parameters.TaskObject)).TMOptionals.Purview), 'Disabled')))\n",
                        "type": "Expression"
                    },
                    "ifTrueActivities": [
                        {
                            "name": "PrepareMetaData",
                            "type": "SynapseNotebook",
                            "dependsOn": [],
                            "policy": {
                                "timeout": "7.00:00:00",
                                "retry": 0,
                                "retryIntervalInSeconds": 30,
                                "secureOutput": false,
                                "secureInput": false
                            },
                            "userProperties": [],
                            "typeProperties": {
                                "notebook": {
                                    "referenceName": "PrepareMetaData",
                                    "type": "NotebookReference"
                                },
                                "parameters": {
                                    "TaskObject": {
                                        "value": {
                                            "value": "@string(pipeline().parameters.TaskObject)",
                                            "type": "Expression"
                                        },
                                        "type": "string"
                                    }
                                },
                                "snapshot": true,
                                "sparkPool": {
                                    "referenceName": SparkPoolName,
                                    "type": "BigDataPoolReference"
                                }
                            }
                        },
                        {
                            "name": "Set Purview Metadata",
                            "type": "SetVariable",
                            "dependsOn": [
                                {
                                    "activity": "PrepareMetaData",
                                    "dependencyConditions": [
                                        "Succeeded"
                                    ]
                                }
                            ],
                            "userProperties": [],
                            "typeProperties": {
                                "variableName": "OutputMetaData",
                                "value": {
                                    "value": "@activity('PrepareMetaData').output.status.Output.result.exitValue",
                                    "type": "Expression"
                                }
                            }
                        },
                        {
                            "name": "PassMetaDataToPurview",
                            "type": "AzureFunctionActivity",
                            "dependsOn": [
                                {
                                    "activity": "Set Purview Metadata",
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
                            "typeProperties": {
                                "functionName": "PurviewGetMetaData",
                                "method": "POST",
                                "body": {
                                    "value": "@json(variables('OutputMetaData'))",
                                    "type": "Expression"
                                }
                            },
                            "linkedServiceName": {
                                "referenceName": "SLS_AzureFunctionApp",
                                "type": "LinkedServiceReference"
                            }
                        }
                    ]
                }
            }
        ],
        "parameters": {
            "TaskObject": {
                "type": "object"
            }
        },
        "variables": {
            "OutputMetaData": {
                "type": "String"
            }
        },
        "folder": {
            "name": Folder
        },
        "annotations": [],
        "lastPublishTime": "2022-03-24T05:32:33Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
};
Wrapper(GenerateArm,pipeline)+{}