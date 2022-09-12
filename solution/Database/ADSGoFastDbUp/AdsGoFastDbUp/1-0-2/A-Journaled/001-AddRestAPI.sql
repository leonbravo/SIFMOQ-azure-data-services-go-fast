/* SOURCE AND TARGET SAMPLES FOR REST API*/
SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] ON 
GO
/* OLD ADF
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-17, N'Sample - REST API Anonymous Authentication', N'Rest', N'Sample REST API Anonymous Authentication', N'(baseurl?)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://catfact.ninja/" }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-18, N'Sample - REST API Basic Authentication', N'Rest', N'Sample REST API Basic Authentication', N'(baseurl?)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://catfact.ninja/"  , "UserName" : "N/A", "PasswordKeyVaultSecretName":"APISecret"   }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-19, N'Sample - REST API Service Principal Authentication', N'Rest', N'Sample REST API Service Principal Authentication', N'(baseurl?)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://catfact.ninja/"  , "ServicePrincipalId" : "N/A", "AadResourceId" : "N/A", "TenantId" : "N/A", "PasswordKeyVaultSecretName":"APISecret"   }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-20, N'Sample - REST API OAuth2 Authentication', N'Rest', N'Sample REST API OAuth2 Authentication', N'(baseurl?)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://catfact.ninja/"  , "ClientId" : "N/A",  "TokenEndpoint" : "N/A" , "PasswordKeyVaultSecretName":"APISecret"   }', 1, 1, NULL)
GO
*/

INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-17, N'Sample - REST API No Auth', N'Rest', N'Sample REST API catfacts', N'(external)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://catfact.ninja"  , "headers" : "{}", "NextPageUrlKey" : "next_page_url"    }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-18, N'Sample - REST API Twitter with Auth', N'Rest', N'Sample REST API twitter', N'(external)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://api.twitter.com/2"  , "headers" : "{        \"Authorization\": \"Bearer $InsertSecret($KeyVault(ark-stg-kv-ads-xjp4).$SecretName(bearerToken).$LinkedServiceName(SLS_AzureKeyVault))$END\"}"    }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-19, N'Sample - REST API HubSpot with Auth', N'Rest', N'Sample REST API hubspot', N'(external)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://api.hubapi.com"  , "headers" : "{\"Content-Type\": \"application/json\",\"Authorization\": \"Bearer $InsertSecret($KeyVault(ark-stg-kv-ads-xjp4).$SecretName(HubspotAPI).$LinkedServiceName(SLS_AzureKeyVault))$END\"}"    }', 1, 1, NULL)
GO
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-20, N'Sample - REST API Meta No Auth in Header', N'Rest', N'Sample REST API Meta', N'(external)', N'MSI', NULL, NULL, N'https://$KeyVaultName$.vault.azure.net/', N'{         "BaseUrl" : "https://graph.facebook.com"  , "headers" : "{}"    }', 1, 1, NULL)
GO
SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] OFF 
GO

/* SOURCE AND TARGET SCHEMA FOR REST API */
/* OLD (ADF)
INSERT [dbo].[SourceAndTargetSystems_JsonSchema] ([SystemType], [JsonSchema]) VALUES (N'Rest', N'{  "$schema": "http://json-schema.org/draft-04/schema#",  "type": "object",  "properties": {    "BaseUrl": {      "type": "string",     }, "UserName": {      "type": "string",     },  "ClientId": {      "type": "string",     }, "AadResourceId": {      "type": "string",     }, "ServicePrincipalId": {      "type": "string",     },  "TenantId": {      "type": "string",     }, "TokenEndpoint": {      "type": "string",     }, "PasswordKeyVaultSecretName": {      "type": "string",     }  },  "required": [    "BaseUrl"  ]}')
*/
INSERT [dbo].[SourceAndTargetSystems_JsonSchema] ([SystemType], [JsonSchema]) VALUES (N'Rest', N'{  "$schema": "http://json-schema.org/draft-04/schema#",  "type": "object",  "properties": {    "BaseUrl": {      "type": "string"     }, "NextPageUrlKey": {      "type": "string"     }, "headers": {      "type": "string"     }  },  "required": [    "BaseUrl", "headers"  ]}')
GO
/* TASK TYPE FOR REST API (Rest) */
SET IDENTITY_INSERT [dbo].[TaskType] ON 
GO
INSERT [dbo].[TaskType] ([TaskTypeId], [TaskTypeName], [TaskExecutionType], [TaskTypeJson], [ActiveYN]) VALUES (-9, N'REST API to Azure Storage', N'ADF', NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[TaskType] OFF
GO

SET IDENTITY_INSERT [dbo].[IntegrationRuntimeMapping] ON 
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (12, 1, 'Azure', -17, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (13, 1, 'Azure', -18, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (14, 1, 'Azure', -19, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (15, 1, 'Azure', -20, 1)
GO
SET IDENTITY_INSERT [dbo].[IntegrationRuntimeMapping] OFF
GO