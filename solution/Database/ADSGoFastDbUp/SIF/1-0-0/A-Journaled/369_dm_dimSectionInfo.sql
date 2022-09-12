CREATE VIEW dm.dimSectionInfo
AS
SELECT
	 SectionInfoKey
    , SchoolCourseInfoKey
    , SectionInfoId
    , [Description]
    , SchoolYear
    , TermInfoKey
	, MediumOfInstructionMain
    , MediumOfInstructionOther
    , LanguageOfInstructionMain
    , LanguageOfInstructionOther
    , LocationOfInstructionMain
    , LocationOfInstructionOther
    , IsSummerSchool
    , CourseSectionCode
    , SectionCode
    , IsCountForAttendance
FROM
dbo.vw_SectionInfo
GO


