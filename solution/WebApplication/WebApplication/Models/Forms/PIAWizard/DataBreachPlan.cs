using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace WebApplication.Forms.PIAWizard
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum DataBreachPlan
    {
        [Display(Name = "Robust Audit Trail")]
        RobustAuditTrail = 0,
        [Display(Name = "Crisis Management Policy")]
        CrisisManagementPolicy = 1,
        [Display(Name = "Notify Of Data Breach Process")]
        NotifyDataBreachProcess = 2,
        [Display(Name = "Trained Staff")]
        TrainedStaff = 3,
        [Display(Name = "Other")]
        Other = 4
    }
}
