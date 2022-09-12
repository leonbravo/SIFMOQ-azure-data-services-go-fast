using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum Specifications
    {
        [Display(Name = "Reduce Data Complexity")]
        ReduceDataComplexity = 0,
        [Display(Name = "Exclude Sensitive Variables")]
        ExcludeSensitiveVariable = 1,
        [Display(Name = "Exclude Detailed Variables")]
        ExcludeDetailedVariables = 2
    }
}
