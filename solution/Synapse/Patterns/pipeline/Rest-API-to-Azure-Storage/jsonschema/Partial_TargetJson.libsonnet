function()
{
      
    "type": "object",
    "properties": {
        "Type": {
            "type": "string",                   
            "enum": [
                "Json"
            ],
            "options": {
                "hidden":true,
                "infoText": "Presently only Json is supported"
            }
        },
        "RelativePath": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "AwSample/dbo/Customer/{yyyy}/{MM}/{dd}/{hh}/"
                },
                "infoText": "(optional) The path of the directory into which you want your extracted data to be written. You can use placeholders such (eg. {yyyy}/{MM}/{dd}/{hh}/). "
            }
        },
        "DataFileName": {
            "type": "string",
            "options": {
                "inputAttributes": {
                    "placeholder": "dbo.Customer.parquet"
                },
                "infoText": "(required) Name of the file that will hold the extracted data"
            }
        },
        "PartitionSize": {
            "type": "string",
            "default": "Multiple",
            "enum": [
                "Single",
                "Multiple"
            ],
            "options": {
                "infoText": "(optional) This is used to decide whether the spark cluster will save the file as multiple parts or use a single partition to save them as a single part. WARNING: This can affect performance on larger sets of data."
            }
        }
    },
    "required": [
        "Type",
        "RelativePath",
        "DataFileName"
     ]

}