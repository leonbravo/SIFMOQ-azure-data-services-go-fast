using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum DataBreachImpactManagement
    {
        [Display(Name = "Additional Access Control")]
        AdditionalAccessControl = 0,
        [Display(Name = "Removed Identifiable Data")]
        RemoveIdentifiableData = 1,
        [Display(Name = "Formal DSA on Data Usage")]
        DSAOnDataUsage = 2,
        [Display(Name = "Data Suppression Used")]
        DataSuppressionUsed = 3,
        [Display(Name = "Other")]
        Other = 4
    }
}
