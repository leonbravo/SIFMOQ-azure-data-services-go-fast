CREATE VIEW dm.factStudentGrade
AS
SELECT 
     StudentGradePK
    , StudentKey
    , SchoolInfoKey
    , SchoolYear
    , TermSpan
    , GradeLetter
    , GradeNumeric
    , GradeNarrative
    , GradePercentage
    , Homegroup
    , YearLevel
    , TeachingGroupShortName
    , TeachingGroupKey
    , StaffKey
 
    , TermInfoKey
    , Description

    , TeacherJudgement
FROM
dbo.vw_StudentGrade