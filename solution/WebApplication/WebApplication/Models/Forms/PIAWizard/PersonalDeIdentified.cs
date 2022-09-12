using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum PersonalDeIdentified
    {
        DeIdentified = 0,
        Personal = 1        
    }
}
