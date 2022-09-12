using System.Threading.Tasks;
using FunctionApp.Models.Options;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Identity.Client;
using System.Collections.Generic;
using System;

namespace FunctionApp.Authentication
{
    /// <summary>
    /// This provider is used for Azure App Services only. 
    /// </summary>
    /// <remarks>Consider using the Azure.Identity package and provider instead. This is no longer the preferred method</remarks>
    public class MicrosoftAzureServicesAppAuthenticationProvider: IAzureAuthenticationProvider
    {
        private readonly bool _useMsi;
        private readonly AuthOptions _authOptions;

        public MicrosoftAzureServicesAppAuthenticationProvider(AuthOptions authOptions, bool useMsi)
        {
            _useMsi = useMsi;
            _authOptions = authOptions;
        }
        public async Task<string> GetAzureRestApiToken(string resourceName)
        {
            try
            {
                if (_useMsi)
                {
                    Microsoft.Azure.Services.AppAuthentication.AzureServiceTokenProvider tokenProvider = new Microsoft.Azure.Services.AppAuthentication.AzureServiceTokenProvider();
                    return await tokenProvider.GetAccessTokenAsync(resourceName).ConfigureAwait(false);
                }
                else
                {

                    AuthenticationContext context =
                        new AuthenticationContext("https://login.windows.net/" + _authOptions.TenantId);
                    Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential cc = new Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential(_authOptions.ClientId, _authOptions.ClientSecret);
                    Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationResult result =  await context.AcquireTokenAsync(resourceName, cc).ConfigureAwait(false);
                    return result.AccessToken;
                }
            }
            catch (System.Exception e)
            {
                throw e;
                return "Failed to GetAzureRestApiToken";
            }
        }

        public async Task<string> GetPowerBIRestApiToken(string clientId, string clientSecret, string tenantId)
        {
            try
            {
                //if supplied a tenantid we replace it
                var tenant = _authOptions.TenantId.ToString();
                if (!String.IsNullOrEmpty(tenantId))
                {
                    tenant = tenantId;
                }
                var tenantSpecificUrl = "https://login.microsoftonline.com/" + tenant + "/";

                //var tenantSpecificUrl = "https://login.microsoftonline.com/" + "ea6e65c7-8840-425b-a957-8c72609ac812/";
                // Create a confidential client to authorize the app with the AAD app
                IConfidentialClientApplication clientApp = ConfidentialClientApplicationBuilder
                                                                                .Create(clientId)
                                                                                .WithClientSecret(clientSecret)
                                                                                .WithAuthority(tenantSpecificUrl)
                                                                                .Build();
                // Make a client call if Access token is not available in cache
                List<string> scopes = new List<string>();
                scopes.Add("https://analysis.windows.net/powerbi/api/.default");
                var authenticationResult = clientApp.AcquireTokenForClient(scopes).ExecuteAsync().Result;
                return authenticationResult.AccessToken;

            }
            catch (System.Exception e)
            {
                throw e;
                return "Failed to GetPowerBIRestApiToken";
            }
        }

        public Azure.Core.TokenCredential GetAzureRestApiTokenCredential(string resourceName)
        {
            throw new System.Exception("GetAzureRestApiTokenCredential method not valid for MicrosoftAzureServicesAppAuthenticationProvider  did you intend to use the AzureIdentityAuthenticationProvider?");            
        }
    }
}