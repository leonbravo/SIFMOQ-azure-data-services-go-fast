using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using WebApplication.Extensions;
using WebApplication.Forms;
using WebApplication.Forms.PIAWizard;
using WebApplication.Framework;
using WebApplication.Models.Forms;
using WebApplication.Models.ValidationAttributes;

namespace WebApplication.Models.Wizards
{
    public partial class PIAWizardViewModel : IValidatableObject
    {
        public int SubjectAreaId { get; set; } // Database row id
        public int Step { get; set; } // Last submitted step
        public int MaxStep { get; set; } // Furthest page reached in wizard
        public int SubmissionMethod { get; set; } // 0: Save-only, 1: Next
        public string BelongingDataset { get; set; }
        public string BelongingDatasetCode { get; set; } // subject area code
        
        [Display(Name = "Is this data set private or public?")]
        [Required]
        public PublicPrivateDataSet DataSetPrivacyStatus { get; set; }

        #region Introduction

        [Display(Name = "1. Are you authorised to use this data?")]
        [Required]
        [MustBeTrue]
        public bool AuthorisedByDataSubjects { get; set; }

        [Display(Name = "2. Have the appropriate data agreements been signed?")]
        [Required]
        [MustBeTrue]
        public bool DataAgreementsSigned { get; set; }

        [Display(Name = "2a. Where are these data agreements stored? Provide a location (i.e. file path)")]
        [Required]
        public string DataAgreementsLocation { get; set; }

        [Display(Name = "3. Do you understand that the metadata associated with this data set will be searchable?")]
        [Required]
        [MustBeTrue]
        public bool UnderstandMetadata { get; set; }

        [Display(Name = "4. Do you accept responsibility for this PIA process and the truthfulness of the responses?")]
        [Required]
        [MustBeTrue]
        public bool AcceptResponsibility { get; set; }

        [Display(Name = "5. Provide a description of the data set being referred to")]
        [Required(ErrorMessage = "This field is required")]
        public string DataSetDescription { get; set; }

        [Display(Name = "6. To which site does the Dataset belong?")]
        public Guid? SiteId { get; set; }

        [Display(Name = "6a. Please provide the source of the data from where it was captured?")]
        [Required(ErrorMessage = "This field is required")]
        public string DataSourceLocation { get; set; }

        // dropdown of all extraction tools
        [Display(Name = "7. Under what storage system is the data set being taken from?")]
        [Required(ErrorMessage = "This field is required")]
        public int? OwningSystem { get; set; } // source system

        [Display(Name = "7a. What is the specific location from within the system where the data is obtained?")]
        [Required(ErrorMessage = "This field is required")]
        public string SystemDataLocation { get; set; }

        

        /// <summary>
        /// 4 fields - first 2 are auto generated based on previous 2 (5. and 6.)
        /// When parsing data from model, combine the names of 5. + 6. + 7. + version number
        /// joined together using an underscore as a separator, to a single value "System purpose version"
        /// </summary>        
        [Display(Name = "8. Identifier")]
        public string SystemPurposeVersion { get; set; }
        public string SiteName { get; set; }
        [Required(ErrorMessage = "This field is required")]
        public string SourceSystemName { get; set; }
        [Required(ErrorMessage = "This field is required")]
        public string SystemPurposeVersionNumber { get; set; }

        public Site Site { get; set; } = new Site();
        public string SystemPurposeVersionFullName => $"{ Site.Name }_{ SourceSystemName }_{ SystemPurposeVersion }_{ SystemPurposeVersionNumber }";

        #endregion

        #region Data subjects

        [Display(Name = "9. Data Owner")]
        [Required]
        public UserReference DataOwner { get; set; } = new UserReference();

        [Display(Name = "10. Data Custodian")] // only 1
        [Required]
        public UserReference DataCustodian { get; set; } = new UserReference();

        [Display(Name = "11. Data Stewards")] // can have multiple
        public IList<UserReference> DataStewards { get; set; } = new List<UserReference>() { new UserReference() };

