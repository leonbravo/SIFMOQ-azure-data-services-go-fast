
Declare @path varchar(200);

SET @path= $(RelativePath)+'/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**';

declare @statement varchar(max) =
'CREATE VIEW dbo.vw_TeachingGroup_Teacher
AS
SELECT DISTINCT
    TG.RefId,
    TeacherList.Association,
    TeacherList.StaffPersonalRefId
FROM 
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH(
    RefId VARCHAR(50),
    TeacherList VARCHAR(MAX)   
) AS TG
CROSS APPLY OPENJSON(TG.TeacherList,''$.TeachingGroupTeacher'')
        WITH (
        Association VARCHAR(100),
        StaffPersonalRefId VARCHAR(50),
        StaffLocalId  VARCHAR(50),
        [Name] NVARCHAR(MAX) ''$.Name'' AS JSON,
        id int ''$.sql:identity()''
    ) as TeacherList';

execute (@statement)
;
GO




