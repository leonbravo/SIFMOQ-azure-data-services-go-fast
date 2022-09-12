function() 
{
  
            "type": "object",
            "properties": {
                "Type": {
                    "type": "string",                    
                    "enum": [
                        "NA"
                    ],
                    "options": {
                        "hidden":true,
                    },
                    "default":"NA"

                },               
                "TableSchema": {
                    "type": "string",
                    "options": {
                        "inputAttributes": {
                            "placeholder": "eg. dbo"
                        }, 
                        "infoText": "(optional) The schema of the table to extract."
                    },
                    "default":""

                },
                "TableName": {
                    "type": "string",
                    "options": {                        
                        "inputAttributes": {
                            "placeholder": "eg. Customer"
                        }, 
                        "infoText": "(optional) The name of the table to extract."
                    },
                    "default":""
                },
            },
            "required": [
                "Type"                
            ]
 
}