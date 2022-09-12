-------------------  SIF datatype with Staffstatus
DROP VIEW IF EXISTS [dm].[dimStaffStatus];
GO

CREATE VIEW [dm].[dimStaffStatus]
AS
SELECT 
	'A' AS [StaffStatus],
	'Active' AS [StaffStatusDescription]
UNION ALL
SELECT	
	'I' AS [StaffStatus],
	'Inactive' AS  [StaffStatusDescription]
UNION ALL
SELECT	
	'N' AS [StaffStatus],
	'No Longer Employed' AS [StaffStatusDescription]
UNION ALL
SELECT	
	'O' AS [StaffStatus], 
	'On Leave' AS  [StaffStatusDescription]
UNION ALL
SELECT	
	'S' AS [StaffStatus], 
	'Suspended' AS [StaffStatusDescription]

UNION ALL
SELECT	
	'X' AS [StaffStatus], 
	'Other - Details Not Available' AS [StaffStatusDescription]

GO