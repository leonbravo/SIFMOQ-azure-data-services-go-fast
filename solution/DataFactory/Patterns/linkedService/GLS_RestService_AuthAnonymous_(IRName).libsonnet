function(shortIRName = "", fullIRName = "")
{
    "name": "GLS_RestService_AuthAnonymous_" + shortIRName,
    "type": "Microsoft.DataFactory/factories/linkedservices",
    "properties": {
        "connectVia": {
            "referenceName": fullIRName,
            "type": "IntegrationRuntimeReference"
        },
        "description": "Generic Anonymous Rest Connection",
        "parameters": {
            "BaseUrl": {
                "type": "String",
                "defaultValue": ""
            }
        },
        "type": "RestService",
        "typeProperties": {
            "url": "@{linkedService().BaseUrl}",
            "enableServerCertificateValidation": true,
            "authenticationType": "Anonymous"
        },
        "annotations": []
    }
}