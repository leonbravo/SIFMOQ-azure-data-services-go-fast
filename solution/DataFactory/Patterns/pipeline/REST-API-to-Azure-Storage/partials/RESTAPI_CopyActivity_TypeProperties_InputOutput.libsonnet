function(GenerateArm="false",GFPIR="IRA", SourceType="Rest", TargetType="AzureBlobFS",TargetFormat="Json") 
if(SourceType=="Rest"&&TargetType=="AzureBlobFS"&&TargetFormat=="Json") then
{
  "source": {
      "type": "RestSource",
      "httpRequestTimeout": "00:01:40",
      "requestInterval": "00.00:00:00.010"
  },
  "sink": {
      "type": "JsonSink",
      "storeSettings": {
          "type": "AzureBlobFSWriteSettings",
          "copyBehavior": "PreserveHierarchy"
      },
      "formatSettings": {
          "type": "JsonWriteSettings"
      }
  },
  "enableStaging": false,
  "parallelCopies": {
      "value": "@pipeline().parameters.TaskObject.DegreeOfCopyParallelism",
      "type": "Expression"
  }
} 
else if(SourceType=="Rest"&&TargetType=="AzureBlobStorage"&&TargetFormat=="Json") then
{
  "source": {
      "type": "RestSource",
      "httpRequestTimeout": "00:01:40",
      "requestInterval": "00.00:00:00.010"
  },
    "sink": {
        "type": "JsonSink",
        "storeSettings": {
            "type": "AzureBlobStorageWriteSettings",
            "copyBehavior": "PreserveHierarchy"
        },
        "formatSettings": {
            "type": "JsonWriteSettings"
        }
    },
    "enableStaging": false,
    "parallelCopies": {
        "value": "@pipeline().parameters.TaskObject.DegreeOfCopyParallelism",
        "type": "Expression"
    }
}
else 
  error 'CopyActivity_TypeProperties.libsonnet Failed: ' + GFPIR+","+SourceType+","+TargetType+","+TargetFormat