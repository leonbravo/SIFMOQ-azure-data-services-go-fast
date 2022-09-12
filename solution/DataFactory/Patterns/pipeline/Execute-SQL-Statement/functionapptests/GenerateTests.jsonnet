function(seed=0)
local tests =
[
    {
        "Active": true,        
        "Pattern": "Execute SQL Statement",         
        "SourceFormat":"NA",
        "SourceType":"Azure SQL",
        "SourceTableName": "ExecuteSQLTest",
        "SourceTableSchema": "dbo",
        "SQLStatement":"drop table if exists dbo.[ExecuteSQLTest@<1>]; Select * into dbo.[ExecuteSQLTest@<1>] from ( values (1 , 2) ) a(col1,col2); Select 1;",
        "QueryTimeout": "02:00:00",
        "SourceSystemAuthType": "MSI",
        "TargetFormat":"NA",
        "TargetType": "Azure SQL", 
        "TargetTableName": "ExecuteSQLTest",
        "TargetTableSchema": "dbo",
        "ADFPipeline": "GPL_AzureSqlTable_NA_AzureSqlTable_ExecuteSql", 
        "Description": "Execute SQL",        
        "TaskDatafactoryIR":"Azure"
    } 
];

local template = import "./partials/functionapptest.libsonnet";

local process = function(index, t)
template(
    t.ADFPipeline,
    t.Pattern, 
    seed-index,//t.TestNumber,
    t.SourceFormat,
    t.SourceType,
    t.SourceTableName+std.toString(seed-index),
    t.SourceTableSchema,
    std.strReplace(t.SQLStatement,"@<1>",std.toString(seed-index)),
    t.QueryTimeout,   
    t.SourceSystemAuthType,
    t.TargetFormat,
    t.TargetType,   
    t.TargetTableName+std.toString(seed-index),
    t.TargetTableSchema,
    t.Description,
    t.TaskDatafactoryIR
);


std.mapWithIndex(process, tests)