        [Display(Name = "External Users with Reader Access")]
        public IList<UserReference> ExternalUsers { get; set; } = new List<UserReference>();

        #endregion

        #region Understand your legal responsibility

        [Display(Name = "12. Provide the location where additional documentation can be found for this data such as a link to a document library or a reference to a location in a document management system")]
        [Required(ErrorMessage = "This field is required")]
        public string SupportingDocumentationLocation { get; set; }


        [Display(Name = "13. Is the data personal information or de-identified data?")]
        [Required(ErrorMessage = "This field is required")]
        public PersonalDeIdentified DataPersonalOrDeIdentified { get; set; }

        [Display(Name = "14. Suppress both numerator and denominator if either or both of these in a row contain a number greater than 10 (to prevent back calculation), but don’t suppress the proportion")]
        public SuppressionRuleOptions SuppressionRuleOne { get; set; }

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string SuppressionRuleOneExpl { get; set; }

        [Display(Name = "15. If and when the count of a particular cell is less than 10, is the suppression only applied to that row?")]
        public SuppressionRuleOptions SuppressionRuleTwo { get; set; }

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string SuppressionRuleTwoExpl { get; set; }

        [Display(Name = "16. Are precautionary measures taken for at-risk populations by aggregating age groups (i.e. age groupings 0 – 4 and or 5 -14 are aggregated into < 15 years) and gender – merging (Indeterminate/Intersex/Unspecified/Not stated/Inadequately described) to Sex X?")]
        public SuppressionRuleOptions SuppressionRuleThree { get; set; }

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string SuppressionRuleThreeExpl { get; set; }

        [Display(Name = "17. If you find zeros for Sex X (Indeterminate/Intersex/Unspecified/Not stated/Inadequately described) for any QIM, please merge all age groups and Indigenous status for Sex X to see if there is any valid number (again rule 1 and 2 applies)")]
        public SuppressionRuleOptions SuppressionRuleFour { get; set; }

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string SuppressionRuleFourExpl { get; set; }

        [Display(Name = "18. Do privacy obligations still apply to de-identified data? Have you identified and documented how the data custodian should manage such a risk, while still using de-identified data in the ways that it is legally permitted to use it?")]
        public bool IdentifiedDataCustodianManagedRisk { get; set; }
        [Display(Name = "18a. How will risks be managed?")]
        [StringLength(400)]
        public string DataRiskManagementExplanation { get; set; }

        #endregion

        #region Data Metadata

        [Display(Name = "19. What form is your data in?")]
        [Required(ErrorMessage = "This field is required")]
        public FormOfData DataForm { get; set; }

        [Display(Name = "20. What level of information about the population does the data provide?")]
        [Required(ErrorMessage = "This field is required")]
        public InformationLevelData InfoLevelOfData { get; set; }

        [Display(Name = "21. What level of information about the population does the data provide?")]
        [Required(ErrorMessage = "This field is required")]
        public InformationLevelVariable InfoLevelOfVariable { get; set; }

        [Display(Name = "22. For the fields listed, what are the main subject areas the data set contains (Select all the apply)?")] // change validation
        public InputSelectionOptionsFor<Properties> TopThreePropsOfData { get; set; } = new InputSelectionOptionsFor<Properties>();

        [Display(Name = "23. Is the data quality high?")]
        [Required(ErrorMessage = "This field is required")]
        public bool IsDataQualityLevelHigh { get; set; }
        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string DataQualityExplanation { get; set; }

        [Display(Name = "24. Is the data about a vulnerable population?")]
        [Required(ErrorMessage = "This field is required")]
        public bool IsDataAboutVulnerablePopulation { get; set; }
        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string PopulationVulnerabilityExplanation { get; set; }

