using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum FormOfData
    {
        [Display(Name = "Flat-file")]
        FlatFile = 0,
        [Display(Name = "Survey Data")]
        Text = 1,
        Database = 2
    }
}
