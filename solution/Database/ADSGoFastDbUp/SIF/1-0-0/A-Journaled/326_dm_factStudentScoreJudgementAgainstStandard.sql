DROP VIEW IF EXISTS [dm].[vw_StudentScoreJudgementAgainstStandard];
GO

CREATE VIEW [dm].[factStudentScoreJudgementAgainstStandard]
AS
SELECT 
	[StudentScoreJASKey]
	, [SchoolYear]
	, [TermInfoKey]
	, [LocalTermCode]
    , [StudentKey]
    , [StudentStateProvinceId]
    , [StudentLocalId]
    , [YearLevel]
    , [TeachingGroupKey]
    , [ClassLocalId]
    , [StaffKey]
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
    dbo.vw_StudentScoreJudgementAgainstStandard
GO