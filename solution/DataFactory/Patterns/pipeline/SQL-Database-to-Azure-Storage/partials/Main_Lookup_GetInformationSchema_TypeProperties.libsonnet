function(GenerateArm="false",GFPIR="IRA", SourceType="AzureSqlTable")
if (SourceType=="AzureSqlTable") then
{
  local referenceName = "GDS_AzureSqlTable_NA_",
  "source": {
    "type": "AzureSqlSource",
    "sqlReaderQuery": {
      "value": "@activity('AF Get Information Schema SQL').output.InformationSchemaSQL",
      "type": "Expression"
    },
    "queryTimeout": "02:00:00",
    "partitionOption": "None"
  },
  "dataset": {    
    "referenceName":if(GenerateArm=="false") 
                    then referenceName + GFPIR
                    else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",   
    "type": "DatasetReference",
    "parameters": {
      "Schema": {
        "value": "@pipeline().parameters.TaskObject.Source.TableSchema",
        "type": "Expression"
      },
      "Table": {
        "value": "@pipeline().parameters.TaskObject.Source.TableName",
        "type": "Expression"
      },
      "Server": {
        "value": "@pipeline().parameters.TaskObject.Source.System.SystemServer",
        "type": "Expression"
      },
      "Database": {
        "value": "@pipeline().parameters.TaskObject.Source.System.Database",
        "type": "Expression"
      }
    }
  },
  "firstRowOnly": false
}
else if (SourceType=="SqlServerTable") then
{
  local referenceName = "GDS_SqlServerTable_NA_",
  "source": {
    "type": "SqlServerSource",
    "sqlReaderQuery": {
      "value": "@activity('AF Get Information Schema SQL').output.InformationSchemaSQL",
      "type": "Expression"
    },
    "queryTimeout": "02:00:00",
    "partitionOption": "None"
  },
  "dataset": {    
    "referenceName":if(GenerateArm=="false") 
                    then referenceName + GFPIR
                    else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",   
    "type": "DatasetReference",
    "parameters": {
      "TableSchema": {
        "value": "@pipeline().parameters.TaskObject.Source.TableSchema",
        "type": "Expression"
      },
      "TableName": {
        "value": "@pipeline().parameters.TaskObject.Source.TableName",
        "type": "Expression"
      },
      "KeyVaultBaseUrl": {
        "value": "@pipeline().parameters.TaskObject.KeyVaultBaseUrl",
        "type": "Expression"
      },
      "PasswordSecret": {
        "value": "@pipeline().parameters.TaskObject.Source.System.PasswordKeyVaultSecretName",
        "type": "Expression"
      },
      "Server": {
        "value": "@pipeline().parameters.TaskObject.Source.System.SystemServer",
        "type": "Expression"
      },
      "Database": {
        "value": "@pipeline().parameters.TaskObject.Source.System.Database",
        "type": "Expression"
      },
      "UserName": {
        "value": "@pipeline().parameters.TaskObject.Source.System.Username",
        "type": "Expression"
      }
    }
  },
  "firstRowOnly": false
}
else if (SourceType=="OracleServerTable") then
{
  local referenceName = "GDS_OracleServerTable_NA_",
  "source": {
    "type": "OracleSource",
    "oracleReaderQuery": {
      "value": "@activity('AF Get Information Schema SQL').output.InformationSchemaSQL",
      "type": "Expression"
    },
    "queryTimeout": "02:00:00",
    "partitionOption": "None"
  },
  "dataset": {    
    "referenceName":if(GenerateArm=="false") 
                    then referenceName + GFPIR
                    else "[concat('"+referenceName+"', parameters('integrationRuntimeShortName'))]",   
    "type": "DatasetReference",
    "parameters": {
        "Host": {
            "value": "@pipeline().parameters.TaskObject.SystemServer",
            "type": "Expression"
        },
        "Port": {
            "value": "@pipeline().parameters.TaskObject.Source.System.Port",
            "type": "Expression"
        },
        "ServiceName": {
            "value": "@pipeline().parameters.TaskObject.Source.System.ServiceName",
            "type": "Expression"
        },
        "UserName": {
            "value": "@pipeline().parameters.TaskObject.UserName",
            "type": "Expression"
        },
        "KeyVaultBaseUrl": {
            "value": "@pipeline().parameters.TaskObject.KeyVaultBaseUrl",
            "type": "Expression"
        },
        "Secret": {
            "value": "@pipeline().parameters.TaskObject.SystemSecretName",
            "type": "Expression"
        },
        "TableSchema": {
            "value": "@pipeline().parameters.TaskObject.Source.TableSchema",
            "type": "Expression"
        },
        "TableName": {
            "value": "@pipeline().parameters.TaskObject.Source.TableName",
            "type": "Expression"
        }
    }
  },
  "firstRowOnly": false
}
else
  error 'GetInformationSchema.libsonnet failed. No mapping for:' +GFPIR+","+SourceType