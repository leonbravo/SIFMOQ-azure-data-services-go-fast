function() 
{
    "type": "object",
    "properties": {
        "Type": {
            "type": "string",                    
            "enum": [
                "Anonymous"
            ],
            "options": {
                "hidden":true,
            },
            "default":"Anonymous"
        },
        "RelativeUrl": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "eg. /users"
                }, 
                "infoText": "The relative URL of the API base URL you wish to use. This is amended to the base URL that is stored in the source system selected."
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
                "infoText": "This is the Request Method you wish to use for the API request. A GET request will not require a Request Body but other selections will."
            }
        },  
        "RequestBody": {
            "type": "string",
            "options": {                        
                "inputAttributes": {
                    "placeholder": ""
                }, 
                "infoText": "The request body being used for the request method chosen. Note: A GET RequestBody will be blank."
            },
            "default":""
        },
        "PaginationRules": {
            "type": "string",
            "options": {                        
                "inputAttributes": {
                    "placeholder": ""
                }, 
                "infoText": "Any Pagination rules to be added to the REST request. Note: This can be left blank."
            },
            "default":""
        },
        "AdditionalHeaders": {
            "type": "string",
            "options": {                        
                "inputAttributes": {
                    "placeholder": ""
                }, 
                "infoText": "Any additional headers to be added to the REST request. Note: This can be left blank."
            },
            "default":""
        },
    },
    "required": [
        "RelativeUrl",
        "RequestMethod"
    ]
 
}