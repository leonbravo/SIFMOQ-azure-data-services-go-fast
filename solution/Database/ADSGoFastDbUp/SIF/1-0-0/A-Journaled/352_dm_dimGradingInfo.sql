DROP VIEW IF EXISTS [dm].[dimGradingInfo];
GO

CREATE VIEW [dm].[dimGradingInfo]
AS

SELECT 
     [GradingAssignmentKey]
    ,[TeachingGroupKey]
    ,[StudentKey]
    ,[SchoolInfoKey]
    ,[GradingCategory]
    ,[Description]
    ,[PointsPossible]
    , cast([CreateDate] as date) as [CreateDate]     
    , cast([DueDate] as date) as [DueDate]        --need to cast as datetime
    ,[Weight]         --need to cast as numeric
    ,[DetailedDescriptionURL]
 FROM [dbo].[vw_GradingAssignment]