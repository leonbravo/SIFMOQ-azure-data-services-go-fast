local partials = {
    "Anonymous": import "Partial_SourceAnonymousAuth.libsonnet",
    "Basic": import "Partial_SourceBasicAuth.libsonnet",
    "ServicePrincipal": import "Partial_SourceServicePrincipalAuth.libsonnet",
    "OAuth2": import "Partial_SourceOAuth2Auth.libsonnet",
    "Json": import "Partial_TargetJson.libsonnet",   
};


function(SourceType = "Rest", SourceFormat = "Anonymous",TargetType = "", TargetFormat = "Json")
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "title": "TaskMasterJson",
    "properties": {
        "Source": partials[SourceFormat](),
        "Target": partials[TargetFormat]()
    },
    "required": [
        "Source",
        "Target"
    ]
}