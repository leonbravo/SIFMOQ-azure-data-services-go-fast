UPDATE [dbo].[SourceAndTargetSystems_JsonSchema]

SET JsonSchema = '{ "$schema": "http://json-schema.org/draft-04/schema#", "type": "object", "properties": { "ServiceName": { "type": "string" }, "Port": { "type": "string" } }, "required": [ "ServiceName", "Port" ]}'

WHERE SystemType = 'Oracle Server'

GO




SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] ON

GO


UPDATE [dbo].[SourceAndTargetSystems]

SET SystemServer = 'localhost'

    ,SystemKeyVaultBaseUrl = 'https://$KeyVaultName$.vault.azure.net/'

    ,SystemJSON = '{  "ServiceName" : "orcltest.igh42ivyqpoujg1qj3le2itzzf.px.internal.cloudapp.net" , "Port" : "1521"  , "PasswordKeyVaultSecretName":"oracleserverpword"   }'

    ,SystemUserName = 'testuser'

    ,SystemSecretName = 'oracleserverpword'

WHERE SystemId = '-13'

GO


SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] OFF

GO