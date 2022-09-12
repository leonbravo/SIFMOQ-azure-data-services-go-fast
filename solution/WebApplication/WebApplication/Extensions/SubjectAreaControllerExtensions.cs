using System.Threading.Tasks;
using WebApplication.Framework;
using WebApplication.Models;

namespace WebApplication.Controllers
{
    public static class SubjectAreaControllerExtensions
    {
        public static async Task<bool> CanEditSubjectArea(this BaseController controller, SubjectArea sa)
        {
            var isPartiallyCompleted = (SubjectAreaFormStatus?)sa.SubjectAreaForm?.FormStatus < SubjectAreaFormStatus.Complete;
            var isMine = sa.UpdatedBy == controller.User.GetUserName() || sa.SubjectAreaForm?.UpdatedBy == controller.User.GetUserName();

            return (isPartiallyCompleted && isMine);
        }
    }
}