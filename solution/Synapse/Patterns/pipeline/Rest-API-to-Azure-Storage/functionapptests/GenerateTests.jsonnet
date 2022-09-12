function(seed=0)
local tests =
[
    //****************************************************************//
    //*                    Execute Notebook Tests                    *//
    //****************************************************************//
        {        
        "Active": true,        
        "Pattern": "REST API to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        "TargetSystemAuthType": "MSI",

        "SourceFormat":"Rest",
        "SourceType":"Rest",
        "SourceRelativeUrl": "/facts?limit=50",
        "SourceRequestBody": "",
        "SourceRequestMethod": "GET",
        "SourceSystemId": -17,


        "TargetFormat":"Json",
        "TargetType":"ADLS",        
        "TargetDataFilename": "TestNoAuthGet.json",
        "TargetRelativePath": "",

        "ExecuteNotebook": "RestAPINotebook",
        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "UseNotebookActivity": "Enabled",
        "PartitionSize": "Single",

        "Description": "Rest to Storage - No Auth GET no Headers",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

    },

    {        
        "Active": true,        
        "Pattern": "REST API to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        "TargetSystemAuthType": "MSI",

        "SourceFormat":"Rest",
        "SourceType":"Rest",
        "SourceRelativeUrl": "/users/2244994945/tweets?tweet.fields=created_at&max_results=100&start_time=2019-01-01T17:00:00Z&end_time=2020-12-12T01:00:00Z",
        "SourceRequestBody": "",
        "SourceRequestMethod": "GET",
        "SourceSystemId": -18,


        "TargetFormat":"Json",
        "TargetType":"ADLS",        
        "TargetDataFilename": "TestTwitterGet.json",
        "TargetRelativePath": "",

        "ExecuteNotebook": "RestAPINotebook",
        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "UseNotebookActivity": "Enabled",
        "PartitionSize": "Single",

        "Description": "Rest to Storage - Twitter GET use headers AUTH",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

    },

    {        
        "Active": true,        
        "Pattern": "REST API to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        "TargetSystemAuthType": "MSI",

        "SourceFormat":"Rest",
        "SourceType":"Rest",
        "SourceRelativeUrl": "/contacts/v1/contact/",
        "SourceRequestBody": "{ \"properties\": [ { \"property\": \"email\", \"value\": \"testingapiPOST@hubspot.com\" }, { \"property\": \"firstname\", \"value\": \"Adrian\" }, { \"property\": \"lastname\", \"value\": \"Mott\" }, { \"property\": \"website\", \"value\": \"http://hubspot.com\" }, { \"property\": \"company\", \"value\": \"HubSpot\" }, { \"property\": \"phone\", \"value\": \"555-122-2323\" }, { \"property\": \"address\", \"value\": \"25 First Street\" }, { \"property\": \"city\", \"value\": \"Cambridge\" }, { \"property\": \"state\", \"value\": \"MA\" }, { \"property\": \"zip\", \"value\": \"02139\" } ] }",
        "SourceRequestMethod": "POST",
        "SourceSystemId": -19,


        "TargetFormat":"Json",
        "TargetType":"ADLS",        
        "TargetDataFilename": "TestHubSpotPOST.json",
        "TargetRelativePath": "",

        "ExecuteNotebook": "RestAPINotebook",
        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "UseNotebookActivity": "Enabled",
        "PartitionSize": "Single",

        "Description": "Rest to Storage - HubSpot POST use headers AUTH - Note: Will require auth / no identity (Email Value) already made",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

    },

    {        
        "Active": true,        
        "Pattern": "REST API to Azure Storage",         
        "SourceSystemAuthType": "MSI",
        "TargetSystemAuthType": "MSI",

        "SourceFormat":"Rest",
        "SourceType":"Rest",
        "SourceRelativeUrl": "/me?access_token=$InsertSecret($KeyVault(ark-stg-kv-ads-xjp4).$SecretName(MetaKey2).$LinkedServiceName(SLS_AzureKeyVault))$END",
        "SourceRequestBody": "",
        "SourceRequestMethod": "GET",
        "SourceSystemId": -20,


        "TargetFormat":"Json",
        "TargetType":"ADLS",        
        "TargetDataFilename": "TestAuthInHeader.json",
        "TargetRelativePath": "",

        "ExecuteNotebook": "RestAPINotebook",
        "Purview": "Disabled",
        "QualifiedIDAssociation": "TaskMasterId",
        "UseNotebookActivity": "Enabled",
        "PartitionSize": "Single",

        "Description": "Rest to Storage - META GET use Auth in Relative URL",  
        "SynapsePipeline": "GPL_SparkNotebookExecution_Primary_Azure", 

    }

];

local template = import "./partials/functionapptest.libsonnet";

local process = function(index, t)
template(
    t.SynapsePipeline,
    t.Description,
    t.Pattern, 
    seed-index,//t.TestNumber,
    t.SourceFormat,
    t.SourceSystemId,
    t.SourceType,
    t.SourceSystemAuthType,
    t.SourceRelativeUrl,
    t.SourceRequestBody,
    t.SourceRequestMethod,
    t.TargetSystemAuthType,
    t.TargetFormat,
    t.TargetType,
    t.TargetDataFilename,
    t.TargetRelativePath,
    t.ExecuteNotebook,
    t.Purview,
    t.QualifiedIDAssociation, 
    t.UseNotebookActivity,
    t.PartitionSize
);


std.mapWithIndex(process, tests)

