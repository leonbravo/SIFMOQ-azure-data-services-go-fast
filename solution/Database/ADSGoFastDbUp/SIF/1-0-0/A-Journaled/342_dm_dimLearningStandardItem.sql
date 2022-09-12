DROP VIEW IF EXISTS  dm.vw_LearningStandardInfo;
GO

CREATE VIEW  dm.dimLearningStandardInfo
AS

SELECT 
   	  LearningStandardKey
	,   StandardSettingBodyCountryCode
	,   StandardSettingBodyStateBodyName
	,   StandardSettingBodyStateProvince
	,   StandardHierarchyLevelNumber
	,   StandardHierarchyLevelDescription
	,   PredecessorItemKey
	,   StatementCode
	, [Statement]
	,  Level1
	,   Level2
	,   LearningStandardDocumentKey
	, SubjectArea 
 FROM dbo.vw_LearningStandardItem