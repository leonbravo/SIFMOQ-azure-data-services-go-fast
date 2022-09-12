using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum EnvironmentReconfigurations
    {
        [Display(Name = "Specify People Access")]
        SpecifyPeopleAccess = 0,
        [Display(Name = "Specify Requisite Security Level")]
        SpecifyRequisiteSecurityLevel = 1,
        [Display(Name = "Allow Access Only Within Own Secure Environment")]
        AllowAccessOnlyWithinOwnSecureEnvironment = 2,
        [Display(Name = "Specify All Analytics Be Checked Before Publishing")]
        SpecifyAllAnalyticsBeCheckedBeforePublish = 3,
        [Display(Name = "Make Use of Data Agreements")]
        MakeUseOfDataAgreements = 4
    }
}
