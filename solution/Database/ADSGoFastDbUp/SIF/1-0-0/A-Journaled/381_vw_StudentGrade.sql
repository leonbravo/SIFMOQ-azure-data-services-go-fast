Declare @path varchar(200);

SET @path= $(RelativePath)+'/StudentGrade/StudentGrade/Snapshot/StudentGrade/**';

declare @statement varchar(max) =
'
CREATE VIEW dbo.vw_StudentGrade
AS
SELECT 
    RefId StudentGradePK
    , StudentPersonalRefId StudentKey
    , SchoolInfoRefId SchoolInfoKey
    , SchoolYear
    , TermSpan
    , JSON_VALUE(Grade,''$.Letter'')  GradeLetter
    , JSON_VALUE(Grade,''$.Numeric'')  GradeNumeric
    , JSON_VALUE(Grade,''$.Narrative'')  GradeNarrative
    , JSON_VALUE(Grade,''$.Percentage'')  GradePercentage
    , Homegroup
    , YearLevel
    , TeachingGroupShortName
    , TeachingGroupRefId TeachingGroupKey
    , StaffPersonalRefId StaffKey
    , Markers
    , TermInfoRefId TermInfoKey
    , [Description]
    , LearningArea
    , LearningStandardList
    , GradingScoreList
    , TeacherJudgement
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
RefId VARCHAR(36) ,
StudentPersonalRefId VARCHAR(36) ,
SchoolInfoRefId VARCHAR(36),
SchoolYear VARCHAR(4) ,
TermSpan VARCHAR(4) ,
Grade VARCHAR (Max) ,
Markers VARCHAR (Max),
Homegroup VARCHAR(255) ,
YearLevel VARCHAR(10) ,
TeachingGroupShortName VARCHAR(255) ,
TeachingGroupRefId VARCHAR(36) ,
StaffPersonalRefId VARCHAR(36) ,

TermInfoRefId VARCHAR(36) ,
[Description] VARCHAR(255) ,
LearningArea           VARCHAR(max),
LearningStandardList   VARCHAR(max),
GradingScoreList VARCHAR(max),
TeacherJudgement VARCHAR(255)

) AS [result]';

execute (@statement)
;
GO
