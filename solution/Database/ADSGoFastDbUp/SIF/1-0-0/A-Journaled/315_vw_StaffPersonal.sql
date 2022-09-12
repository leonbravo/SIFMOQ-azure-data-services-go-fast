Declare @path varchar(200);

SET @path= $(RelativePath)+'/StaffPersonal/StaffPersonal/Snapshot/StaffPersonal/**'

declare @statement varchar(max)
='CREATE VIEW  [dbo].[vw_StaffPersonal]
AS
SELECT
	*
FROM
OPENROWSET(
BULK ''' + @path+ ''',
DATA_SOURCE =''sif_eds'',
FORMAT=''PARQUET''
) WITH (
	[RefId] varchar(50)
	, [LocalId] varchar(50)
	, [StateProvinceId] varchar(20)
	, [FirstName] varchar(255) ''$.PersonInfo.Name.GivenName''	
	, [LastName] varchar(255) ''$.PersonInfo.Name.FamilyName''	
	, [MiddleName] varchar(255)
	, [OtherNames] varchar(max)  ''$.PersonInfo.OtherNames''
	, [EmploymentStatus] varchar(1)
	, [Title] varchar(50)
	, [IndigenousStatus] varchar(255)  ''$.PersonInfo.Demographics.IndigenousStatus''
	, [Sex] varchar(10) ''$.PersonInfo.Demographics.Sex''
	, [BirthDate] varchar(255) ''$.PersonInfo.Demographics.BirthDate''
	, [DateOfDeath] varchar(255) ''$.PersonInfo.Demographics.DateOfDeath''
	, [Deceased] varchar(255) ''$.PersonInfo.Demographics.Deceased''
	, [BirthDateVerification] varchar(50) ''$.PersonInfo.Demographics.BirthDateVerification''
	, [PlaceOfBirth] varchar(50) ''$.PersonInfo.Demographics.PlaceOfBirth''
	, [StateOfBirth] varchar(50) ''$.PersonInfo.Demographics.StateOfBirth''
	, [CountryOfBirth ] varchar(50) ''$.PersonInfo.Demographics.CountryOfBirth''
	, [CountryOfCitizenship ] varchar(max) ''$.PersonInfo.Demographics.CountriesOfCitizenship''
	, [CountryOfResidency] varchar(max) ''$.PersonInfo.Demographics.CountriesOfResidency''
	, [CountryArrivalDate] varchar(255) ''$.PersonInfo.Demographics.CountryArrivalDate''
	, [AustralianCitizenshipStatus] varchar(255) ''$.PersonInfo.Demographics.AustralianCitizenshipStatus''
	, [EnglishProficiency]          varchar(255) ''$.PersonInfo.Demographics.EnglishProficiency.Code''
	, [LanguageList]                varchar(max) ''$.PersonInfo.Demographics.LanguageList''
	, [DwellingArrangement]         varchar(50)  ''$.PersonInfo.Demographics.DwellingArrangement.Code''
	, [Religion]                    varchar(50)  ''$.PersonInfo.Demographics.Religion.Code''
	, [ReligiousEventList]          varchar(max) ''$.PersonInfo.Demographics.ReligiousEventList''
	, [ReligiousRegion]             varchar(50)  ''$.PersonInfo.Demographics.ReligiousRegion''
	, [PermanentResident]           varchar(255) ''$.PersonInfo.Demographics.PermanentResident''
	, [VisaSubClass]                varchar(255) ''$.PersonInfo.Demographics.VisaSubClass''
	, [VisaStatisticalCode]         varchar(5)   ''$.PersonInfo.Demographics.VisaStatisticalCode''
	, [EmailList]                   varchar(max) ''$.PersonInfo.EmailList''
	, [PhoneNumberList]             varchar(max) ''$.PersonInfo.PhoneNumberList''
	, [AddressList]                 varchar(max) ''$.PersonInfo.AddressList''
)
AS [SP]'

execute (@statement)