

$sql = @"

"@

$tests = (Get-Content -Path  ($PWD.ToString() + '../../../FunctionApp/FunctionApp.TestHarness/UnitTests/tests.json') | ConvertFrom-Json -Depth 10)




$i = 0
foreach ($t in $tests)
{
    Write-Information "_____________________________"
    Write-Information "Writing test number: " $i.ToString()
    Write-Information "_____________________________"
    
    $TaskMasterId = ($t.TaskMasterId)
    $TaskMasterName = $t.TestDescription
    $TaskTypeId = $t.TaskTypeId
    $TaskGroupId = [bool]($t.PSobject.Properties.name -match "TaskGroupId") ? $t.TaskGroupId : ( -1, -2, -3, -4 | Get-Random  )
    $ScheduleMasterId = -4
    $SourceSystemId = $t.SourceSystemId
    $TargetSystemId = $t.TargetSystemId
    $DegreeOfCopyParallelism = $t.DegreeOfCopyParallelism
    $AllowMultipleActiveInstances = 0
    $TaskDatafactoryIR = "'Azure'"
    $TaskMasterJSON = $t.TaskMasterJson
    $ActiveYN = 0
    $DependencyChainTag = [bool]($t.PSobject.Properties.name -match "DependencyChainTag") ? $t.DependencyChainTag : ""
    $EngineId = $t.EngineId
    
    $i+=1

    $sql += "
                                        
    SET IDENTITY_INSERT [dbo].[TaskMaster] ON;
    insert into [dbo].[TaskMaster]
    (
        [TaskMasterId]                          ,
        [TaskMasterName]                        ,
        [TaskTypeId]                            ,
        [TaskGroupId]                           ,
        [ScheduleMasterId]                      ,
        [SourceSystemId]                        ,
        [TargetSystemId]                        ,
        [DegreeOfCopyParallelism]               ,
        [AllowMultipleActiveInstances]          ,
        [TaskDatafactoryIR]                     ,
        [TaskMasterJSON]                        ,
        [ActiveYN]                              ,
        [DependencyChainTag]                    ,
        [EngineId]                         
    )
    select 
        $TaskMasterId                          ,
        '$TaskMasterName'                      ,
        $TaskTypeId                            ,
        $TaskGroupId                           ,
        $ScheduleMasterId                      ,
        $SourceSystemId                        ,
        $TargetSystemId                        ,
        $DegreeOfCopyParallelism               ,
        $AllowMultipleActiveInstances          ,
        $TaskDatafactoryIR                     ,
        '$TaskMasterJSON'                      ,
        $ActiveYN                              ,
        '$DependencyChainTag'                  ,
        $EngineId;  
    
    SET IDENTITY_INSERT [dbo].[TaskMaster] OFF;        
    
    "

}

$sql | Set-Content ("$PWD/SqlTests.sql")