        [Display(Name = "25. When was the data collected?")]
        [DataType(DataType.Date)]
        [Required(ErrorMessage = "This field is required")]
        public DateTime? WhenDataWasCollected { get; set; }
        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string DataTimeCollectedExplanation { get; set; }

        [Display(Name = "26. Is the data hierarchical in nature?")]
        [Required(ErrorMessage = "This field is required")]
        public bool IsDataHierarchical { get; set; }
        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string DataHierarchicalExplanation { get; set; }

        [Display(Name = "27. Is the data time-stamped?")]
        [Required(ErrorMessage = "This field is required")]
        public bool IsDataTimeStamped { get; set; }

        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string DataTimestampedExplanation { get; set; }

        #endregion

        #region Meet your ethical obligations
        
        [Display(Name = "28. Has the appropriate consent been obtained for the data set keeping in mind its intended purpose once it has been de-identified?")]
        [Required(ErrorMessage = "This field is required")]
        public BinaryOrNa RespectDataAssurances { get; set; }
        [Display(Name = "28a. Provide an explanation")]
        [StringLength(400)]
        public string DataAssuranceExplanation { get; set; }
        [Display(Name = "29. Has the appropriate level of transparency been provided on how the data can be reused?")]
        [Required(ErrorMessage = "This field is required")]
        public BinaryOrNa HasProvidedTransparency { get; set; }
        [Display(Name = "29a. Give a description of your rationale")]
        [StringLength(400)]
        public string ProvidedTransparencyExplanation { get; set; }
        [Display(Name = "30. Have the appropriate data sharing agreements or release activies been considered?")]
        [Required(ErrorMessage = "This field is required")]
        public BinaryOrNa HasObtainedSubjectsViews { get; set; }
        [Display(Name = "30a. Have  all concerns been adequately addressed?")]
        [StringLength(400)]
        public string SubjectsViewsExplanation { get; set; }

        #endregion

        #region Identify the processes you will need to go through

        [Display(Name = "31. Have you assessed the data set to an inital risk specification?")]
        public bool HasInitialSpecification { get; set; }
        [Display(Name = "32. If yes, what actions have you undertaken to reduce the level of risk? Select all that apply and provide an explanation")]
        public InputSelectionOptionsFor<Specifications> TopLevelAssessment { get; set; } = new InputSelectionOptionsFor<Specifications>();

        [Display(Name = "32a. Explanation")]
        [StringLength(400)]
        public string DataComplexityExpl { get; set; }
        [Display(Name = "32b. Explanation")]
        [StringLength(400)]
        public string SensitiveVariableExpl { get; set; }
        [Display(Name = "32c. Explanation")]
        [StringLength(400)]
        public string DetailedVariableExpl { get; set; }

        [Display(Name = "33. Review the data set and establish relevant plausible scenarios for your data situation. In mitigating a potential data breach situation consider the who, how, and why in your scenario planning. Explain? ")]
        public string AnalysisExplanation { get; set; }

        [Display(Name = "34. Data Analytical approaches considered:")]
        public InputSelectionOptionsFor<Properties> DataAnalyticalApproaches { get; set; } = new InputSelectionOptionsFor<Properties>();
        #endregion

        #region Identify the disclosure control processes that are relevant to your data situation

        [Display(Name = "35. If you need to reconfigure the environment, how would you do that?")]
        public InputSelectionOptionsFor<EnvironmentReconfigurations> ReconfigureEnvirontment { get; set; } = new InputSelectionOptionsFor<EnvironmentReconfigurations>();

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string ExplanationReconfigureEnvirontment { get; set; }

        [Display(Name = "36. If you need to modify the data, how would you do that?")]
        public InputSelectionOptionsFor<DataModification> ModifyingData { get; set; } = new InputSelectionOptionsFor<DataModification>();

        [Display(Name = "Explanation:")]
        [StringLength(400)]
        public string ExplanationModifyingDataOptions { get; set; }


        #endregion

        #region Impact management puts in place a plan for reducing the impact of such an event should it happen

