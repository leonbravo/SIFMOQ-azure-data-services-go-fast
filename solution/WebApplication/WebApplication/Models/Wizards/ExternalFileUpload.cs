using System;
using System.ComponentModel.DataAnnotations;

namespace WebApplication.Models.Wizards
{
    public partial class ExternalFileUpload
    {
        public Int64 UploadSystemId { get; set; }
        public Int64 EmailSystemId { get; set; }
        public Int64 TargetSystemId { get; set; } 
        public Int64 ScheduleMasterId { get; set; }
        public Int64 EngineId { get; set; }
        public Int64 TaskGroupId { get; set; }
        public Int64 TaskTypeId { get; set; }

        public string UploadFileName { get; set; }
        public bool IsActive { get; set; }
        public bool AllowMultipleActiveInstances { get; set; }

        public string ExternalParties { get; set; } // is this info relevant or should be stored?
        
        [Required(ErrorMessage = "Name is required")]
        public string TaskMasterName { get; set; }

        [Required]
        public string TaskDatafactoryIr { get; set; }
        public string DependencyChainTag { get; set; }        
        public int DegreeOfCopyParallelism { get; set; }

        public string EmailTemplateFileName { get; set; }
        [Display(Name = "Email Address")]
        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string Email { get; set; }
        [Display(Name = "Email Address")]
        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Invalid Email Address")]
        public string OperatorEmail { get; set; }
        public string OperatorName { get; set; }
        public string RelativePath { get; set; }
        public string FileUploaderWebAppURL { get; set; }
        public string EmailSubject { get; set; }
        public string TargetSystemUidInPHI { get; set; }

    }
}
