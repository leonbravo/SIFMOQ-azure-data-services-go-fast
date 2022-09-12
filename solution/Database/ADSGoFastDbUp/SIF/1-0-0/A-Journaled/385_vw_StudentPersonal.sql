Declare @path varchar(200);

SET @path= $(RelativePath)+'/StudentPersonal/StudentPersonal/Snapshot/StudentPersonal/**';

declare @statement varchar(max) =
'CREATE VIEW  [dbo].[vw_StudentPersonal]
AS
SELECT
	*
FROM
    OPENROWSET(
    BULK  '''+@path+''',
	DATA_SOURCE =''sif_eds'',
    FORMAT=''PARQUET''
)  WITH (
	[RefId] varchar(50)
	, [LocalId] varchar(50)
	, [StateProvinceId] varchar(20)
	, [NationalUniqueStudentIdentifier] varchar(50)
	, [AlertMessages] varchar(max)  '$.AlertMessages'
	, [MedicalAlertMessages] varchar(max) '$.MedicalAlertMessages'
	, [FirstName] varchar(255) '$.PersonInfo.Name.GivenName'	
	, [LastName] varchar(255) '$.PersonInfo.Name.FamilyName'	
	, [MiddleName] varchar(255)
	, [OtherNames] varchar(max)  '$.PersonInfo.OtherNames'
	, [ProjectedGraduationYear] varchar(4)
	, [OnTimeGraduationYear] varchar(4)
	, [GraduationDate] varchar(20)
	, [MostRecent] varchar(max)  '$.MostRecent'
	, [AcceptableUsePolicy] varchar(2)
	, [GiftedTalented] varchar(2)
	, [EconomicDisadvantage] varchar(2)
	, [ESL] varchar(2)
	, [ESLDateAssessed] varchar(20)
	, [YoungCarersRole] varchar(2)
	, [Disability] varchar(2)
	, [IntegrationAide] varchar(2)
	, [EducationSupport] varchar(2)
	, [HomeSchooledStudent] varchar(2)
	, [IndependentStudent] varchar(2)
	, [Sensitive] varchar(2)
	, [OfflineDelivery] varchar(2)
	, [ESLSupport] varchar(2)
	, [PrePrimaryEducation] varchar(50)
	, [PrePrimaryEducationHours] varchar(2)
	, [FirstAUSchoolEnrollment] varchar(20)
	, [EmailList] varchar(max)       ''$.PersonInfo.EmailList''
	, [PhoneNumberList] varchar(max) ''$.PersonInfo.PhoneNumberList''
	, [AddressList] varchar(max)     ''$.PersonInfo.AddressList''
	, [IndigenousStatus] varchar(255)  ''$.PersonInfo.Demographics.IndigenousStatus''
	, [Sex] varchar(10)                ''$.PersonInfo.Demographics.Sex''
	, [BirthDate] varchar(255)         ''$.PersonInfo.Demographics.BirthDate''
	, [DateOfDeath] varchar(255)        ''$.PersonInfo.Demographics.DateOfDeath''
	, [Deceased] varchar(255)            ''$.PersonInfo.Demographics.Deceased''
	, [BirthDateVerification] varchar(50) ''$.PersonInfo.Demographics.BirthDateVerification''
	, [PlaceOfBirth] varchar(50) ''$.PersonInfo.Demographics.PlaceOfBirth''
	, [StateOfBirth] varchar(50) ''$.PersonInfo.Demographics.StateOfBirth''
	, [CountryOfBirth ] varchar(50) ''$.PersonInfo.Demographics.CountryOfBirth''
	, [CountryOfCitizenship ] varchar(max) ''$.PersonInfo.Demographics.CountriesOfCitizenship''
	, [CountryOfResidency] varchar(max) ''$.PersonInfo.Demographics.CountriesOfResidency''
	, [CountryArrivalDate] varchar(255) ''$.PersonInfo.Demographics.CountryArrivalDate''
	, [AustralianCitizenshipStatus] varchar(255) ''$.PersonInfo.Demographics.AustralianCitizenshipStatus''
	, [EnglishProficiency] varchar(255) ''$.PersonInfo.Demographics.EnglishProficiency.Code''
	, [LanguageList] varchar(max)       ''$.PersonInfo.Demographics.LanguageList''
	, [DwellingArrangement] varchar(50) ''$.PersonInfo.Demographics.DwellingArrangement.Code''
	, [Religion] varchar(50)            ''$.PersonInfo.Demographics.Religion.Code''
	, [ReligiousEventList] varchar(max) ''$.PersonInfo.Demographics.ReligiousEventList'
	, [ReligiousRegion] varchar(50)     ''$.PersonInfo.Demographics.ReligiousRegion''
	, [PermanentResident] varchar(255)  ''$.PersonInfo.Demographics.PermanentResident''
	, [VisaSubClass] varchar(255)       ''$.PersonInfo.Demographics.VisaSubClass''
	, [VisaStatisticalCode] varchar(5)  ''$.PersonInfo.Demographics.VisaStatisticalCode''
	, [VisaSubClassList] varchar(max)   ''$.PersonInfo.Demographics.VisaSubClassList''
	, [PassportList] varchar(max)       ''$.PersonInfo.Demographics.Passport''
	, [LBOTE] varchar(20)
	, [InterpreterRequired]  varchar(2)
	, [ImmunisationCertificateStatus]  varchar(50)
	, [CulturalBackground] varchar(50)
	, [MaritalStatus] varchar(50)
	, [MedicareNumber]  varchar(20)
	, [MedicarePositionNumber] varchar(2)
	, [MedicareCardHolderName] varchar(50)
	, [PrivateHealthInsurance] varchar(50)
)
AS [SP]';

execute (@statement)
;
GO

