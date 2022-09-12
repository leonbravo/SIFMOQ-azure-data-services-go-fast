
Declare @path varchar(200);

SET @path= $(RelativePath)+'/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**';

declare @statement varchar(max) =
'CREATE VIEW dbo.vw_TeachingGroup_Period
AS
SELECT DISTINCT
    TG.RefId,
    PeriodList.DayId,
    PeriodList.PeriodId
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH(
    RefId VARCHAR(50),
    TeachingGroupPeriodList VARCHAR(MAX)   
) AS TG
CROSS APPLY OPENJSON(TG.TeachingGroupPeriodList,''$.TeachingGroupPeriod'')
        WITH (
        DayId VARCHAR(3),
        PeriodId INT,
        id int ''$.sql:identity()''
    ) as PeriodList'
;

execute (@statement)
;
GO