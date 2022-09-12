using Azure.Core;
using System.Threading.Tasks;

namespace FunctionApp.Authentication
{
    public interface IAzureAuthenticationProvider
    {
        Task<string> GetAzureRestApiToken(string resourceName);
        TokenCredential GetAzureRestApiTokenCredential(string resourceName);
    }
}
