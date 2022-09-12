CREATE VIEW dm.CalendarDate
as
SELECT 
CalendarDateRefId	CalendarDateKey
,  cast([Date] as date) as [Date]     
, CalendarSummaryRefId   as   CalendarSummaryKey           

, SchoolInfoRefId	 as SchoolInfoKey   
, cast(SchoolYear  as INT) as SchoolYear
, CalendarDateType       

, CalendarDateNumber	
, StudentAttendanceCountsTowardAttendance
, StudentAttendanceValue	      
, TeacherAttendanceCountsTowardAttendance      
, TeacherAttendanceValue
, AdministratorAttendanceCountsTowardAttendance 
, AdministratorAttendanceValue
from dbo.vw_CalendarDate