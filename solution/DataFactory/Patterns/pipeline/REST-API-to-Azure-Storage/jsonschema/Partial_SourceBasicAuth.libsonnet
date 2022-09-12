function() 
{
    "type": "object",
    "properties": {
        "Type": {
            "type": "string",                    
            "enum": [
                "Basic"
            ],
            "options": {
                "hidden":true,
            },
            "default":"Basic"
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
                "infoText": "This is the Request Method you wish to use for the API request. A GET request will not require a Request Body but other selections will"
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
    },
    "required": [
        "RelativeUrl",
        "RequestMethod"
    ]
 
}