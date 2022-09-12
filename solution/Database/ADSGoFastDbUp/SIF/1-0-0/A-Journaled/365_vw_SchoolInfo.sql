Declare @path varchar(200);

SET @path= $(RelativePath)+'/SchoolInfo/SchoolInfo/Snapshot/SchoolInfo/*' ;
declare @statement varchar(max) =
'
CREATE VIEW [dbo].[vw_SchoolInfo]
AS
SELECT 
	[RefId] AS [SchoolInfoKey]
	, [LocalId] AS [SchooldInfoId]
	, [StateProvinceId]
	, [CommonwealthId]
	, [ParentCommonwealthId]
    , [ACARAId]
	, [SchoolName]
	, [LEAInfoRefId]
    , JSON_VALUE([OtherLEA], ''$.value'') AS [OtherLEAId] 
    , JSON_VALUE([OtherLEA], ''$.SIF_RefObject'') AS [SIF_RefObject]
    , [SchoolDistrict]
    , [SchoolDistrictId]
    , [SchoolType]
    , [SchoolURL]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.Type'') AS [PrincipalInfoType]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.Title'') AS [PrincipalInfoTitle]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.FamilyName'') AS [PrincipalInfoFamilyName]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.GivenName'') AS [PrincipalInfoGivenName]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.MiddleName'') AS [PrincipalInfoMiddleName]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.Suffix'') AS [PrincipalInfoSuffix]
    , JSON_VALUE([PrincipalInfo], ''$.ContactName.FullName'') AS [PrincipalInfoFullName]
    , JSON_VALUE([PrincipalInfo], ''$.ContactTitle'') AS [PrincipalInfoContactTitle]
    , JSON_VALUE([PhoneNumberList], ''$.PhoneNumber[0].Number'') AS [Telephone1]
    , JSON_VALUE([PhoneNumberList], ''$.PhoneNumber[0].Type'') AS [Telephone1TypeDescription]
    , JSON_VALUE([PhoneNumberList], ''$.PhoneNumber[1].Number'') AS [Telephone2]
    , JSON_VALUE([PhoneNumberList], ''$.PhoneNumber[1].Type'') AS [Telephone2TypeDescription]
    , [SessionType]
    , [ARIA]
    , [OperationalStatus]
    , [FederalElectorate]
    , [SchoolSector]
    , [IndependentSchool]
    , [NonGovSystemicStatus]
    , [System] AS [SchoolSystemType]
    , [ReligiousAffiliation] AS [ReligiousAfiliationGroup]
    , [SchoolGeographicLocation]
    , [LocalGovernmentArea]
    , [JurisdictionLowerHouse]
    , [SLA]
    , [SchoolCoEdStatus]
    , [BoardingSchoolStatus]
    , [EntityOpen]
    , [EntityClose]
    , [SchoolTimeZone]
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
) 
WITH (
    [RefId] VARCHAR(36) ,	
    [LocalId] VARCHAR(50)  ,
    [StateProvinceId] VARCHAR(50)  ,
    [CommonwealthId] VARCHAR(50)  ,
    [ParentCommonwealthId] VARCHAR(50)  ,
    [ACARAId] VARCHAR(50)  ,					
    [SchoolName] VARCHAR(255)  ,
    [LEAInfoRefId] VARCHAR(50)  ,	
    [OtherLEA] VARCHAR(100)  ,	
    [SIF_RefObject] VARCHAR(7)  ,	
    [SchoolDistrict] VARCHAR(255)  ,	
    [SchoolDistrictId] VARCHAR(50)  ,	
    [SchoolType] VARCHAR(255)  ,	
    [SchoolURL] VARCHAR(1000)  ,	
    [PrincipalInfo] VARCHAR(1000)  ,	
    [PhoneNumberList] VARCHAR(1000)  ,		
    [SessionType] VARCHAR(4)  ,	
    [ARIA] VARCHAR (10),	
    [OperationalStatus] VARCHAR(1)  ,	
    [FederalElectorate] VARCHAR(3)  ,	
    [SchoolSector] VARCHAR(3)  ,	
    [IndependentSchool] VARCHAR(1)  ,	
    [NonGovSystemicStatus] VARCHAR(1)  ,	
    [System] VARCHAR(4)  ,	
    [ReligiousAffiliation] VARCHAR(4)  ,	
    [SchoolGeographicLocation] VARCHAR(10)  ,	
    [LocalGovernmentArea] VARCHAR(255)  ,	
    [JurisdictionLowerHouse] VARCHAR(255)  ,	
    [SLA] VARCHAR(10)  ,	
    [SchoolCoEdStatus] VARCHAR(1)  ,	
    [BoardingSchoolStatus] VARCHAR(1)  ,	
    [EntityOpen] VARCHAR(10)  ,	
    [EntityClose] VARCHAR(10)  ,	
    [SchoolTimeZone] VARCHAR(10)  
) 
AS [result]';

execute (@statement)
;
GO



