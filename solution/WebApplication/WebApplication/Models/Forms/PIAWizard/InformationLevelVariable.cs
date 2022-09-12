using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum InformationLevelVariable
    {        
        [Display(Name = "Direct Identifiers")]
        DirectIdentifier = 0,
        [Display(Name = "Indirect Identifiers")]
        IndirectIdentifiers = 1,
        [Display(Name = "Aggregated Cohort Grouping")]
        AggregatedCohortGrouping = 2
    }
}

