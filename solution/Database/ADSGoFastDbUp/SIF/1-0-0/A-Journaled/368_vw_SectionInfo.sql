Declare @path varchar(200);

SET @path= $(RelativePath)+'/SectionInfo/SectionInfo/Snapshot/SectionInfo/*';
declare @statement varchar(max) =
'CREATE VIEW dbo.vw_SectionInfo
AS
SELECT
	RefId SectionInfoKey
    , SchoolCourseInfoRefId  SchoolCourseInfoKey
    , LocalId SectionInfoId
    , [Description]
    , SchoolYear
    , TermInfoRefId TermInfoKey
	, JSON_VALUE(MediumOfInstruction,  ''$.Code'')  MediumOfInstructionMain
    , JSON_VALUE(MediumOfInstruction,  ''$.OtherCodeList.value'')  MediumOfInstructionOther
    , JSON_VALUE(LanguageOfInstruction,''$.Code'')  LanguageOfInstructionMain
    , JSON_VALUE(LanguageOfInstruction,''$.OtherCodeList.value'')  LanguageOfInstructionOther
    , JSON_VALUE(LocationOfInstruction,''$.Code'')  LocationOfInstructionMain
    , JSON_VALUE(LocationOfInstruction,''$.OtherCodeList.value'')  LocationOfInstructionOther
    , SummerSchool IsSummerSchool
    , JSON_VALUE(SchoolCourseInfoOverride,''$.CourseCode'')  CourseSectionCode
    , JSON_VALUE(SchoolCourseInfoOverride,''$.StateCourseCode'')  SectionCode
    , CountForAttendance IsCountForAttendance
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
)  WITH(
    [RefId]  varchar(50)
    , [SchoolCourseInfoRefId]  varchar(50)
    , [LocalId]  varchar(50)
    , [Description]  varchar(255)
    , [SchoolYear]  varchar (4)
    , [TermInfoRefId]  varchar(50)
    , [MediumOfInstruction]   varchar(255)
    , [LanguageOfInstruction]   varchar(255)
    , [LocationOfInstruction]   varchar(255)
    , [SummerSchool]   varchar(3)
    , [SchoolCourseInfoOverride]   varchar(MAX)
    , [CountForAttendance]   varchar(3)
)
AS [result]';
execute (@statement);
go


