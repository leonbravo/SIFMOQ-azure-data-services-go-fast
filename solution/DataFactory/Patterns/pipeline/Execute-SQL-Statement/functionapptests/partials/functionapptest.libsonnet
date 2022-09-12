local commons = import '../../../static/partials/functionapptest_commons.libsonnet';
local vars = import '../../../static/partials/secrets.libsonnet';
function(
    ADFPipeline = "",
    Pattern = "SQL Database to Azure Storage",
    TestNumber = "-1",
    SourceFormat = "NA",
    SourceType = "Azure SQL",
    SourceTableName = "",
    SourceTableSchema = "",
    SQLStatement = "",
    QueryTimeout = "",    
    SourceSystemAuthType = "MSI",
    TargetFormat = "NA",
    TargetType = "Azure Blob",    
    TargetTableName = "",
    TargetTableSchema = "",
    TestDescription = "",
    TaskDatafactoryIR = ""
    )
{
    local TaskMasterJson =     
    {
        "Source":{
            "Type": SourceFormat,
            "TableName": SourceTableName,
            "TableSchema": SourceTableSchema

        },
        "Target":{
            "Type":TargetFormat,
            "TableName": TargetTableName,
            "TableSchema":TargetTableSchema
        },
        "SQLStatement": "drop table if exists dbo.[ExecuteSQLTest-26]; Select * into dbo.[ExecuteSQLTest-26] from ( values (1 , 2) ) a(col1,col2); Select 1;",
        "QueryTimeout": QueryTimeout,
    },

    local TaskInstanceJson =  
    {        
    },

    local SourceSystemJson = 
    {
        "Database": vars.sampledb_name,
        "UsernameKeyVaultSecretName":"",
        "PasswordKeyVaultSecretName":""        
    },

    local TargetSystemJson = 
    {
        "Container" : "datalakeraw" 
    },
             
    "TaskInstanceJson":std.manifestJson(TaskInstanceJson),
    "TaskType":Pattern,
    "TaskTypeId":-8,
    "EngineName":vars.datafactory_name,
    "EngineResourceGroup":vars.resource_group_name,
    "EngineSubscriptionId":vars.subscription_id,
    "EngineJson":  "{}",
    "TaskMasterJson":std.manifestJson(TaskMasterJson),       
    "TaskMasterId":TestNumber,
    "SourceSystemId":if(SourceType == "Azure SQL") then -1 else if(SourceType == "Azure Synapse") then -10 else if(SourceType == "SQL Server") then -14 else -6,
    "SourceSystemJSON":std.manifestJson(SourceSystemJson),
    "SourceSystemType":SourceType,
    "SourceSystemServer":vars.sqlserver_name + ".database.windows.net",
    "SourceKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "SourceSystemAuthType":SourceSystemAuthType,
    "SourceSystemSecretName":"",
    "SourceSystemUserName":"",   
    "TargetSystemId":if(TargetType == "Azure SQL") then -1 else if(TargetType == "Azure Synapse") then -10 else if(TargetType == "SQL Server") then -14 else -6,
    "TargetSystemJSON":std.manifestJson(TargetSystemJson),
    "TargetSystemType":TargetType,
    "TargetSystemServer":vars.sqlserver_name + ".database.windows.net",
    "TargetKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "TargetSystemAuthType":"MSI",
    "TargetSystemSecretName":"",
	"TargetSystemUserName":"",    
    "ADFPipeline": ADFPipeline,
    "TestDescription": "[" + TestNumber + "] " +  " " + TestDescription,
    "TaskDatafactoryIR": if(TaskDatafactoryIR == null) then "Azure" else TaskDatafactoryIR,
    "DependencyChainTag": ""
}+commons

