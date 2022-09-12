function() 
{
  
            "type": "object",
            "properties": {
                "Type": {
                    "type": "string",                    
                    "enum": [
                        "Table"
                    ],
                    "options": {
                        "hidden":true,
                    },
                    "default":"Table"

                },
                "IncrementalType": {
                    "type": "string",
                    "description": "(required) Full Extraction or Incremental based on a Watermark Column",
                    "enum": [
                        "Watermark"
                    ],
                    "options": {
                        "hidden":true,
                    },
                    "default":"Watermark"
                },
                "TableSchema": {
                    "type": "string",
                    "options": {
                        "inputAttributes": {
                            "placeholder": "eg. dbo"
                        }, 
                        "infoText": "(required) The schema of the table to extract."
                    },
                    "default":""

                },
                "TableName": {
                    "type": "string",
                    "options": {                        
                        "inputAttributes": {
                            "placeholder": "eg. Customer"
                        }, 
                        "infoText": "(required) The name of the table to extract."
                    },
                    "default":""
                },
            },
            "required": [
                "Type",
                "IncrementalType"
            ]
 
}