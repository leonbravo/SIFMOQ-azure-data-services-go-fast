Declare @path varchar(200);

SET @path= $(RelativePath)+'/LearningStandardItem/LearningStandardItem/Snapshot/LearningStandardItem/**';
 
declare @statement varchar(max) =
'CREATE VIEW dbo.vw_LearningStandardItem
AS
SELECT
	RefId  LearningStandardKey
	, JSON_VALUE(StandardSettingBody,''$.Country'')  StandardSettingBodyCountryCode
	, JSON_VALUE(StandardSettingBody,''$.SettingBodyName'')  StandardSettingBodyStateBodyName
	, JSON_VALUE(StandardSettingBody,''$.StateProvince'')  StandardSettingBodyStateProvince
	, JSON_VALUE(StandardHierarchyLevel,''$.Number'')  StandardHierarchyLevelNumber
	, JSON_VALUE(StandardHierarchyLevel,''$.Description'')  StandardHierarchyLevelDescription
	, JSON_VALUE(PredecessorItems,''$.LearningStandardItemRefId[0]'')  PredecessorItemKey
	, JSON_VALUE(StatementCodes,''$.StatementCode[0]'')  StatementCode
	, JSON_VALUE(Statements,''$.Statement[0]''     )  [Statement]
	, JSON_VALUE(YearLevels,''$.YearLevel[0].Code'')  Level1
	, JSON_VALUE(YearLevels,''$.YearLevel[1].Code'')  Level2
	, LearningStandardDocumentRefId  LearningStandardDocumentKey
	,JSON_VALUE(StandardIdentifier, ''$.ACStrandSubjectArea.SubjectArea.Code'') SubjectArea
FROM
   OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) WITH(
	
  [RefId] varchar(50),
  [StandardSettingBody] varchar(255),
  [StandardHierarchyLevel] varchar(255) ,
  [PredecessorItems] varchar(255),
  [StatementCodes] varchar(255) ,
  [Statement] varchar(255),
  [Statements] varchar(1000),
  [YearLevels] varchar(255),
  [LearningStandardDocumentRefId] varchar(50),
    [StandardIdentifier] varchar(MAX)
)
    AS [result]';

execute (@statement)
;
GO



