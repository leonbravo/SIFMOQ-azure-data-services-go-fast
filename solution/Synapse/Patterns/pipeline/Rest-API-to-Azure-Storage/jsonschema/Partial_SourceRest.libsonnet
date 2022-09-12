function() 
{
    "type": "object",
    "properties": {
        "Type": {
            "type": "string",                    
            "enum": [
                "Rest"
            ],
            "options": {
                "hidden":true,
            },
            "default":"Rest"
        },
        "RelativeUrl": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "eg. /users"
                }, 
                "infoText": "(required) The relative URL of the API base URL you wish to use. This is amended to the base URL that is stored in the source system selected."
            },
            "default":""
        },
        "RequestMethod": {
            "type": "string",
            "default": "GET",
            "enum": [
                "GET",
                "POST"
            ],
            "options": {
                "infoText": "(required) This is the Request Method you wish to use for the API request. A GET request will not require a Request Body but other selections will"
            }
        },
        "Pagination": {
            "type": "string",
            "default": "Disabled",
            "enum": [
                "NextPageUrlKey",
                "Disabled"
            ],
            "options": {
                "infoText": "(required)WARNING: This is still experimental and is hard to generalise, you may want to use the example in the RestAPINotebook and modify it to fit your use case. Currently, it only supports NextPageUrlKey which is defined in the SourceAndTargetSystem SystemJSON."
            }
        },    
        "RequestBody": {
            "type": "string",
            "options": {                        
                "inputAttributes": {
                    "placeholder": ""
                }, 
                "infoText": "(optional) The request body being used for the request method chosen. Note: A GET RequestBody will not use this."
            },
            "default":""
        },
    },
    "required": [
        "RelativeUrl",
        "RequestMethod",
        "Pagination"
    ]
 
}