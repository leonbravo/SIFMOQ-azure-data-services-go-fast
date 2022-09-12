
UPDATE [dbo].[ExecutionEngine]
SET EngineName = '$SynapseWorkspaceName$'
	,SystemType = 'Synapse'
	,ResourceGroup = '$ResourceGroupName$'
	,SubscriptionUid = '$SubscriptionId$'
	,DefaultKeyVaultURL = 'https://$KeyVaultName$.vault.azure.net/'
	,LogAnalyticsWorkspaceId = '$LogAnalyticsWorkspaceId$'
	,EngineJson = '{
            "endpoint": "https://$SynapseWorkspaceName$.dev.azuresynapse.net", "DeltaProcessingNotebook": "DeltaProcessingNotebook", "PurviewAccountName": "$PurviewAccountName$", "DefaultSparkPoolName":"$SynapseSparkPoolName$"
        }'
WHERE EngineId = '-2'
GO