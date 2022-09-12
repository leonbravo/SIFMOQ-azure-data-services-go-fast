-------------------  SIF datatype with SexCode

DROP VIEW IF EXISTS [dm].[dimSexCode];
GO

CREATE VIEW [dm].[dimSexCode]
AS
SELECT 
	1 AS [SexCode],
	'Male' AS [SexCodeDescription]
UNION ALL
SELECT	
	2 AS [SexCode],
	'Female' AS  [SexCodeDescription]
UNION ALL
SELECT	
	3 AS [SexCode],
	'Intersex or indeterminate' AS [SexCodeDescription]
UNION ALL
SELECT	
	4 AS [SexCode], 
	'Self-described' AS  [SexCodeDescription]
UNION ALL
SELECT	
	9 AS [SexCode], 
	'Not Stated/Inadequately Described' AS [SexCodeDescription]
GO