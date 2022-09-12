function() 
{
            "type": "object",
            "properties": {
                "Type": {
                    "type": "string",                    
                    "enum": [
                        "Json"
                    ], 
                    "options":{
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
                            "placeholder": "eg. Customer.xlsx"
                        },
                        "infoText": "(required) Name of the file to be imported."
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
                },
                "JsonTranslator": {
                    "type": "object",             
                    "properties": {
                        "type": {
                            "type": "string",                                                   
                            "options":{
                                "hidden": true
                            },
                            "default": "TabularTranslator"      
                        },
                        "mappings": {
                            "type": "array",
                            "items": {
                                "type": "object",
                                "properties": {
                                    "source":{
                                        "type": "object",
                                        "properties": {
                                            "path": {
                                                "type":"string",
                                                "default":"",
                                                "options": {                        
                                                    "infoText": "(required) The json path that points to this column"
                                                } 
                                            } 
                                        },
                                        "required": [
                                            "path"                                         
                                        ]
                                    },
                                    "sink":{
                                        "type": "object",
                                        "properties": {
                                            "name": {
                                                "type":"string",
                                                "default":"",
                                                "options": {                        
                                                    "infoText": "(required) The type of the column that data will be loaded into."
                                                } 
                                            },
                                            "type": {
                                                "type":"string",
                                                "default":"",
                                                "options": {                        
                                                    "infoText": "(required) The name of the column that data will be loaded into"
                                                } 
                                            }  
                                        },
                                        "required": [
                                            "name",
                                            "type"                                       
                                        ]
                                    }                                    
                                },
                                "required": [
                                    "source",
                                    "sink"                                       
                                ]
                            }                          
                        },
                        "collectionReference": {
                            "type": "string",                                                                               
                            "default": "",                    
                            "options": {                        
                                "infoText": "(required) The json path that represents the array to be imported / processed."
                            }   
                        },
                        "mapComplexValuesToString": {
                            "type": "boolean",                                                                               
                            "default": false      
                        }
                    },
                    "required": [
                        "type",
                        "mappings",                                       
                        "collectionReference",
                        "mapComplexValuesToString"
                    ]
                },
                "MaxConcurrentConnections": {
                    "type": "integer",
                    "default": 10,                                       
                    "options": {                        
                        "infoText": ""
                    }
                }
            },
            "required": [
                "Type",
                "RelativePath",
                "DataFileName",
                "SchemaFileName",
                "MaxConcurrentConnections"
            ]
        
}