## DataFactory


Describes Execution Engine instances.
This can include an instance of either:
* Synapse Workspace
* Datafactory 

A datafactory will not require any additional information from its Engine json.

A synapse workspace will require additional information, this includes:
    *endpoint - Workspace dev endpoint
    *DeltaProcessingNotebook - The default notebook to be used for the delta task type
    *PurviewAccountName - The purview account name to be used for any lineage
    *DefaultSparkPoolName - The name of the spark pool to be used for notebook activities.