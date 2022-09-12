DROP VIEW IF EXISTS [dm].[dimMarkValueInfo];
GO

CREATE VIEW [dm].[dimMarkValueInfo]
AS
SELECT 
	 [MarkInfoKey]
	, [SchoolInfoKey]
	, [ValueName]
    , [PercentageMinimum]
    , [PercentageMaximum]
    , [PercentagePassingGrade]
    , [NumericPrecision]
    , [NumericScale]
    , [NumericLow]
    , [NumericHigh]
    , [NumericPassingGrade]
    , [NarrativeMaximumSize]
    , [Narrative]    
FROM
[dbo].[vw_MarkValueInfo]



