function(SourceType = "AzureBlobStorage")	
{
    "type": "%(SourceType)sReadSettings" % {SourceType:SourceType},
    "recursive": false,                            
    "wildcardFolderPath": {
                                "value": "@pipeline().parameters.TaskObject.Source.Instance.SourceRelativePath",
                                "type": "Expression"
                            },
    "wildcardFileName": {
                                "value": "@if(\n    equals(\n        pipeline().parameters.TaskObject.Source.DataFileNameChunkPostfix,\n        'Enabled'\n        ),\n    concat(\n    replace(\n        pipeline().parameters.TaskObject.Source.DataFileName,\n        '.parquet',\n        ''\n        ),\n    '.*.parquet'\n    ),\n    pipeline().parameters.TaskObject.Source.DataFileName\n)",
                                "type": "Expression"
                            },
    "enablePartitionDiscovery": false        
}