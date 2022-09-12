Declare @path varchar(200);

SET @path= $(RelativePath)+'/MarkValueInfo/MarkValueInfo/Snapshot/MarkValueInfo/*';

declare @statement varchar(max) =
'
CREATE VIEW [dbo].[vw_MarkValueInfo_ValidLetterMark]
AS
SELECT 
	MVI.[RefId] AS [MarkInfoKey],
	LML.Code,
    LML.NumericEquivalent
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
    [RefId] VARCHAR(50),	
    [ValidLetterMarkList] VARCHAR(MAX) 
)
AS MVI
CROSS APPLY OPENJSON(MVI.ValidLetterMarkList,''$.ValidLetterMark'')
        WITH (
        Code VARCHAR(3),
        NumericEquivalent INT,
        id int ''$.sql:identity()''
    ) as LML'
;

execute (@statement);

