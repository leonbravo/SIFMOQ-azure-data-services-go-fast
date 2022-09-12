using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace WebApplication.Models
{
    public class EntityRoleMap
    {
        public const string SubjectAreaTypeName = "SubjectArea";
        public const string ExecutionEngineTypeName = "ExecutionEngine";
        public const string ScheduleMasterTypeName = "ScheduleMaster";
        public const string SourceAndTargetTypeName = "SourceAndTargetSystems";

        public int EntityRoleMapId { get; set; }
        public string EntityTypeName { get; set; }
        [Required(AllowEmptyStrings = false, ErrorMessage = "Please input valid EntityId")]
        public int EntityId { get; set; }
        [Required(AllowEmptyStrings = false, ErrorMessage = "Please input valid AadGroupUid")]
        public Guid AadGroupUid { get; set; }
        
        [Required(AllowEmptyStrings = false, ErrorMessage = "Please input valid ApplicationRoleName")]
        public string ApplicationRoleName { get; set; }

        public DateTime ExpiryDate { get; set; }
        public bool ActiveYN { get; set; }
        public string UpdatedBy { get; set; }
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime ValidFrom { get; set; }
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime ValidTo { get; set; }
    }
}
