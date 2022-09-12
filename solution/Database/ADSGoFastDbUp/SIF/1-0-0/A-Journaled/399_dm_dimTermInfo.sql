

/*
--Created for presentation layerREATED FOR PRESENTATION LAYER (i.e. Power BI Reporting)
*/

DROP VIEW IF EXISTS [analytics].[dimTermInfo];
GO

CREATE VIEW [dm].[dimTermInfo]
AS

SELECT
     [TermInfoKey]
    ,[SchoolInfoKey]
    ,CAST([SchoolYear] AS SMALLINT) AS [SchoolYear]
    ,CAST([StartDate] AS DATE) AS [StartDate]
    ,CAST([EndDate] AS DATE) AS [EndDate]
    ,[Description]
    ,[AttendanceTerm]
    ,CAST([RelativeDuration] AS NUMERIC(10,4)) AS [RelativeDuration]
    ,[TermCode]
    ,[Track]
    ,[TermSpan]
    ,[MarkingTerm]
    ,[SchedulingTerm]
 FROM [dbo].[vw_TermInfo];
 GO