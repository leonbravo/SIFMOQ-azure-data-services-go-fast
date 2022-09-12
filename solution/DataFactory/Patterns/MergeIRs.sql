            Merge dbo.IntegrationRuntime Tgt
            using (
            Select * from OPENJSON('[
  {
    "is_azure": true,
    "is_managed_vnet": true,
    "name": "Azure-Integration-Runtime",
    "short_name": "Azure",
    "valid_pipeline_patterns": [
      {
        "Folder": "*",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      }
    ],
    "valid_source_systems": [
      "*"
    ]
  },
  {
    "is_azure": false,
    "is_managed_vnet": false,
    "name": "Onprem-Integration-Runtime",
    "short_name": "OnPrem",
    "valid_pipeline_patterns": [
      {
        "Folder": "Azure-Storage-to-Azure-Storage",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "Execute-SQL-Statement",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "SQL-Database-to-Azure-Storage",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "SQL-Database-to-Azure-Storage-CDC",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      }
    ],
    "valid_source_systems": [
      "-14",
      "-15",
      "-9",
      "-3",
      "-4"
    ]
  }
]') WITH 
            (
                name varchar(200), 
                short_name varchar(20), 
                is_azure bit, 
                is_managed_vnet bit     
            )
            ) Src on Src.short_name = tgt.IntegrationRuntimeName 
            when NOT matched by TARGET then insert
            (IntegrationRuntimeName, EngineId, ActiveYN)
            VALUES (Src.short_name,1,1);


            drop table if exists #tempIntegrationRuntimeMapping 
            Select ir.IntegrationRuntimeId, a.short_name IntegrationRuntimeName, c.[value] SystemId
            into #tempIntegrationRuntimeMapping
            from 
            (
            Select IR.*, Patterns.[Value] from OPENJSON('[
  {
    "is_azure": true,
    "is_managed_vnet": true,
    "name": "Azure-Integration-Runtime",
    "short_name": "Azure",
    "valid_pipeline_patterns": [
      {
        "Folder": "*",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      }
    ],
    "valid_source_systems": [
      "*"
    ]
  },
  {
    "is_azure": false,
    "is_managed_vnet": false,
    "name": "Onprem-Integration-Runtime",
    "short_name": "OnPrem",
    "valid_pipeline_patterns": [
      {
        "Folder": "Azure-Storage-to-Azure-Storage",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "Execute-SQL-Statement",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "SQL-Database-to-Azure-Storage",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      },
      {
        "Folder": "SQL-Database-to-Azure-Storage-CDC",
        "SourceFormat": "*",
        "SourceType": "*",
        "TargetFormat": "*",
        "TargetType": "*",
        "TaskTypeId": "*"
      }
    ],
    "valid_source_systems": [
      "-14",
      "-15",
      "-9",
      "-3",
      "-4"
    ]
  }
]') A 
           CROSS APPLY OPENJSON(A.[value]) Patterns 
           CROSS APPLY OPENJSON(A.[value]) with (short_name varchar(max)) IR 
           where Patterns.[key] = 'valid_source_systems'
           ) A
           OUTER APPLY OPENJSON(A.[Value])  C
           join 
           dbo.IntegrationRuntime ir on ir.IntegrationRuntimeName = a.short_name 
           
           drop table if exists #tempIntegrationRuntimeMapping2
           Select * into #tempIntegrationRuntimeMapping2
           from 
           (
           select a.IntegrationRuntimeId, a.IntegrationRuntimeName, b.SystemId from #tempIntegrationRuntimeMapping  a
           cross join [dbo].[SourceAndTargetSystems] b 
           where a.SystemId = '*'
           union 
           select a.IntegrationRuntimeId, a.IntegrationRuntimeName, a.SystemId from #tempIntegrationRuntimeMapping  a
           where a.SystemId != '*'
           ) a
                    
           Merge dbo.IntegrationRuntimeMapping tgt
           using #tempIntegrationRuntimeMapping2 src on 
           tgt.IntegrationRuntimeName = src.IntegrationRuntimeName and tgt.SystemId = src.SystemId
           when not matched by target then 
           insert 
           ([IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN])
           values 
           (src.IntegrationRuntimeId, src.IntegrationRuntimeName, cast(src.SystemId as bigint), 1);            

           
