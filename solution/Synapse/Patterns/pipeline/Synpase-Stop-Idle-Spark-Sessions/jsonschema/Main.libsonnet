local partials = {
    "Not-Applicable": import "Not-Applicable.libsonnet"
};


function(SourceType = "", SourceFormat = "Not-Applicable", TargetType = "", TargetFormat = "Not-Applicable")
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "title": "TaskMasterJson",
    "properties": {
        "SparkPoolName": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "TestPool"
                },
                "infoText": "(required) Use this field to define the name of the Synapse SQL Pool you are wanting to manipulate within your workspace."
            }
        },
        "Source": partials[SourceFormat](),
        "Target": partials[TargetFormat]()
    },
    "required": [
        "SparkPoolName"
    ]
}