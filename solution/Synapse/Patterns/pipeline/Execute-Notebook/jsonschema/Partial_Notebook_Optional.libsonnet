function()
 {
    "type": "object",
    "properties": {
        "Type": {
            "type": "string",
            "enum": [
                "Notebook-Optional"
            ],
            "options": {
                "hidden": true
            }
        },
        "WriteSchemaToPurview": {
            "type": "string",
            "default": "Disabled",
            "enum": [
                "Enabled",
                "Disabled"
            ],
            "options": {
                "infoText": "(required) Use this if you wish to push metadata about your schema from this task to Purview. Note: It is advise to only use this after resources have been initially scanned."
            },
        },
        "RelativePath": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "Note: This field is completely optional to use for values to place into the TaskObject passed into the Notebook."
                },
                "infoText": "(optional) Path of the folder holding the file to be imported/exported."
            }
        },
        "DataFileName": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "Note: This field is completely optional to use for values to place into the TaskObject passed into the Notebook."
                },
                "infoText": "(optional) Name of the file to be imported."
            }
        },
        "SchemaFileName": {
            "type": "string",             
            "options": {
                "inputAttributes": {
                    "placeholder": "Note: This field is completely optional to use for values to place into the TaskObject passed into the Notebook."
                },
                "infoText": "(optional) Name of the schema file to use when generating the target table."
            }
        } 
    },
    "required": [
        "WriteSchemaToPurview"
    ]
}