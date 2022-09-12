--DROP VIEW IF EXISTS [dm].[dimStaff]
CREATE VIEW [dm].[dimStaff]
AS
SELECT
	[RefId] as StaffKey
	, [LocalId] as StaffId
	, [StateProvinceId]
	, [FirstName]       
	, [LastName]        
	, [MiddleName]  
	, [FirstName] + ISNULL([MiddleName], ' ') + [LastName] AS [StaffName]      
	, [Title]
	, cast(json_value([OtherNames],'$.Name[0].Type') as varchar(255)) OtherNameType1
	, cast(json_value([OtherNames],'$.Name[0].FamilyName') as varchar(255)) OtherNameFamilyName1
	, cast(json_value([OtherNames],'$.Name[0].GivenName') as varchar(255)) OtherNameGivenName1
	, cast(json_value([OtherNames],'$.Name[0].FullName') as varchar(255)) OtherNameFullName1
	, cast(json_value([OtherNames],'$.Name[1].Type') as varchar(255)) OtherNameType2
	, cast(json_value([OtherNames],'$.Name[1].FamilyName') as varchar(255)) OtherNameFamilyName2
	, cast(json_value([OtherNames],'$.Name[1].GivenName') as varchar(255)) OtherNameGivenName2
	, cast(json_value([OtherNames],'$.Name[1].FullName') as varchar(255)) OtherNameFullName2
	, [EmploymentStatus]
	, cast([IndigenousStatus] as smallint) as [IndigenousStatus]
	, [Sex]
	, cast([BirthDate] as date) as [BirthDate]
	, cast([DateOfDeath] as date) as [DateOfDeath]
	, [Deceased]
	, [BirthDateVerification]
	, [PlaceOfBirth]
	, [StateOfBirth]
	, [CountryOfBirth]
	, cast(json_value([CountryOfCitizenship],'$.CountryOfCitizenship[0]') as varchar(50)) CountryOfCitizenship
	, cast(json_value([CountryOfCitizenship],'$.CountryOfCitizenship[1]') as varchar(50)) CountryOfCitizenship2
	, cast(json_value([CountryOfResidency],'$.CountryOfResidency[0]') as varchar(50)) CountryOfResidency
	, cast(json_value([CountryOfResidency],'$.CountryOfResidency[1]') as varchar(50)) CountryOfResidency2
	, cast([CountryArrivalDate] as date) as [CountryArrivalDate]
	, [AustralianCitizenshipStatus]
	, cast([EnglishProficiency] as smallint) as [EnglishProficiency]
	, cast(json_value([LanguageList],'$.Language[0].Code') as varchar(50)) as MainLanguageSpokenAtHome
	, cast(json_value([LanguageList],'$.Language[1].Code') as varchar(50)) as SecondLanguage
	, cast(json_value([LanguageList],'$.Language[2].Code') as varchar(50)) as OtherLanguage
	, [DwellingArrangement]
	, [Religion]
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[0].Type') as varchar(50)) as ReligionEvent1
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[0].Date') as date) as ReligionEvent1Date
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[1].Type') as varchar(50)) as ReligionEvent2
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[1].Date') as date) as ReligionEvent2Date
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[2].Type') as varchar(50)) as ReligionEvent3
	, cast(json_value([ReligiousEventList],'$.ReligiousEvent[2].Date') as date) as ReligionEvent3Date
	, [ReligiousRegion]
	, [PermanentResident]
	, [VisaSubClass]
	, [VisaStatisticalCode]
	, cast(json_value([AddressList],'$.Address[0].Type') as varchar(50)) as AddressType1
	, cast(json_value([AddressList],'$.Address[0].Role') as varchar(50)) as AddressRole1
	, cast(json_value([AddressList],'$.Address[0].Street.Line1') as varchar(255)) as AddressStreet1Line1
	, cast(json_value([AddressList],'$.Address[0].Street.Line2') as varchar(255)) as AddressStreet1Line2
	, cast(json_value([AddressList],'$.Address[0].City') as varchar(255)) as AddressCity1
	, cast(json_value([AddressList],'$.Address[0].StateProvince') as varchar(255)) as AddressStateProvince1
	, cast(json_value([AddressList],'$.Address[0].Country') as varchar(255)) as AddressCountry1
	, cast(json_value([AddressList],'$.Address[0].PostalCode') as varchar(255)) as AddressPostalCode1
	, cast(json_value([AddressList],'$.Address[1].Type') as varchar(50)) as AddressType2
	, cast(json_value([AddressList],'$.Address[1].Role') as varchar(50)) as AddressRole2
	, cast(json_value([AddressList],'$.Address[1].Street.Line1') as varchar(255)) as AddressStreet2Line1
	, cast(json_value([AddressList],'$.Address[1].Street.Line2') as varchar(255)) as AddressStreet2Line2
	, cast(json_value([AddressList],'$.Address[1].City') as varchar(255)) as AddressCity2
	, cast(json_value([AddressList],'$.Address[1].StateProvince') as varchar(255)) as AddressStateProvince2
	, cast(json_value([AddressList],'$.Address[1].Country') as varchar(255)) as AddressCountry2
	, cast(json_value([AddressList],'$.Address[1].PostalCode') as varchar(255)) as AddressPostalCode2
	, cast(json_value([EmailList],'$.Email[0].Type') as varchar(2)) as TypeEmail1Description
	, cast(json_value([EmailList],'$.Email[0].value') as varchar(50)) as TypeEmail1
	, cast(json_value([EmailList],'$.Email[1].Type') as varchar(2)) as TypeEmail2Description
	, cast(json_value([EmailList],'$.Email[1].value') as varchar(50)) as TypeEmail2
	, cast(json_value([PhoneNumberList],'$.PhoneNumber[0].Type') as varchar(2)) as Telephone1TypeDescription
	, cast(json_value([PhoneNumberList],'$.PhoneNumber[0].Number') as varchar(50)) as Telephone1
	, cast(json_value([PhoneNumberList],'$.PhoneNumber[1].Type') as varchar(2)) as Telephone2TypeDescription
	, cast(json_value([PhoneNumberList],'$.PhoneNumber[1].Number') as varchar(50)) as Telephone2
FROM [dbo].[vw_StaffPersonal];


