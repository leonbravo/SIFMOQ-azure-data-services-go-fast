
DROP VIEW IF EXISTS dbo.vw_TeachingGroup_Student;
GO

CREATE VIEW dbo.vw_TeachingGroup_Student
AS
SELECT DISTINCT
    TG.RefId,
    StudentList.StudentPersonalRefId
FROM OPENROWSET(
BULK 'samples/sif/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**',
DATA_SOURCE ='sif_eds',
FORMAT='PARQUET'
) 
WITH(
    RefId VARCHAR(50),
    StudentList VARCHAR(MAX)   
) AS TG
CROSS APPLY OPENJSON(TG.StudentList,'$.TeachingGroupStudent')
        WITH (
        StudentPersonalRefId VARCHAR(50),
        StudentLocalId VARCHAR(50),
        [Name] NVARCHAR(MAX) '$.Name' AS JSON,
        id int '$.sql:identity()'
    ) as StudentList;
        
-- SELECT * FROM dbo.vw_TeachingGroup_Student;        