local commons = import '../../../static/partials/functionapptest_commons.libsonnet';
local vars = import '../../../static/partials/secrets.libsonnet';
function(
    SynapsePipeline = "GPL_SparkNotebookExecution_Azure",
    TestDescription = "",
    Pattern = "REST API to Azure Storage",
    TestNumber = "-1",
    SourceFormat = "Rest",
    SourceSystemId = 0,
    SourceType = "Rest",
    SourceSystemAuthType = "MSI",
    SourceRelativeUrl = "", 
    SourceRequestBody = "",
    SourceRequestMethod = "GET",
    TargetSystemAuthType = "MSI",
    TargetFormat = "Json",
    TargetType = "Json",
    TargetDataFilename = "Test.Json",
    TargetRelativePath = "",
    ExecuteNotebook = "RestAPINotebook",
    Purview = "Disabled",
    QualifiedIDAssociation = "TaskMasterId",
    UseNotebookActivity = "Enabled",
    PartitionSize = "Single",
    Pagination = "Disabled"
    )
{
    local TaskMasterJson =     
    {
        "ExecuteNotebook": ExecuteNotebook,
        "Purview": Purview,
        "QualifiedIDAssociation": QualifiedIDAssociation,
        "PartitionSize": PartitionSize,
        "UseNotebookActivity": UseNotebookActivity,       
        "Source":{
            "Type": SourceFormat,
            "RelativeUrl": SourceRelativeUrl,
            "RequestBody": SourceRequestBody,
            "RequestMethod": SourceRequestMethod,
            "Pagination": Pagination                                     
        },

        "Target":{
            "Type":TargetFormat,
            "RelativePath":"",
            "DataFileName": TargetDataFilename,

        },
    },

    local TaskInstanceJson =  
    {
        
    },

    local SourceSystemJson = 
    {
          
    },

    local TargetSystemJson = 
    {   
         
    },
             
    "TaskInstanceJson":std.manifestJson(TaskInstanceJson),
    "TaskTypeId":-9,
    "TaskType":Pattern,
    "EngineName":vars.datafactory_name,
    "EngineResourceGroup":vars.resource_group_name,
    "EngineSubscriptionId":vars.subscription_id,
    "EngineJson":  '{"endpoint": "https://' + vars.synapse_workspace_name + '.dev.azuresynapse.net", "DeltaProcessingNotebook": "DeltaProcessingNotebook"}',
    "TaskMasterJson":std.manifestJson(TaskMasterJson),       
    "TaskMasterId":TestNumber,
    "SourceSystemId": -17,
    "SourceSystemJSON":std.manifestJson(SourceSystemJson),
    "SourceSystemType":SourceType,
    "SourceSystemServer":"N/A",
    "SourceKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "SourceSystemAuthType":SourceSystemAuthType,
    "SourceSystemSecretName":"",
    "SourceSystemUserName":"",   
    "TargetSystemId": -8,
    "TargetSystemJSON":std.manifestJson(TargetSystemJson),
    "TargetSystemType":TargetType,
    "TargetSystemServer":"N/A",
    "TargetKeyVaultBaseUrl":"https://" + vars.keyvault_name +".vault.azure.net",
    "TargetSystemAuthType":TargetSystemAuthType,
    "TargetSystemSecretName":"",
	"TargetSystemUserName":"",
    "SynapsePipeline": SynapsePipeline,
    "TestDescription": "[" + TestNumber + "] " + TestDescription,
    "DependencyChainTag": ""
}+commons

