
DROP VIEW IF EXISTS dm.factTeachingGroup;
GO

CREATE VIEW dm.factTeachingGroup
AS
SELECT DISTINCT
    RefId AS TeachingGroupKey,
    StudentPersonalRefId AS StudentKey,
    StaffPersonalRefId AS StaffKey,
    SchoolInfoRefId AS SchoolKey,    
    SchoolCourseInfoRefId AS SchoolCourseKey,       
    TimeTableSubjectRefId AS TimeTableSubjectKey,  
    Association AS StaffPersonalAssociation,     
    LocalId AS TeachingGroupId,      
    SchoolLocalId,
    SchoolCourseLocalId,
    TimeTableSubjectLocalId,        
    DayId,
    PeriodId,    
    SchoolYear,
    ShortName,
    LongName,
    GroupType,
    [Set],
    Block,
    CurriculumLevel,
    KeyLearningArea,
    Semester,
    MinClassSize,
    MaxClassSize 
 FROM [dbo].[vw_TeachingGroup] 
;

-- SELECT * FROM dm.factTeachingGroup    
