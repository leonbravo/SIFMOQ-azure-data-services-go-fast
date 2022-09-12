using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using WebApplication.Forms.PIAWizard;

namespace WebApplication.Models.Forms
{
    public class PIAForm
    {
        public int SubjectAreaId { get; set; } // Database row id
        public int Step { get; set; } // Last submitted step
        public int MaxStep { get; set; } // Furthest page reached in wizard
        public int SubmissionMethod { get; set; } // 0: Save-only, 1: Next
        public PublicPrivateDataSet DataSetPrivacyStatus { get; set; } 

        public bool AuthorisedByDataSubjects { get; set; }
        public bool DataAgreementsSigned { get; set; }
        public string DataAgreementsLocation { get; set; }
        public bool UnderstandMetadata { get; set; }
        public bool AcceptResponsibility { get; set; }

        public string BelongingDatasetCode { get; set; } 
        public string BelongingDataset { get; set; } // name of associated subject area code

        public Guid? SiteId { get; set; }
        public string DataSourceLocation { get; set; }
        public int? OwningSystem { get; set; }
        public string SystemDataLocation { get; set; }
        public string SystemPurposeVersion { get; set; }
        public string SiteName { get; set; }
        public string SourceSystemName { get; set; }
        public string SystemPurposeVersionNumber { get; set; }

        public string DataSetDescription { get; set; }
        public string SupportingDocumentationLocation { get; set; }
        public PersonalDeIdentified DataPersonalOrDeIdentified { get; set; }
        public SuppressionRuleOptions SuppressionRuleOne { get; set; }
        public string SuppressionRuleOneExpl { get; set; }
        public SuppressionRuleOptions SuppressionRuleTwo { get; set; }
        public string SuppressionRuleTwoExpl { get; set; }
        public SuppressionRuleOptions SuppressionRuleThree { get; set; }
        public string SuppressionRuleThreeExpl { get; set; }
        public SuppressionRuleOptions SuppressionRuleFour { get; set; }
        public string SuppressionRuleFourExpl { get; set; }
        public bool IdentifiedDataCustodianManagedRisk { get; set; }
        public string DataRiskManagementExplanation { get; set; }

        public FormOfData DataForm { get; set; }
        public InformationLevelData InfoLevelOfData { get; set; }
        public InformationLevelVariable InfoLevelOfVariable { get; set; }
        public IList<Properties> TopThreePropsOfData { get; set; } = new List<Properties>();

        public bool IsDataQualityLevelHigh { get; set; }
        public string DataQualityExplanation { get; set; }
        public bool IsDataAboutVulnerablePopulation { get; set; }
        public string PopulationVulnerabilityExplanation { get; set; }
        public DateTime? WhenDataWasCollected { get; set; }
        public string DataTimeCollectedExplanation { get; set; }
        public bool IsDataHierarchical { get; set; }
        public string DataHierarchicalExplanation { get; set; }
        public bool IsDataTimeStamped { get; set; }
        public string DataTimestampedExplanation { get; set; }

        public UserReference DataOwner { get; set; } 
        public UserReference DataCustodian { get; set; }
        public IList<UserReference> DataStewards { get; set; } = new List<UserReference>();
        public IList<UserReference> ExternalUsers { get; set; } = new List<UserReference>();

        public BinaryOrNa RespectDataAssurances { get; set; }
        public string DataAssuranceExplanation { get; set; }
        public BinaryOrNa HasProvidedTransparency { get; set; }
        public string ProvidedTransparencyExplanation { get; set; }
        public BinaryOrNa HasObtainedSubjectsViews { get; set; }
        public string SubjectsViewsExplanation { get; set; }

        public bool HasInitialSpecification { get; set; }
        public IList<Specifications> TopLevelAssessment { get; set; } = new List<Specifications>();
        public string DataComplexityExpl { get; set; }
        public string SensitiveVariableExpl { get; set; }
        public string DetailedVariableExpl { get; set; }
        public string AnalysisExplanation { get; set; }
        public IList<Properties> DataAnalyticalApproaches { get; set; } = new List<Properties>();
        public bool PreparationTesting { get; set; }
        public string PenetrationTestingExplanation { get; set; }

        public IList<EnvironmentReconfigurations> ReconfigureEnvironment { get; set; } = new List<EnvironmentReconfigurations>();
        public string ExplanationReconfigureEnvirontment { get; set; }
        public IList<DataModification> ModifyingData { get; set; } = new List<DataModification>();
        public string ExplanationModifyingDataOptions { get; set; }

        public IList<DataBreachImpactManagement> ImpactManagementReductionOptions { get; set; }  = new List<DataBreachImpactManagement>();
        public string ImpactManagementExplanation { get; set; }
        public string ImpactManagementOtherOption { get; set; } // remove
        public IList<StakeholderAssuranceProtection> StakeholdersAssurance { get; set; } = new List<StakeholderAssuranceProtection>();
        public string StakeholderAssuranceExplanation { get; set; }
        public IList<DataBreachPlan> PlanForDataBreachProcess { get; set; } = new List<DataBreachPlan>();
        public string DataBreachPlanExplanation { get; set; }


        public static readonly JsonSerializerSettings JsonSettings = new JsonSerializerSettings
        {
            ObjectCreationHandling = ObjectCreationHandling.Replace,
            NullValueHandling = NullValueHandling.Ignore,
            MissingMemberHandling = MissingMemberHandling.Ignore,
        };

    }

}
