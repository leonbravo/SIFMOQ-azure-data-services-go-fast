Declare @path varchar(200);

SET @path= $(RelativePath)+'/CalendarDate/CalendarDate/Snapshot/CalendarDate/**'


declare @statement varchar(max)
='CREATE VIEW dbo.vw_CalendarDate
as
SELECT *
FROM OPENROWSET(
BULK  ''' + @path+ ''',
DATA_SOURCE =''sif_eds'',
FORMAT=''PARQUET''
) WITH (
 CalendarDateRefId	VARCHAR(50) 
, [Date]	            VARCHAR (50)                      
, CalendarSummaryRefId	VARCHAR (50)
, SchoolInfoRefId	    VARCHAR (50)
, SchoolYear	        VARCHAR(4)
, CalendarDateType	    VARCHAR(20)  ''$.CalendarDateType.Code''
, CalendarDateNumber	INT 
, StudentAttendanceCountsTowardAttendance     VARCHAR(255)  ''$.StudentAttendance.CountsTowardAttendance''
, StudentAttendanceValue	     FLOAT  ''$.StudentAttendance.AttendanceValue''
, TeacherAttendanceCountsTowardAttendance      VARCHAR(255)  ''$.TeacherAttendance.CountsTowardAttendance''
, TeacherAttendanceValue   FLOAT      ''$.TeacherAttendance.AttendanceValue''
, AdministratorAttendanceCountsTowardAttendance VARCHAR(255) 	''$.AdministratorAttendance.CountsTowardAttendance''
, AdministratorAttendanceValue FLOAT   ''$.AdministratorAttendance.AttendanceValue''

)
as r'



exec (@statement )
go




