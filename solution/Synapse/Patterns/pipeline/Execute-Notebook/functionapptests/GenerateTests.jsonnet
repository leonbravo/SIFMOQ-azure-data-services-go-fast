function(seed=0)
local tests =
[
    //****************************************************************//
    //*                    Execute Notebook Tests                    *//
    //****************************************************************//
    {        
        "Active": true,        
        "Pattern": "Execute-Notebook",         
        "SourceSystemAuthType": "MSI",
        
        "SourceFormat":"Notebook-Optional",
        "SourceType":"N/A",        
        "SourceDataFilename":"",
        "SourceSourceSystemAuthType": "MSI",
        "SourceSchemaFileName":"", 
        "SourceSkipLineCount":"",
        "SourceFirstRowAsHeader": "false",
        "SourceSheetName":"",
        "SourceMaxConcurrentConnections":0,
        "SourceRecursively":"false",
        "SourceDeleteAfterCompletion":"false",
        "SourceWriteSchemaToPurview": "Disabled",

        "TargetFormat":"Notebook-Optional",
        "TargetType":"N/A",        
        "TargetDataFilename":"",
        "TargetSchemaFileName":"",
        "TargetSourceSystemAuthType":"MSI", 
        "TargetSkipLineCount":"",
        "TargetFirstRowAsHeader": "false",
        "TargetSheetName":"",
        "TargetMaxConcurrentConnections":0,
        "TargetRecursively":"false",
        "TargetDeleteAfterCompletion":"false",
        "TargetWriteSchemaToPurview": "Disabled",

        "ExecuteNotebook": "SampleNotebook",
        "CustomDefinitions": "",
        "Description": "Execute Notebook test - by default this execute the SampleNotebook provided within the synapse deployment.",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure",
        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId", 
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
    t.ExecuteNotebook,
    t.CustomDefinitions,
    t.Purview,
    t.QualifiedIDAssociation, 
    t.UseNotebookActivity
);


std.mapWithIndex(process, tests)

