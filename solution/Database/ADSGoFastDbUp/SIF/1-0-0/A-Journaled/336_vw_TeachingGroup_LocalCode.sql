
DROP VIEW IF EXISTS dbo.vw_TeachingGroup_LocalCode;
GO

CREATE VIEW dbo.vw_TeachingGroup_LocalCode
AS
SELECT DISTINCT
    TG.RefId,
    LC.LocalisedCode,
    LC.Description,
    LC.Element
FROM OPENROWSET(
BULK 'samples/sif/TeachingGroup/TeachingGroup/Snapshot/TeachingGroup/**',
DATA_SOURCE ='sif_eds',
FORMAT='PARQUET'
) 
WITH(
    RefId VARCHAR(50),
    LocalCodeList VARCHAR(MAX)   
) AS TG
CROSS APPLY OPENJSON(TG.LocalCodeList,'$.LocalCode')
        WITH (
        LocalisedCode VARCHAR(20),
        Description VARCHAR(255),
        Element  VARCHAR(255),
        id int '$.sql:identity()'
    ) as LC
;

-- SELECT * FROM vw_TeachingGroup_LocalCode
