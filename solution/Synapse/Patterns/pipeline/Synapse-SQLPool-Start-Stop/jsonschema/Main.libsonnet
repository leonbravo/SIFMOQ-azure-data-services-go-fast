local partials = {
    "Not-Applicable": import "Not-Applicable.libsonnet"
};


function(SourceType = "", SourceFormat = "Not-Applicable", TargetType = "", TargetFormat = "Not-Applicable")
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "title": "TaskMasterJson",
    "properties": {
        "SQLPoolName": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "TestPool"
                },
                "infoText": "(required) Use this field to define the name of the Synapse SQL Pool you are wanting to manipulate within your workspace."
            }
        },
        "SQLPoolOperation": {
            "type": "string",
            "enum": [
                "Start",
                "Pause"
            ],
            "options": {
                "infoText": "(required) Use this field to select whether you would like to start or pause the SQLPool you have defined."
            },
        },
        "Source": partials[SourceFormat](),
        "Target": partials[TargetFormat]()
    },
    "required": [
        "SQLPoolName",
        "SQLPoolOperation"
    ]
}