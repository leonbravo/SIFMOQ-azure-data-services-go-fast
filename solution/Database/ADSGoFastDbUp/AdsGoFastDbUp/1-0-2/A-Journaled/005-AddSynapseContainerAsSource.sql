BEGIN TRANSACTION; 
SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] ON;
INSERT [dbo].[SourceAndTargetSystems] ([SystemId], [SystemName], [SystemType], [SystemDescription], [SystemServer], [SystemAuthType], [SystemUserName], [SystemSecretName], [SystemKeyVaultBaseUrl], [SystemJSON], [ActiveYN], [IsExternal], [DataFactoryIR]) VALUES (-5, 'dummy', N'ADLS', N'Azure Data Lake - ADS Go Fast Synapase Lakedatabase Container', N'dummy', N'MSI', NULL, NULL, N'dummy', N'{ "Container" : "dummy" }', 1, 0, NULL);
SET IDENTITY_INSERT [dbo].[SourceAndTargetSystems] OFF;


UPDATE [dbo].[SourceAndTargetSystems]
SET SystemServer = 'https://$AdlsStorageName$.dfs.core.windows.net'
	,SystemKeyVaultBaseUrl = 'https://$KeyVaultName$.vault.azure.net/'
	,SystemJSON = '{ "Container" : "$SynapseLakeDatabaseContainerName$" }'
	,SystemName = '$AdlsStorageName$\lakedatabase'
WHERE SystemId = '-5';

COMMIT TRANSACTION;
