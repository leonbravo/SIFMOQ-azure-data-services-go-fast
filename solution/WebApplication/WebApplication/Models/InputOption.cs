using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    public class InputOption<U> where U : System.Enum
    {
        [JsonConverter(typeof(StringEnumConverter))]
        public U Option { get; set; }
        public bool IsSelected { get; set; }

    }
}