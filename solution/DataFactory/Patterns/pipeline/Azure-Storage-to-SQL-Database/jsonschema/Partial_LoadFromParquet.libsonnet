function()
{
            "type": "object",
            "properties": {
                "Type": {
                    "type": "string",
                    "enum": [
                        "Parquet"
                    ],
                    "options": {
                        "hidden": true
                    }
                },
                "RelativePath": {
                    "type": "string",
                    "options": {
                        "inputAttributes": {
                            "placeholder": "eg. AwSample/dbo/Customer/{yyyy}/{MM}/{dd}/{hh}/"
                        },
                        "infoText": "(optional) Path of the file to be imported."
                    }
                },
                "DataFileName": {
                    "type": "string",
                    "options": {
                        "inputAttributes": {
                            "placeholder": "eg. Customer.parquet"
                        },
                        "infoText": "(required) Name of the file to be imported."
                    }
                },
                "DataFileNameChunkPostfix": {
                    "type": "string",
                    "enum": [
                        "Enabled",
                        "Disabled"
                    ],
                    "default": "Enabled",
                    "options": {                        
                        "infoText": "(required) When Enabled the import task will assume that the incoming file name has a chunk identifier at the end of the file name (eg. Customer.chunk1.parquet)"
                    }
                },
                "SchemaFileName": {
                    "type": "string",             
                    "options": {
                        "inputAttributes": {
                            "placeholder": "eg. Customer_Schema.json"
                        },
                        "infoText": "(required) Name of the schema file to use when generating the target table. *Note that if you do not provide a schema file then the schema will be automatically inferred based on the source data."
                    }
                }
            },
            "required": [
                "Type",
                "RelativePath",
                "DataFileName",
                "DataFileNameChunkPostfix",
                "SchemaFileName"
            ]
 
}