using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum SuppressionRuleOptions
    {
        [Display(Name = "Not Applicable")]
        NA = 0,
        [Display(Name = "I have applied this suppression rule")]
        Applied = 1,
        [Display(Name = "I have not applied this suppression rule")]
        NotApplied = 2,        
    }
}
