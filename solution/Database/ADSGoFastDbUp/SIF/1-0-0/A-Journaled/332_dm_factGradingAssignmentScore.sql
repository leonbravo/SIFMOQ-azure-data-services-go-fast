drop view if EXISTS dm.factGradingAssignmentScore
go
CREATE VIEW dm.factGradingAssignmentScore
AS
SELECT
	 GradingAssignmentScoreKey
    , StudentKey
    , StudentId
    , TeachingGroupKey
    , SchoolInfoKey
    , GradingAssignmentKey
    , StaffKey
	, cast([DateGraded] as DATE) as DateGraded
    , cast( ExpectedScore as bit) as ExpectedScore
    , cast(ScorePoints as int)  as ScorePoints
    , cast(ScorePercent as NUMERIC (5,2)) as ScorePercent
    , ScoreLetter
    , ScoreDescription
    , TeacherJudgement
    , MarkInfoKey
    , AssignmentScoreIteration
FROM dbo.vw_GradingAssignmentScore