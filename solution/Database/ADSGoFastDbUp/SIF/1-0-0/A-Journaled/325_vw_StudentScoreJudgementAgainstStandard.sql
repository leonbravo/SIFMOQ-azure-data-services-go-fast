Declare @path varchar(200);

SET @path= $(RelativePath)+'/StudentScoreJudgementAgainstStandard/StudentScoreJudgementAgainstStandard/Snapshot/StudentScoreJudgementAgainstStandard/*'

declare @statement varchar(max) =
'CREATE VIEW [dbo].[vw_StudentScoreJudgementAgainstStandard]
AS
SELECT 
	[RefId] AS [StudentScoreJASKey]
	, [SchoolYear]
	, [TermInfoRefId] AS [TermInfoKey]
	, [LocalTermCode]
    , [StudentPersonalRefId] AS [StudentKey]
    , [StudentStateProvinceId]
    , [StudentLocalId]
    , JSON_VALUE([YearLevel], ''$.Code'') AS [YearLevel]
    , [TeachingGroupRefId] AS [TeachingGroupKey]
    , [ClassLocalId]
    , [StaffPersonalRefId] AS [StaffKey]
    , [StaffLocalId]
    , [LearningStandardList]
    , [CurriculumCode]   
    , [CurriculumNodeCode]
    , [Score]
    , [SpecialCircumstanceLocalCode]
    , [ManagedPathwayLocalCode]
    , [SchoolInfoRefId]
    , [SchoolLocalId]
    , [SchoolCommonwealthId]
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
    [RefId] VARCHAR(36) ,	
    [SchoolYear] VARCHAR(8000) ,	
    [TermInfoRefId] VARCHAR(36) ,	
    [LocalTermCode] VARCHAR(255) ,
    [StudentPersonalRefId] VARCHAR(36) ,	
    [StudentStateProvinceId] VARCHAR(255) ,	
    [StudentLocalId] VARCHAR(255) ,	
    [YearLevel] VARCHAR(100) ,	
    [TeachingGroupRefId] VARCHAR(36) ,	
    [ClassLocalId] VARCHAR(255) ,	
    [StaffPersonalRefId] VARCHAR(36) ,	
    [StaffLocalId] VARCHAR(255) ,	
    [LearningStandardList] VARCHAR(1000) ,	
    [CurriculumCode] VARCHAR(255) ,	
    [CurriculumNodeCode] VARCHAR(255) ,	
    [Score] VARCHAR(255) ,	
    [SpecialCircumstanceLocalCode] VARCHAR(255) ,	
    [ManagedPathwayLocalCode] VARCHAR(255) ,	
    [SchoolInfoRefId] VARCHAR(255) ,	
    [SchoolLocalId] VARCHAR(255) ,	
    [SchoolCommonwealthId] VARCHAR(255) 
) 
AS [result]';

execute (@statement)
;
GO