using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum InformationLevelData
    {
        [Display(Name = "Individual Level")]
        IndividualLevel = 0,
        Aggregated = 1,
        Locality = 2
    }
}

