Declare @path varchar(200);

SET @path= $(RelativePath)+'GradingAssignment/GradingAssignment/Snapshot/GradingAssignment/**';

declare @statement varchar(max) =
'CREATE VIEW [dbo].[vw_GradingAssignment]
AS
SELECT 
    [RefId] AS [GradingAssignmentKey]
    ,[TeachingGroupRefId] AS [TeachingGroupKey]
    ,[StudentPersonalRefIdList] AS [StudentKey]
    ,[SchoolInfoRefId] AS [SchoolInfoKey]
    ,[GradingCategory] AS [GradingCategory]
    ,[Description] AS [Description]
    ,[PointsPossible]
    ,[CreateDate]
    ,[DueDate]
    ,[Weight]
    ,[DetailedDescriptionURL]
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
    [RefId] VARCHAR(36) ,
    [TeachingGroupRefId] VARCHAR(36) ,
    [StudentPersonalRefIdList] VARCHAR(36),
    [SchoolInfoRefId] VARCHAR(36) ,
    [GradingCategory] VARCHAR(255) ,
    [Description] VARCHAR (1000) ,
    [PointsPossible] VARCHAR(8000) ,
    [CreateDate] VARCHAR (8000) ,
    [DueDate] VARCHAR(8000) ,
    [Weight] VARCHAR(18) ,
    [DetailedDescriptionURL] VARCHAR(1000) 
) AS [result]'
;

execute (@statement)
;
GO