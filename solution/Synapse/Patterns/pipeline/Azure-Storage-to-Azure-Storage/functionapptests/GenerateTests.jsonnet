function(seed=0)
local tests =
[
    //****************************************************************/
    //**                    Storage to Storage Tests                 */
    //****************************************************************/
    //GPL_AzureBlobFS_Binary_AzureBlobFS_Binary_FullLoad
    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.Customer*.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",
        
        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"SalesLT.Customer",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Disabled: Purview / CDCSource / SparkTableCreate - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.Customer*.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        
        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"SalesLT.Customer",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: SparkTableCreate | Disabled: Purview / CDCSource -",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Enabled",
        "SparkTableDBName": "TestDB",
        "SparkTableName": "TestTable",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.Customer*.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"SalesLT.Customer",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: Purview | Disabled: SparkTableCreate / CDCSource - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Enabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.CustomerCDCInit.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.CustomerCDCInit.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"CustomerCDCDeltaTest",
        "TargetSchemaFileName":"CustomerCDCDeltaTest.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: CDCSource | Disabled: SparkTableCreate / Purview - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Enabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.Customer*.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"SalesLT.Customer",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: SparkTableCreate / Purview | Disabled: CDCSource - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Enabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Enabled",
        "SparkTableDBName": "TestDB",
        "SparkTableName": "TestTable2",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.CustomerCDCEdit1.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.CustomerCDCEdit1.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",
        
        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"CustomerCDCDeltaTest",
        "TargetSchemaFileName":"CustomerCDCDeltaTest.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: SparkTableCreate / CDCSource | Disabled: Purview - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Enabled",
        "SparkTableCreate": "Enabled",
        "SparkTableDBName": "TestDB",
        "SparkTableName": "TestTable3",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.CustomerCDCEdit2.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.CustomerCDCEdit2.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"CustomerCDCDeltaTest",
        "TargetSchemaFileName":"CustomerCDCDeltaTest.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: Purview / CDCSource | Disabled: SparkTableCreate - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Enabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Enabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled"

       
    },

    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Parquet",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT.CustomerCDCEdit3.parquet",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.CustomerCDCEdit3.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",
        
        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"CustomerCDCDeltaTest",
        "TargetSchemaFileName":"CustomerCDCDeltaTest.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "parquet to delta - Enabled: Purview / CDCSource / SparkTableCreate - ",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

        "Purview": "Enabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Enabled",
        "SparkTableCreate": "Enabled",
        "SparkTableDBName": "TestDB",
        "SparkTableName": "TestTable4",
        "UseNotebookActivity": "Disabled"

       
    },



    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Delta",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT_Customer_Delta/SalesLT.Customer/",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",
        
        "TargetFormat":"Delta",
        "TargetType":"ADLS",        
        "TargetDataFilename":"DeltaTable/SalesLT.Customer",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "File copy between datalake zones - delta to delta",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure",

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled" 
       
    },


    {        
        "Active": true,        
        "Pattern": "Azure Storage to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Delta",
        "SourceType":"ADLS",        
        "SourceDataFilename":"SalesLT_Customer_Delta/SalesLT.Customer/",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"SalesLT.Customer*.json", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Parquet",
        "TargetType":"ADLS",        
        "TargetDataFilename":"SalesLT.Customer*.parquet",
        "TargetSchemaFileName":"SalesLT.Customer.json",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "Description": "File copy between datalake zones - delta to parquet",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure",

        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "CDCSource": "Disabled",
        "SparkTableCreate": "Disabled",
        "SparkTableDBName": "",
        "SparkTableName": "",
        "UseNotebookActivity": "Disabled"
       
    }

];

local template = import "./partials/functionapptest.libsonnet";

local process = function(index, t)
template(
    t.SynapsePipeline,
    t.Pattern, 
    seed-index,//t.TestNumber,
    t.SourceFormat,
    t.SourceType,
    t.SourceDataFilename,
    t.SourceSchemaFileName,
    t.SourceSourceSystemAuthType,
    t.SourceSkipLineCount,
    t.SourceFirstRowAsHeader,
    t.SourceSheetName,
    t.SourceMaxConcurrentConnections,
    t.SourceRecursively,
    t.SourceDeleteAfterCompletion,
    t.SourceWriteSchemaToPurview,
    t.TargetFormat,
    t.TargetType,
    t.TargetDataFilename,
    t.TargetSchemaFileName,
    t.TargetSourceSystemAuthType,
    t.TargetSkipLineCount,
    t.TargetFirstRowAsHeader,
    t.TargetSheetName,
    t.TargetMaxConcurrentConnections,
    t.TargetRecursively,
    t.TargetDeleteAfterCompletion,
    t.TargetWriteSchemaToPurview,
    t.Description,
    t.Purview,
    t.QualifiedIDAssociation,
    t.CDCSource,
    t.SparkTableCreate,
    t.SparkTableDBName,
    t.SparkTableName,
    t.UseNotebookActivity
);


std.mapWithIndex(process, tests)

