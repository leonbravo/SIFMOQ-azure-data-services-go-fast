Declare @path varchar(200);

SET @path= $(RelativePath)+ '/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**';

select @path;



declare @statement varchar(max) =
'
CREATE VIEW dbo.vw_TeachingGroup_list
AS
SELECT DISTINCT
    RefId,
    SchoolYear,
    LocalId,
    ShortName,
    LongName,
    GroupType,
    CAST([Set] AS INT) [Set],
    CAST(Block AS INT) Block,
    CurriculumLevel,
    SchoolInfoRefId,
    SchoolLocalId,
    SchoolCourseInfoRefId,
    SchoolCourseLocalId,
    TimeTableSubjectRefId,
    TimeTableSubjectLocalId,
    KeyLearningArea,
    Semester,
    MinClassSize,
    MaxClassSize    
FROM     OPENROWSET(
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
    MaxClassSize VARCHAR(4)
) AS TG '   ;

execute (@statement)
;

go