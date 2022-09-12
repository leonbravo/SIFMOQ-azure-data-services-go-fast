using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum StakeholderAssuranceProtection
    {
        [Display(Name = "DSA")]
        DSA = 0,
        [Display(Name = "Contact When Risk Profile Changes")]
        ContactWhenRiskProfileChanges = 1
    }
}
