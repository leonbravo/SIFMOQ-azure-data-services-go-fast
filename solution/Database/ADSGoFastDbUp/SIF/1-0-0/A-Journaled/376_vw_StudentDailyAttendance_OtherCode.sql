Declare @path varchar(200);

SET @path= $(RelativePath)+'/StudentDailyAttendance/StudentDailyAttendance/Snapshot/StudentDailyAttendance/**';
declare @statement varchar(max) =
'
CREATE VIEW dbo.vw_StudentDailyAttendance_OtherCode
AS
SELECT 
    RefId,
    OtherCodeList.Codeset,
    OtherCodeList.value
FROM     OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH(
    RefId VARCHAR(50),
    AttendanceCode VARCHAR(MAX)
) AS SDA
CROSS APPLY OPENJSON(SDA.AttendanceCode,''$.OtherCodeList.OtherCode'')
        WITH (
        Codeset VARCHAR(50),
        value VARCHAR(10),
        id int ''$.sql:identity()''
    ) as OtherCodeList'
    ;

execute (@statement)
;
GO