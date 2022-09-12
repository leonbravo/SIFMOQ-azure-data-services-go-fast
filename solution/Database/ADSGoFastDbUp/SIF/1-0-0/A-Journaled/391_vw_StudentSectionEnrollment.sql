Declare @path varchar(200);

SET @path= $(RelativePath)+'/StudentSectionEnrollment/StudentSectionEnrollment' ;

declare @statement varchar(max) =
'
CREATE VIEW dbo.vw_StudentSectionEnrollment 
AS
SELECT
    RefId ,
    StudentPersonalRefId,
    SectionInfoRefId,
    SchoolYear,    
    EntryDate,
    ExitDate,
    JSON_VALUE(SIF_ExtendedElements, ''$.Status'') [Status],
    JSON_VALUE(SIF_ExtendedElements, ''$.ValidFrom'') ValidFrom,
    JSON_VALUE(SIF_ExtendedElements, ''$.ValidTo'') ValidTo,
    JSON_VALUE(SIF_ExtendedElements, ''$.IsActive'') IsActive,
    JSON_VALUE(SIF_ExtendedElements, ''$.CreatedOn'') CreatedOn,
    JSON_VALUE(SIF_ExtendedElements, ''$.CreatedBy'') CreatedBy,
    JSON_VALUE(SIF_ExtendedElements, ''$.UpdatedOn'') UpdatedOn,
    JSON_VALUE(SIF_ExtendedElements, ''$.UpdatedBy'') UpdatedBy,
    JSON_VALUE(SIF_ExtendedElements, ''$.HashKey'') HashKey
FROM     OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
    EntryDate VARCHAR(10),
    ExitDate VARCHAR(10),
    RefId VARCHAR(50),
    StudentPersonalRefId VARCHAR(50),
    SchoolYear VARCHAR(4),
    SectionInfoRefId VARCHAR (50),
    SIF_ExtendedElements VARCHAR(MAX),
    [Status] VARCHAR(50),
    ValidFrom VARCHAR(10),
    ValidTo VARCHAR(10),
    IsActive BIT,
    CreatedOn VARCHAR(10),
    CreatedBy VARCHAR(255),
    UpdatedOn VARCHAR (10),
    UpdatedBy VARCHAR(255),
    HashKey VARCHAR(50)
) AS [result]';

execute (@statement)
;
GO