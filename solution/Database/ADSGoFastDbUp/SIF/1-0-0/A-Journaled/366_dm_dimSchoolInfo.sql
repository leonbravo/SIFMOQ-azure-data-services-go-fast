
DROP VIEW IF EXISTS [dm].[dimSchoolInfo];
GO

CREATE VIEW [dm].[dimSchoolInfo]
AS
SELECT 
	 [SchoolInfoKey]
	,  [SchooldInfoId]
	, [StateProvinceId]
	, [CommonwealthId]
	, [ParentCommonwealthId]
    , [ACARAId]
	, [SchoolName]
	, [LEAInfoRefId]
    , [OtherLEAId] 
    ,  [SIF_RefObject]
    , [SchoolDistrict]
    , [SchoolDistrictId]
    , [SchoolType]
    , [SchoolURL]
    , [PrincipalInfoType]
    ,  [PrincipalInfoTitle]
    ,  [PrincipalInfoFamilyName]
    ,  [PrincipalInfoGivenName]
    ,  [PrincipalInfoMiddleName]
    ,  [PrincipalInfoSuffix]
    ,  [PrincipalInfoFullName]
    , [PrincipalInfoContactTitle]
    , [Telephone1]
    , [Telephone1TypeDescription]
    , [Telephone2]
    ,  [Telephone2TypeDescription]
    , [SessionType]
    , [ARIA]
    , [OperationalStatus]
    , [FederalElectorate]
    , [SchoolSector]
    , [IndependentSchool]
    , [NonGovSystemicStatus]
    , [SchoolSystemType]
    ,  [ReligiousAfiliationGroup]
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
[dbo].[vw_SchoolInfo]
GO



