

DROP VIEW IF EXISTS dm.dimStudentSectionEnrollment;
GO

CREATE VIEW dm.dimStudentSectionEnrollment 
AS
SELECT
    RefId AS StudentSectionEnrollmentKey,
    StudentPersonalRefId AS StudentKey,
    SectionInfoRefId AS SectionInfoKey,
    SchoolYear,    
    CAST(EntryDate AS DATE) AS EntryDate,
    CAST(ExitDate AS DATE) AS ExitDate,
    CAST([Status] AS VARCHAR(50)) [Status],
    CAST(ValidFrom AS DATE) ValidFrom,
    CAST(ValidTo AS DATE) ValidTo,
    CAST(IsActive AS VARCHAR(50)) IsActive,
    CAST(CreatedOn AS DATE) CreatedOn,
    CAST(CreatedBy AS VARCHAR(50)) CreatedBy,
    CAST(UpdatedOn AS DATE) UpdatedOn,
    CAST(UpdatedBy AS VARCHAR(50)) UpdatedBy,
    CAST(HashKey AS VARCHAR(50)) HashKey
FROM dbo.vw_StudentSectionEnrollment;


-- SELECT * FROM dm.dimStudentSectionEnrollment