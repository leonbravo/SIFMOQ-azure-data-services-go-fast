function(GenerateArm="false",GFPIR="Azure",SourceType="SqlServerTable",SourceFormat="Table", TargetType="AzureBlobFS", TargetFormat="Parquet")

local generateArmAsBool = GenerateArm == "true";
local Wrapper = import '../static/partials/wrapper.libsonnet';

local typePropertiesInputOnly = import './partials/CDC_CopyActivity_TypeProperties_InputOnly.libsonnet';
local typePropertiesInputOutput = import './partials/CDC_CopyActivity_TypeProperties_InputOutput.libsonnet';
local SQL_Query = "@activity('AF Get Information Schema SQL').output.InformationSchemaSQL";
local SQL_Statement1 = "@replace(\n  pipeline().parameters.TaskObject.Source.SQLStatement,\n  '/*Remove First*/--',\n  ''\n  )";
local SQL_Statement2 = "@replace(\n  replace(\n    replace(\n      pipeline().parameters.TaskObject.Source.SQLStatement,\n      '/*Remove Second*/--',\n      ''\n      ),\n    '/*to_lsn*/',\n    activity('GetChangeCount').output.firstRow.to_lsn\n    ),\n'/*from_lsn*/',\nactivity('GetChangeCount').output.firstRow.from_lsn\n)";
local parameterDefaultValue = import './partials/parameterDefaultValue.libsonnet';
local AzureBlobFS_Parquet_CopyActivity_Output = import './partials/CDC_CopyActivity_AzureBlobFS_Parquet_Outputs.libsonnet';
local AzureBlobStorage_Parquet_CopyActivity_Output = import './partials/CDC_CopyActivity_AzureBlobStorage_Parquet_Outputs.libsonnet';
local AzureSqlTable_NA_CopyActivity_Inputs = import './partials/CDC_CopyActivity_AzureSqlTable_NA_Inputs.libsonnet';
local SqlServerTable_NA_CopyActivity_Inputs = import './partials/CDC_CopyActivity_SqlServerTable_NA_Inputs.libsonnet';
local GetTargetMetadata = import './partials/CDC_CopyActivity_GetTargetMetadata.libsonnet';


local name =  if(!generateArmAsBool) 
			then "GPL_"+SourceType+"_"+"NA"+"_"+TargetType+"_"+TargetFormat+"_CDC_" + "Primary_" + GFPIR 
			else "[concat(parameters('dataFactoryName'), '/','GPL_"+SourceType+"_"+"NA"+"_"+TargetType+"_"+TargetFormat+"_CDC_Primary_" + "', parameters('integrationRuntimeShortName'))]";

local Folder =  if(GenerateArm=="false") 
					then "ADS Go Fast/Data Movement/SQL-Database-to-Azure-Storage-CDC/" + GFPIR + "/"
					else "[concat('ADS Go Fast/Data Movement/SQL-Database-to-Azure-Storage-CDC', parameters('integrationRuntimeShortName'), '/')]";

local copyActivityName = "Copy %(Source)s to %(Target)s" % {Source: SourceType, Target: TargetType};
local logSuccessActivityName = "%(ActivityName)s Succeed" % {ActivityName: copyActivityName};
local logStartedActivityName = "%(ActivityName)s Started" % {ActivityName: copyActivityName};
local logFailedActivityName = "%(ActivityName)s Failed" % {ActivityName: copyActivityName};

