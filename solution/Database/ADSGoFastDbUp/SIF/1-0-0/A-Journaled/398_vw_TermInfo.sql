Declare @path varchar(200);

SET @path= $(RelativePath)+'/TermInfo/TermInfo/Snapshot/TermInfo/*';

declare @statement varchar(max) =
'
CREATE VIEW [dbo].[vw_TermInfo]
AS
SELECT 
    [RefId] AS [TermInfoKey]
    ,[SchoolInfoRefId] AS [SchoolInfoKey]
    ,[SchoolYear] AS [SchoolYear]
    ,[StartDate] AS [StartDate]
    ,[EndDate] AS [EndDate]
    ,[Description] AS [Description]
    ,[RelativeDuration]
    ,[TermCode]
    ,[Track]
    ,[TermSpan]
    ,[MarkingTerm] 
    ,[SchedulingTerm]
    ,[AttendanceTerm]
FROM
       OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) WITH (
[RefId] VARCHAR(36) ,
[SchoolInfoRefId] VARCHAR(36) ,
[SchoolYear] VARCHAR(4),
[StartDate] VARCHAR(10) ,
[EndDate] VARCHAR(10) ,
[Description] VARCHAR (255) ,
[RelativeDuration] VARCHAR(18) ,
[TermCode] VARCHAR (50) ,
[Track] VARCHAR(100) ,
[TermSpan] VARCHAR(20) ,
[MarkingTerm] VARCHAR(2) ,
[SchedulingTerm] VARCHAR(2) ,
[AttendanceTerm] VARCHAR(2) 
) AS [result]';

execute (@statement)
;
GO