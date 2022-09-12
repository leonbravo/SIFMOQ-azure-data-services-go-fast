using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum Properties
    {
        Age = 0,
        Gender = 1,
        Quality = 2,
        [Display(Name = "Indigenous Status")]
        IndigenousStatus = 3,
        Location = 4,
        Clinical = 5
    }
}
