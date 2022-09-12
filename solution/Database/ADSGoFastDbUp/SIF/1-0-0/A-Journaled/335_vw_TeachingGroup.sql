Declare @path varchar(200);

SET @path= $(RelativePath)+'/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**';

declare @statement varchar(max) =
'CREATE VIEW dbo.vw_TeachingGroup
AS
SELECT DISTINCT
    TG.RefId,
    StudentList.StudentPersonalRefId,
    TeacherList.StaffPersonalRefId,
    TeacherList.Association,        
    PeriodList.DayId,
    PeriodList.PeriodId,    
    TG.SchoolYear,
    TG.LocalId,
    TG.ShortName,
    TG.LongName,
    TG.GroupType,
    CAST(TG.[Set] AS INT) [Set],
    CAST(TG.Block AS INT) Block,
    TG.CurriculumLevel,
    TG.SchoolInfoRefId,
    TG.SchoolLocalId,
    TG.SchoolCourseInfoRefId,
    TG.SchoolCourseLocalId,
    TG.TimeTableSubjectRefId,
    TG.TimeTableSubjectLocalId,
    TG.KeyLearningArea,
    TG.Semester,
    TG.MinClassSize,
    TG.MaxClassSize     
FROM OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH(
    RefId VARCHAR(50),
    SchoolYear VARCHAR(4),
    LocalId VARCHAR(50),
    ShortName VARCHAR(20),
    LongName VARCHAR(255),
    GroupType  VARCHAR(255),
    [Set] VARCHAR(4),
    Block VARCHAR(4),
    CurriculumLevel VARCHAR(255),
    SchoolInfoRefId VARCHAR(50),
    SchoolLocalId VARCHAR(50),
    SchoolCourseInfoRefId VARCHAR(50),
    SchoolCourseLocalId VARCHAR(50),
    TimeTableSubjectRefId VARCHAR(50),
    TimeTableSubjectLocalId VARCHAR(50),
    KeyLearningArea VARCHAR(20),
    Semester VARCHAR(50),
    MinClassSize VARCHAR(4),
    MaxClassSize VARCHAR(4),
    StudentList VARCHAR(MAX),
    TeacherList VARCHAR(MAX),
    TeachingGroupPeriodList VARCHAR(MAX)
) AS TG    
CROSS APPLY OPENJSON(TG.StudentList,''$.TeachingGroupStudent'')
        WITH (
        StudentPersonalRefId VARCHAR(50),
        StudentLocalId VARCHAR(50),
        [Name] NVARCHAR(MAX) ''$.Name'' AS JSON,
        id int               ''$.sql:identity()''
    ) AS StudentList
CROSS APPLY OPENJSON(TG.TeacherList,''$.TeachingGroupTeacher'')
        WITH (
        Association VARCHAR(100),
        StaffPersonalRefId VARCHAR(50),
        StaffLocalId  VARCHAR(50),
        [Name] NVARCHAR(MAX) ''$.Name'' AS JSON,
        id int ''$.sql:identity()''
    ) AS TeacherList
CROSS APPLY OPENJSON(TG.TeachingGroupPeriodList,''$.TeachingGroupPeriod'')
        WITH (
        DayId VARCHAR(1),
        PeriodId INT,
        id int ''$.sql:identity()''
    ) AS PeriodList';

execute (@statement)
;
GO


