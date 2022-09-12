using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum DataModification
    {
        [Display(Name = "De-Identify")]
        DeIdentify = 0,
        Suppress = 1,
        Anonymise = 2,
        Aggregate = 3,
        [Display(Name = "Delete Certain Fields")]
        DeleteCertainFields = 4
    }
}
