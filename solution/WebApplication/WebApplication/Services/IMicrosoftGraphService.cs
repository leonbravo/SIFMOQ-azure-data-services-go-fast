using System.Collections.Generic;
using System.Threading.Tasks;
using WebApplication.Models;

namespace WebApplication.Services
{
    public interface IMicrosoftGraphService
    {
        Task<IEnumerable<UserReference>> GetMembers();
    }
}