        [Display(Name = "37. How would you manage the impact of a disclosure (related to Notifiable Data Breach) if you and your stakeholders have developed a good working relationship. What have you done to reduce the likelihood to manage this?")]
        public InputSelectionOptionsFor<DataBreachImpactManagement> ImpactManagementReductionOptions { get; set; } = new InputSelectionOptionsFor<DataBreachImpactManagement>();

        [Display(Name = "Explanation")]
        public string ImpactManagementExplanation { get; set; }

        [Display(Name = "38. Identify who your stakeholders are and what assurances you provided them with in terms of the use and protection of the data")]
        public InputSelectionOptionsFor<StakeholderAssuranceProtection> StakeholdersAssurance { get; set; } = new InputSelectionOptionsFor<StakeholderAssuranceProtection>();

        [Display(Name = "Explanation")]
        public string StakeholderAssuranceExplanation { get; set; }

        [Display(Name = "39. Document the process you would follow in the event of a possible breach.")]
        public InputSelectionOptionsFor<DataBreachPlan> PlanForDataBreachProcess { get; set; } = new InputSelectionOptionsFor<DataBreachPlan>();

        [Display(Name = "Explanation")]
        [StringLength(400)]
        public string DataBreachPlanExplanation { get; set; }

        #endregion

        public PIAForm ToForm()
        {
            return new PIAForm()
            {
                AcceptResponsibility = this.AcceptResponsibility,
                AnalysisExplanation = this.AnalysisExplanation,
                AuthorisedByDataSubjects = this.AuthorisedByDataSubjects,
                BelongingDataset = this.BelongingDataset,
                BelongingDatasetCode = this.BelongingDatasetCode,
                DataAgreementsSigned = this.DataAgreementsSigned,
                DataAgreementsLocation = this.DataAgreementsLocation,
                DataAnalyticalApproaches = this.DataAnalyticalApproaches.GetSelections(),
                DataAssuranceExplanation = this.DataAssuranceExplanation,
                DataBreachPlanExplanation = this.DataBreachPlanExplanation,
                DataComplexityExpl = this.DataComplexityExpl,
                DataCustodian = this.DataCustodian,
                DataForm = this.DataForm,
                DataHierarchicalExplanation = this.DataHierarchicalExplanation,
                DataOwner = this.DataOwner,
                DataPersonalOrDeIdentified = this.DataPersonalOrDeIdentified,
                DataQualityExplanation = this.DataQualityExplanation,
                DataRiskManagementExplanation = this.DataRiskManagementExplanation,
                DataSetDescription = this.DataSetDescription,
                DataSetPrivacyStatus = this.DataSetPrivacyStatus,
                DataSourceLocation = this.DataSourceLocation,
                DataStewards = this.DataStewards.ToList(),
                DataTimeCollectedExplanation = this.DataTimeCollectedExplanation,
                DataTimestampedExplanation = this.DataTimestampedExplanation,
                DetailedVariableExpl = this.DetailedVariableExpl,
                ExplanationModifyingDataOptions = this.ExplanationModifyingDataOptions,
                ExplanationReconfigureEnvirontment = this.ExplanationReconfigureEnvirontment,
                ExternalUsers = this.ExternalUsers.ToList(),
                HasInitialSpecification = this.HasInitialSpecification,
                HasObtainedSubjectsViews = this.HasObtainedSubjectsViews,
                HasProvidedTransparency = this.HasProvidedTransparency,
                IdentifiedDataCustodianManagedRisk = this.IdentifiedDataCustodianManagedRisk,
                ImpactManagementExplanation = this.ImpactManagementExplanation,
                ImpactManagementReductionOptions = ImpactManagementReductionOptions.GetSelections(),
                InfoLevelOfData = InfoLevelOfData,
                InfoLevelOfVariable = InfoLevelOfVariable,
                IsDataAboutVulnerablePopulation = IsDataAboutVulnerablePopulation,
                WhenDataWasCollected = WhenDataWasCollected,
                IsDataHierarchical = IsDataHierarchical,
                IsDataQualityLevelHigh = IsDataQualityLevelHigh,
                IsDataTimeStamped = IsDataTimeStamped,
                MaxStep = MaxStep,
                ModifyingData = ModifyingData.GetSelections(),
                OwningSystem = OwningSystem,
                PlanForDataBreachProcess = PlanForDataBreachProcess.GetSelections(),
                ReconfigureEnvironment = ReconfigureEnvirontment.GetSelections(),
                RespectDataAssurances = RespectDataAssurances,
                SensitiveVariableExpl = this.SensitiveVariableExpl,
                StakeholdersAssurance = StakeholdersAssurance.GetSelections(),
                Step = Step,
                SubjectAreaId = SubjectAreaId,
                SiteId = this.Site.Id,
                SiteName = this.Site.Name,
                ProvidedTransparencyExplanation = this.ProvidedTransparencyExplanation,
                PopulationVulnerabilityExplanation = this.PopulationVulnerabilityExplanation,
                StakeholderAssuranceExplanation = this.StakeholderAssuranceExplanation,
                SubmissionMethod = SubmissionMethod,
                SubjectsViewsExplanation = this.SubjectsViewsExplanation,
                SupportingDocumentationLocation = this.SupportingDocumentationLocation,
                SuppressionRuleFour = SuppressionRuleFour,
                SuppressionRuleFourExpl = SuppressionRuleFourExpl,
                SuppressionRuleOne = SuppressionRuleOne,
                SuppressionRuleOneExpl = SuppressionRuleOneExpl,
                SuppressionRuleThree = SuppressionRuleThree,
                SuppressionRuleThreeExpl = SuppressionRuleThreeExpl,
                SuppressionRuleTwo = SuppressionRuleTwo,
                SuppressionRuleTwoExpl = SuppressionRuleTwoExpl,
                SystemDataLocation = this.SystemDataLocation,
                SystemPurposeVersion = SystemPurposeVersion,
                SystemPurposeVersionNumber = SystemPurposeVersionNumber,
                SourceSystemName = SourceSystemName,
                TopLevelAssessment = TopLevelAssessment.GetSelections(),
                TopThreePropsOfData = TopThreePropsOfData.GetSelections(),
                UnderstandMetadata = UnderstandMetadata,
            };
        }

