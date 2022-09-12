Declare @path varchar(200);

SET @path= $(RelativePath)+'/GradingAssignmentScore/GradingAssignmentScore/Snapshot/GradingAssignmentScore/**'

declare @statement varchar(max) ='CREATE VIEW dbo.vw_GradingAssignmentScore
AS
SELECT
	RefId GradingAssignmentScoreKey
    , StudentPersonalRefId StudentKey
    , StudentPersonalLocalId StudentId
    , TeachingGroupRefId TeachingGroupKey
    , SchoolInfoRefId SchoolInfoKey
    , GradingAssignmentRefId GradingAssignmentKey
    , StaffPersonalRefId StaffKey
	, DateGraded
    , ExpectedScore
    , ScorePoints
    , ScorePercent
    , ScoreLetter
    , ScoreDescription
    , TeacherJudgement
    , MarkInfoRefId MarkInfoKey
    , AssignmentScoreIteration
FROM
OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) WITH (
    [RefId]  varchar(50),
    [StudentPersonalRefId] varchar(50),
    [StudentPersonalLocalId] varchar(50),
    [TeachingGroupRefId] varchar(50),
    [SchoolInfoRefId] varchar(50),
    [GradingAssignmentRefId] varchar(50),
    [StaffPersonalRefId] varchar(50),
    [DateGraded] varchar(50),
    [ExpectedScore] varchar(5),
    [ScorePoints]   int,
    [ScorePercent] FLOAT,
    [ScoreLetter] varchar(5),
    [ScoreDescription] varchar(255),
    [TeacherJudgement] varchar(255),
    [MarkInfoRefId] varchar(50),
    [AssignmentScoreIteration] varchar(255)
)

    AS [result]';

    execute (@statement)
GO


