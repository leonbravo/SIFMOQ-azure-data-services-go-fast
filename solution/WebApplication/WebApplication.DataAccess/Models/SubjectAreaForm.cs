using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebApplication.Models
{
    public partial class SubjectAreaForm
    {
        public int SubjectAreaFormId { get; set; }
        public string FormJson { get; set; }
        public byte? FormStatus { get; set; }
        public string UpdatedBy { get; set; }
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime ValidFrom { get; set; }
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime ValidTo { get; set; }
        public byte Revision { get; set; }
        
        [Display(Name="PIA Status")] 
        public string FormStatusDisplay 
        {
            get
            {
                var fs = (SubjectAreaFormStatus?) FormStatus ?? SubjectAreaFormStatus.Incomplete;
                string status = fs < SubjectAreaFormStatus.Complete ? "Incomplete" : "Complete";
                return status;
            }
        }

    }
}
