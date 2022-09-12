function(GenerateArm="false",GFPIR="",SparkPoolName = "")
local name =  "GPL_SparkNotebookExecution_Primary_" + GFPIR;
local Wrapper = import '../static/partials/wrapper.libsonnet';
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
                "name": "If Condition1",
                "type": "IfCondition",
                "dependsOn": [
                    {
                        "activity": "Set variable1",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "expression": {
                        "value": "@equals(json(string(pipeline().parameters.TaskObject)).TMOptionals.UseNotebookActivity,'Disabled')",
                        "type": "Expression"
                    },
                    "ifFalseActivities": [
                        {
                            "name": "Execute Pipeline2",
                            "type": "ExecutePipeline",
                            "dependsOn": [],
                            "userProperties": [],
                            "typeProperties": {
                                "pipeline": {
                                    "referenceName": "GPL_SparkNotebookExecution_NotebookActivity_"+GFPIR,
                                    "type": "PipelineReference"
                                },
                                "waitOnCompletion": true,
                                "parameters": {
                                    "TaskObject": {
                                        "value": "@pipeline().parameters.TaskObject",
                                        "type": "Expression"
                                    }
                                }
                            }
                        }
                    ],
                    "ifTrueActivities": [
                        {
                            "name": "Execute Pipeline1",
                            "type": "ExecutePipeline",
                            "dependsOn": [],
                            "userProperties": [],
                            "typeProperties": {
                                "pipeline": {
                                    "referenceName": "GPL_SparkNotebookExecution_FunctionActivity_"+GFPIR,
                                    "type": "PipelineReference"
                                },
                                "waitOnCompletion": true,
                                "parameters": {
                                    "TaskObject": {
                                        "value": "@pipeline().parameters.TaskObject",
                                        "type": "Expression"
                                    }
                                }
                            }
                        }
                    ]
                }
            },
            {
                "name": "Set variable1",
                "type": "SetVariable",
                "dependsOn": [],
                "userProperties": [],
                "typeProperties": {
                    "variableName": "UseNotebookActivity",
                    "value": {
                        "value": "@string(pipeline().parameters.TaskObject)",
                        "type": "Expression"
                    }
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
            },
            "NotebookExecutionComplete": {
                "type": "Boolean",
                "defaultValue": false
            },
            "SessionAllocationComplete": {
                "type": "Boolean",
                "defaultValue": false
            },
            "UseNotebookActivity": {
                "type": "String"
            }
        },
        "folder": {
            "name": Folder
        },
        "annotations": [],
        "lastPublishTime": "2022-04-06T03:50:37Z"
    },
    "type": "Microsoft.Synapse/workspaces/pipelines"
};
Wrapper(GenerateArm,pipeline)+{}