        public static PIAWizardViewModel FromForm(PIAForm form)
        {
            return new PIAWizardViewModel()
            {
                AcceptResponsibility = form.AcceptResponsibility,
                AnalysisExplanation = form.AnalysisExplanation,
                AuthorisedByDataSubjects = form.AuthorisedByDataSubjects,
                BelongingDataset = form.BelongingDataset,
                BelongingDatasetCode = form.BelongingDatasetCode,
                DataAgreementsSigned = form.DataAgreementsSigned,
                DataAgreementsLocation = form.DataAgreementsLocation,
                DataAnalyticalApproaches = form.DataAnalyticalApproaches.AsInputSelectionOptions(),
                DataAssuranceExplanation = form.DataAssuranceExplanation,
                DataBreachPlanExplanation = form.DataBreachPlanExplanation,
                DataComplexityExpl = form.DataComplexityExpl,
                DataCustodian = form.DataCustodian,
                DataForm = form.DataForm,
                DataHierarchicalExplanation = form.DataHierarchicalExplanation,
                DataOwner = form.DataOwner,
                DataPersonalOrDeIdentified = form.DataPersonalOrDeIdentified,
                DataQualityExplanation = form.DataQualityExplanation,
                DataRiskManagementExplanation = form.DataRiskManagementExplanation,
                DataSetDescription = form.DataSetDescription,
                DataSetPrivacyStatus = form.DataSetPrivacyStatus,
                DataSourceLocation = form.DataSourceLocation,
                DataStewards = form.DataStewards.ToList(),
                DataTimeCollectedExplanation = form.DataTimeCollectedExplanation,
                DataTimestampedExplanation = form.DataTimestampedExplanation,
                DetailedVariableExpl = form.DetailedVariableExpl,
                ExplanationModifyingDataOptions = form.ExplanationModifyingDataOptions,
                ExplanationReconfigureEnvirontment = form.ExplanationReconfigureEnvirontment,
                ExternalUsers = form.ExternalUsers.ToList(),
                HasInitialSpecification = form.HasInitialSpecification,
                HasObtainedSubjectsViews = form.HasObtainedSubjectsViews,
                HasProvidedTransparency = form.HasProvidedTransparency,
                IdentifiedDataCustodianManagedRisk = form.IdentifiedDataCustodianManagedRisk,
                ImpactManagementExplanation = form.ImpactManagementExplanation,
                ImpactManagementReductionOptions = form.ImpactManagementReductionOptions.AsInputSelectionOptions(),
                InfoLevelOfData = form.InfoLevelOfData,
                InfoLevelOfVariable = form.InfoLevelOfVariable,
                IsDataAboutVulnerablePopulation = form.IsDataAboutVulnerablePopulation,
                WhenDataWasCollected = form.WhenDataWasCollected,
                IsDataHierarchical = form.IsDataHierarchical,
                IsDataQualityLevelHigh = form.IsDataQualityLevelHigh,
                IsDataTimeStamped = form.IsDataTimeStamped,
                MaxStep = form.MaxStep,
                ModifyingData = form.ModifyingData.AsInputSelectionOptions(),
                OwningSystem = form.OwningSystem,
                PlanForDataBreachProcess = form.PlanForDataBreachProcess.AsInputSelectionOptions(),
                ReconfigureEnvirontment = form.ReconfigureEnvironment.AsInputSelectionOptions(),
                RespectDataAssurances = form.RespectDataAssurances,
                StakeholdersAssurance = form.StakeholdersAssurance.AsInputSelectionOptions(),
                Step = form.Step,
                SubjectAreaId = form.SubjectAreaId,
                SiteId = form.SiteId,
                SiteName = form.SiteName,
                Site = new Site() {Id = form.SiteId.GetValueOrDefault(), Name = form.SiteName },
                ProvidedTransparencyExplanation = form.ProvidedTransparencyExplanation,
                PopulationVulnerabilityExplanation = form.PopulationVulnerabilityExplanation,
                SensitiveVariableExpl = form.SensitiveVariableExpl,
                StakeholderAssuranceExplanation = form.StakeholderAssuranceExplanation,
                SubmissionMethod = form.SubmissionMethod,
                SubjectsViewsExplanation = form.SubjectsViewsExplanation,
                SupportingDocumentationLocation = form.SupportingDocumentationLocation,
                SuppressionRuleFour = form.SuppressionRuleFour,
                SuppressionRuleFourExpl = form.SuppressionRuleFourExpl,
                SuppressionRuleOne = form.SuppressionRuleOne,
                SuppressionRuleOneExpl = form.SuppressionRuleOneExpl,
                SuppressionRuleThree = form.SuppressionRuleThree,
                SuppressionRuleThreeExpl = form.SuppressionRuleThreeExpl,
                SuppressionRuleTwo = form.SuppressionRuleTwo,
                SuppressionRuleTwoExpl = form.SuppressionRuleTwoExpl,
                SystemDataLocation = form.SystemDataLocation,
                SystemPurposeVersion = form.SystemPurposeVersion,
                SystemPurposeVersionNumber = form.SystemPurposeVersionNumber,
                SourceSystemName = form.SourceSystemName,
                TopLevelAssessment = form.TopLevelAssessment.AsInputSelectionOptions(),
                TopThreePropsOfData = form.TopThreePropsOfData.AsInputSelectionOptions(),
                UnderstandMetadata = form.UnderstandMetadata,
            };
        }
    }
}
