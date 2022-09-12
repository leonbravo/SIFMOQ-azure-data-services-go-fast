
DROP VIEW IF EXISTS dm.dimStudentAttendance;
GO

CREATE VIEW dm.dimStudentAttendance
AS
SELECT
    [RefId] AS StudentDailyAttendanceKey,
    [StudentPersonalRefId] AS StudentKey,
    [SchoolInfoRefId] AS SchoolInfoKey,
    [Date] AS CalendarDate,
    [SchoolYear] AS SchoolYear,
    [DayValue] AS DayValue,
    [AttendanceCode] AS AttendanceCode,
    [AttendanceStatus] AS AttendanceStatus,
    [TimeIn] AS TimeIn,
    [TimeOut] AS [TimeOut],
    [AttendanceNote] AS AttendanceNote
FROM
    [dbo].[vw_StudentDailyAttendance]

-- SELECT * FROM dm.dimStudentAttendance    