local pipeline = 
{
    "name": name,
    "properties": {
        "activities": [
            {
                "name": "AF Get Information Schema SQL",
                "type": "AzureFunctionActivity",
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
                    "functionName": "GetInformationSchemaSQL",
                    "method": "POST",
                    "body": {
                        "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"TableSchema\":\"', string(pipeline().parameters.TaskObject.Source.TableSchema), '\",\"TableName\":\"', string(pipeline().parameters.TaskObject.Source.TableName),'\"}'))",
                        "type": "Expression"
                    }
                },
                "linkedServiceName": {
                    "referenceName": "SLS_AzureFunctionApp",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "Lookup Get SQL Metadata",
                "type": "Lookup",
                "dependsOn": [
                    {
                        "activity": "AF Get Information Schema SQL",
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
                "typeProperties": typePropertiesInputOnly(GenerateArm,GFPIR,SourceType, TargetType, TargetFormat, SQL_Query, false)

            },
            {
                "name": "AF Log - Get Metadata Failed",
                "type": "ExecutePipeline",
                "dependsOn": [
                    {
                        "activity": "Lookup Get SQL Metadata",
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
                            "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Get Metadata\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"Comment\":\"', encodeUriComponent(string(activity('Lookup Get SQL Metadata').error.message)), '\",\"Status\":\"Failed\"}'))",
                            "type": "Expression"
                        },
                        "FunctionName": "Log",
                        "Method": "Post"
                    }
                }
            },
            {
                "name": "AF Persist Metadata and Get Mapping",
                "type": "AzureFunctionActivity",
                "dependsOn": [
                    {
                        "activity": "Lookup Get SQL Metadata",
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
                    "functionName": "TaskExecutionSchemaFile",
                    "method": "POST",
                    "body": {
                        "value": "@json(\n concat('{\"TaskInstanceId\":\"',\n string(pipeline().parameters.TaskObject.TaskInstanceId), \n '\",\"ExecutionUid\":\"', \n string(pipeline().parameters.TaskObject.ExecutionUid), \n '\",\"RunId\":\"', string(pipeline().RunId), \n '\",\"StorageAccountName\":\"', \n string(pipeline().parameters.TaskObject.Target.System.SystemServer),\n  '\",\"StorageAccountContainer\":\"', \n  string(pipeline().parameters.TaskObject.Target.System.Container), \n  '\",\"RelativePath\":\"', \n  string(pipeline().parameters.TaskObject.Target.Instance.TargetRelativePath), \n  '\",\"SchemaFileName\":\"', \n  string(pipeline().parameters.TaskObject.Target.SchemaFileName), \n  '\",\"SourceType\":\"', \n  string(pipeline().parameters.TaskObject.Source.System.Type), \n  '\",\"TargetType\":\"', \n  if(\n    contains(\n    string(pipeline().parameters.TaskObject.Target.System.SystemServer),\n    '.dfs.core.windows.net'\n    ),\n   'ADLS',\n   'Azure Blob'), \n  '\",\"Data\":',\n  string(activity('Lookup Get SQL Metadata').output),\n  ',\"MetadataType\":\"SQL\"}')\n)",
                        "type": "Expression"
                    }
                },
                "linkedServiceName": {
                    "referenceName": "SLS_AzureFunctionApp",
                    "type": "LinkedServiceReference"
                }
            },
            {
                "name": "GetChangeCount",
                "type": "Lookup",
                "dependsOn": [
                    {
                        "activity": "AF Persist Metadata and Get Mapping",
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
                "typeProperties": typePropertiesInputOnly(GenerateArm,GFPIR,SourceType, TargetType, TargetFormat, SQL_Statement1, true)
            },
            {
                "name": "HasChangedRows",
                "type": "IfCondition",
                "dependsOn": [
                    {
                        "activity": "GetChangeCount",
                        "dependencyConditions": [
                            "Succeeded"
                        ]
                    }
                ],
                "userProperties": [],
                "typeProperties": {
                    "expression": {
                        "value": "@greater(\n  int(\n    activity('GetChangeCount').output.firstRow.ChangeCount\n    )\n,0)",
                        "type": "Expression"
                    },
                    "ifTrueActivities": [
                        {
                            "name": "IncrementalCopy",
                            "type": "Copy",
                            "dependsOn": [
                                {
                                    "activity": "SetWatermark",
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
                            "typeProperties": typePropertiesInputOutput(GenerateArm,GFPIR,SourceType, TargetType, TargetFormat, SQL_Statement2),
                            "inputs": (if(SourceType=="AzureSqlTable") then AzureSqlTable_NA_CopyActivity_Inputs(GenerateArm,GFPIR) else SqlServerTable_NA_CopyActivity_Inputs(GenerateArm,GFPIR)),
                            "outputs":(if(TargetType=="AzureBlobFS") then AzureBlobFS_Parquet_CopyActivity_Output(GenerateArm,GFPIR) else AzureBlobStorage_Parquet_CopyActivity_Output(GenerateArm,GFPIR))
                        },
                        {
                            "name": "SetWatermark",
                            "type": "SetVariable",
                            "dependsOn": [],
                            "userProperties": [],
                            "typeProperties": {
                                "variableName": "NewWatermark",
                                "value": {
                                    "value": "@activity('GetChangeCount').output.firstRow.to_lsn",
                                    "type": "Expression"
                                }
                            }
                        },
                        {
                            "name": "AF Persist Parquet Metadata",
                            "type": "AzureFunctionActivity",
                            "dependsOn": [
                                {
                                    "activity": "Get Parquet Metadata",
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
                                "functionName": "TaskExecutionSchemaFile",
                                "method": "POST",
                                "body": {
                                    "value": "@json(\n concat(\n '{\"TaskInstanceId\":\"', \n string(pipeline().parameters.TaskObject.TaskInstanceId), \n '\",\"ExecutionUid\":\"', \n string(pipeline().parameters.TaskObject.ExecutionUid), \n '\",\"RunId\":\"', \n string(pipeline().RunId), \n '\",\"StorageAccountName\":\"', \n string(pipeline().parameters.TaskObject.Target.System.SystemServer), \n '\",\"StorageAccountContainer\":\"', \n string(pipeline().parameters.TaskObject.Target.System.Container), \n '\",\"RelativePath\":\"', \n string(pipeline().parameters.TaskObject.Target.Instance.TargetRelativePath), \n '\",\"SchemaFileName\":\"', \n string(pipeline().parameters.TaskObject.Target.SchemaFileName), \n '\",\"SourceType\":\"', \n string(pipeline().parameters.TaskObject.Source.System.Type), \n '\",\"TargetType\":\"', \n if(\n    contains(\n    string(pipeline().parameters.TaskObject.Target.System.SystemServer),\n    '.dfs.core.windows.net'\n    ),\n   'ADLS',\n   'Azure Blob'), \n '\",\"Data\":',\n string(activity('Get Parquet Metadata').output),\n ',\"MetadataType\":\"Parquet\"}')\n)",
                                    "type": "Expression"
                                }
                            },
                            "linkedServiceName": {
                                "referenceName": "SLS_AzureFunctionApp",
                                "type": "LinkedServiceReference"
                            }
                        },
                        {
                            "name": "Get Parquet Metadata",
                            "type": "GetMetadata",
                            "dependsOn": [
                                {
                                    "activity": "IncrementalCopy",
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
                            "typeProperties": GetTargetMetadata(GenerateArm,GFPIR,TargetType, TargetFormat)
                        },
                        {
                            "name": "AF Set New Watermark",
                            "type": "ExecutePipeline",
                            "dependsOn": [
                                {
                                    "activity": "AF Persist Parquet Metadata",
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
                                        "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"TaskMasterId\":\"', string(pipeline().parameters.TaskObject.TaskMasterId),'\",\"TaskMasterWaterMarkColumnType\":\"', 'lsn','\",\"WaterMarkValue\":\"', variables('NewWatermark'), '\"}'))",
                                        "type": "Expression"
                                    },
                                    "FunctionName": "WaterMark",
                                    "Method": "Post"
                                }
                            }
                        },
                        {
                            "name": "Pipeline AF Log - Copy Failed",
                            "type": "ExecutePipeline",
                            "dependsOn": [
                                {
                                    "activity": "IncrementalCopy",
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
                                        "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Copy SQL to Storage\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"Comment\":\"', encodeUriComponent(string(activity('IncrementalCopy').error.message)), '\",\"Status\":\"Failed\"}'))",
                                        "type": "Expression"
                                    },
                                    "FunctionName": "Log",
                                    "Method": "Post"
                                }
                            }
                        },
                        {
                            "name": "Pipeline AF Log - Copy Succeed",
                            "type": "ExecutePipeline",
                            "dependsOn": [
                                {
                                    "activity": "IncrementalCopy",
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
                                        "value": "@json(concat('{\"TaskInstanceId\":\"', string(pipeline().parameters.TaskObject.TaskInstanceId), '\",\"ExecutionUid\":\"', string(pipeline().parameters.TaskObject.ExecutionUid), '\",\"RunId\":\"', string(pipeline().RunId), '\",\"LogTypeId\":1,\"LogSource\":\"ADF\",\"ActivityType\":\"Copy SQL to Storage\",\"StartDateTimeOffSet\":\"', string(pipeline().TriggerTime), '\",\"EndDateTimeOffSet\":\"', string(utcnow()), '\",\"RowsInserted\":\"', string(activity('IncrementalCopy').output.rowsCopied), '\",\"Comment\":\"\",\"Status\":\"Complete\"}'))",
                                        "type": "Expression"
                                    },
                                    "FunctionName": "Log",
                                    "Method": "Post"
                                }
                            }
                        }
                    ]
                }
            }
        ],
        "parameters": {
            "TaskObject": {
                "type": "object",
                "defaultValue": {
                    "DegreeOfCopyParallelism": 1,
                    "Enabled": 1,
                    "ExecutionEngine": {
                        "ADFPipeline": "GPL_AzureSqlTable_NA_AzureBlobFS_Parquet_Azure",
                        "EngineId": -1,
                        "EngineJson": "{}",
                        "EngineName": "ark-stg-adf-ads-irud",
                        "ResourceGroup": "dlzdev04",
                        "SubscriptionId": "ed1206e0-17c7-4bc2-ad4b-f8d4dab9284f",
                        "SystemType": "Datafactory",
                        "TaskDatafactoryIR": "Azure"
                    },
                    "ExecutionUid": "8448eabb-9ba4-4779-865b-29e973431273",
                    "KeyVaultBaseUrl": "https://ads-dev-kv-ads-y56o.vault.azure.net",
                    "NumberOfRetries": 0,
                    "ScheduleMasterId": "-4",
                    "Source": {
                        "ChunkField": "",
                        "ChunkSize": 0,
                        "ExtractionSQL": "",
                        "IncrementalSQLStatement": "",
                        "IncrementalType": "CDC",
                        "Instance": {
                            "TargetRelativePath": ""
                        },
                        "SQLStatement": "/*Remove First*/-- DECLARE  @from_lsn binary(10), @to_lsn binary(10);\r\n /*Remove First*/-- SET @from_lsn =sys.fn_cdc_get_min_lsn((SELECT capture_instance FROM cdc.change_tables where source_object_id  = object_id('SalesLT.Product')));  \r\n /*Remove First*/-- SET @to_lsn = sys.fn_cdc_map_time_to_lsn('largest less than or equal',  GETDATE());\r\n /*Remove First*/--  SELECT CONVERT(varchar(max),@to_lsn,1) to_lsn,CONVERT(varchar(max),@from_lsn,1) from_lsn, count(*) ChangeCount FROM cdc.fn_cdc_get_all_changes_SalesLT_Product(@from_lsn, @to_lsn, N'all'); \r\n /*Remove Second*/-- SELECT * FROM cdc.fn_cdc_get_all_changes_SalesLT_Product(convert(binary(10),'/*from_lsn*/',1), convert(binary(10),'/*to_lsn*/',1), N'all');",
                        "System": {
                            "AuthenticationType": "WindowsAuth",
                            "Database": "Adventureworks",
                            "SystemId": -1,
                            "SystemServer": "(local)",
                            "Type": "Azure SQL",
                            "Username": "adminuser",
                            "PasswordKeyVaultSecretName": "selfhostedsqlpw"
                        },
                        "TableName": "Customer",
                        "TableSchema": "SalesLT",
                        "Type": "Table"
                    },
                    "Target": {
                        "DataFileName": "TestFile.parquet",
                        "Instance": {
                            "TargetRelativePath": ""
                        },
                        "RelativePath": "",
                        "SchemaFileName": "TestFile.json",
                        "System": {
                            "AuthenticationType": "MSI",
                            "Container": "datalakelanding",
                            "SystemId": -8,
                            "SystemServer": "https://adsdevdlsadsy56oblob.blob.core.windows.net/",
                            "Type": "Azure Blob",
                            "Username": null
                        },
                        "Type": "Parquet"
                    },
                    "TaskExecutionType": "ADF",
                    "TaskGroupConcurrency": "10",
                    "TaskGroupPriority": 0,
                    "TaskInstanceId": 1,
                    "TaskMasterId": 2,
                    "TaskStatus": "InProgress",
                    "TaskType": "SQL Database to Azure Storage"
                }
            }
        },
        "variables": {
            "NewWatermark": {
                "type": "String"
            },
            "SQLStatement1": {
                "type": "String"
            },
            "SQLStatement2": {
                "type": "String"
            }
        },
        "folder": {
            "name": Folder
        },
        "annotations": [],
        "lastPublishTime": "2022-03-27T00:15:57Z"
    },
    "type": "Microsoft.DataFactory/factories/pipelines"
};
Wrapper(GenerateArm,pipeline)+{}