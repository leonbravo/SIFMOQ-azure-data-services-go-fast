/*-----------------------------------------------------------------------

 Copyright (c) Microsoft Corporation.
 Licensed under the MIT license.

-----------------------------------------------------------------------*/
 
Begin TRY

DECLARE @tmpOutPut table( ScheduleInstanceId bigint,  
                           ScheduleMasterId bigint); 

/*General Schedule Insert */
INSERT INTO [dbo].[ScheduleInstance] ([schedulemasterid],[scheduleddateutc],[scheduleddatetimeoffset],[activeyn])
  OUTPUT INSERTED.ScheduleInstanceId,   
         INSERTED.ScheduleMasterId
  INTO @tmpOutPut
SELECT [schedulemasterid],[scheduleddateutc],[scheduleddatetimeoffset],[activeyn]
FROM {tmpScheduleInstance}

/*General Task Insert */
INSERT INTO [dbo].[TaskInstance] ([executionuid],[taskmasterid],[scheduleinstanceid],[adfpipeline],[taskinstancejson],[lastexecutionstatus],[activeyn])
SELECT [executionuid],tmpTI.[taskmasterid],B.[scheduleinstanceid],[adfpipeline],[taskinstancejson],[lastexecutionstatus],tmpTI.[activeyn]
FROM {tmpTaskInstance} tmpTI
INNER JOIN [dbo].[TaskMaster] TM
on TM.TaskMasterId = tmpTI.TaskMasterId
INNER JOIN @tmpOutPut B
ON B.ScheduleMasterId = TM.ScheduleMasterId
WHERE TM.InsertIntoCurrentSchedule = 0

/*Insert Into Current Schedule Tasks*/
INSERT INTO [dbo].[TaskInstance] ([executionuid],[taskmasterid],[scheduleinstanceid],[adfpipeline],[taskinstancejson],[lastexecutionstatus],[activeyn])
SELECT [executionuid],tmpTI.[taskmasterid],B.[scheduleinstanceid],[adfpipeline],[taskinstancejson],[lastexecutionstatus],tmpTI.[activeyn]
FROM {tmpTaskInstance} tmpTI
INNER JOIN [dbo].[TaskMaster] TM
on TM.TaskMasterId = tmpTI.TaskMasterId
INNER JOIN 
(
    Select a.ScheduleMasterId, max(a.scheduleinstanceid) scheduleinstanceid
    from [dbo].[ScheduleInstance] a
    group by a.ScheduleMasterId
) B
ON B.ScheduleMasterId = TM.ScheduleMasterId
WHERE TM.InsertIntoCurrentSchedule = 1

/*Flip Flag on Insert into Current Schedule Tasks*/
Update TaskMaster
Set InsertIntoCurrentSchedule = 0
From TaskMaster
where InsertIntoCurrentSchedule = 1

END TRY
 
Begin Catch

  -- Raise an error with the details of the exception
  DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
  SELECT @ErrMsg = ERROR_MESSAGE(),
         @ErrSeverity = ERROR_SEVERITY()
 
  RAISERROR(@ErrMsg, @ErrSeverity, 1)
 
End Catch
