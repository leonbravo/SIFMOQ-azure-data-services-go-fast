using System.ComponentModel.DataAnnotations;

namespace WebApplication.Models
{
    public partial class IntegrationRuntimeMapping
    {
        public int IntegrationRuntimeMappingId { get; set; }
        [Display(Name = "Integration Runtime ID")]
        public int IntegrationRuntimeId { get; set; }
        [Display(Name = "Integration Runtime Name")]
        [Required(AllowEmptyStrings = false, ErrorMessage = "Please input valid Mapping Type")]
        public string IntegrationRuntimeName { get; set; }
        [Display(Name = "Source System ID")]
        public long SystemId { get; set; }
        [Display(Name = "Is Active")]
        public bool ActiveYn { get; set; }

    }
}
