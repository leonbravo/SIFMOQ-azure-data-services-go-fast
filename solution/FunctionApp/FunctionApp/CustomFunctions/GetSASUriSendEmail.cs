using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using FormatWith;
using FunctionApp.DataAccess;
using FunctionApp.Helpers;
using FunctionApp.Models;
using FunctionApp.Models.Options;
using FunctionApp.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SendGrid;
using SendGrid.Helpers.Errors.Model;
using SendGrid.Helpers.Mail;

namespace FunctionApp.CustomFunctions
{
    public class GetSasUriSendEmailHttpTrigger
    {
        private readonly IOptions<ApplicationOptions> _options;
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;

        public GetSasUriSendEmailHttpTrigger(IOptions<ApplicationOptions> options, TaskMetaDataDatabase taskMetaDataDatabase)
        {
            _options = options;
            _taskMetaDataDatabase = taskMetaDataDatabase;
        }
        [FunctionName("GetSASUriSendEmailHttpTrigger")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req, ILogger log, ExecutionContext context)
        {
            Guid executionId = context.InvocationId;
            
            FrameworkRunner fr = new FrameworkRunner(log, executionId);

            FrameworkRunnerWorkerWithHttpRequest worker = SendEmailSasUri;
            var result = await fr.Invoke(req, "GetSASUriSendEmailHttpTrigger", worker);
            if (result.Succeeded)
            {
                return new OkObjectResult(JObject.Parse(result.ReturnObject));
            }
            else
            {
                return new BadRequestObjectResult(new { Error = "Execution Failed...." });
            }
        }

        public async Task<JObject> SendEmailSasUri(HttpRequest req, Logging.Logging logging)
        {
            string requestBody = new StreamReader(req.Body).ReadToEndAsync().Result;
            dynamic taskInformation = JsonConvert.DeserializeObject(requestBody);

            string taskInstanceId = taskInformation["TaskInstanceId"].ToString();
            string executionUid = taskInformation["ExecutionUid"].ToString();

            try
            {
                //Get SAS URI
                string blobStorageAccountName = taskInformation["Source"]["StorageAccountName"].ToString();
                string blobStorageContainerName = taskInformation["Source"]["StorageAccountContainer"].ToString();
                string blobStorageFolderPath = taskInformation["Source"]["RelativePath"].ToString();
                string dataFileName = taskInformation["Source"]["DataFileName"].ToString();
                int accessDuration = (int)taskInformation["Source"]["SasURIDaysValid"];
                string targetSystemUidInPhi = taskInformation["Source"]["TargetSystemUidInPHI"];
                string fileUploaderWebAppUrl = taskInformation["Source"]["FileUploaderWebAppURL"];

                string sasUri = CreateSasToken(blobStorageAccountName, blobStorageContainerName, blobStorageFolderPath, dataFileName, accessDuration);

                //Send Email
                string emailRecipient = taskInformation["Target"]["EmailRecipient"].ToString();
                string emailRecipientName = taskInformation["Target"]["EmailRecipientName"].ToString();
                string emailTemplateFileName = taskInformation["Target"]["EmailTemplateFileName"].ToString();
                string senderEmail = taskInformation["Target"]["SenderEmail"].ToString();
                string senderDescription = taskInformation["Target"]["SenderDescription"].ToString();
                string subject = taskInformation["Target"]["EmailSubject"].ToString();

                //Get Plain Text and Email Subject from Template Files 
                Dictionary<string, string> @params = new Dictionary<string, string>
                {
                    { "NAME", emailRecipientName },
                    { "SASTOKEN", sasUri },
                    { "FileUploaderUrl", fileUploaderWebAppUrl },
                    { "TargetSystemUidInPHI", targetSystemUidInPhi },

                };
                string plainTextContent = await File.ReadAllTextAsync(Path.Combine(Path.Combine(EnvironmentHelper.GetWorkingFolder(), _options.Value.LocalPaths.HTMLTemplateLocation), emailTemplateFileName + ".txt"));
                plainTextContent = plainTextContent.FormatWith(@params, MissingKeyBehaviour.ThrowException);

                string htmlContent = await File.ReadAllTextAsync(Path.Combine(Path.Combine(EnvironmentHelper.GetWorkingFolder(), _options.Value.LocalPaths.HTMLTemplateLocation), emailTemplateFileName + ".html"));
                htmlContent = htmlContent.FormatWith(@params, MissingKeyBehaviour.ThrowException);

                byte[] attachmentContent = await File.ReadAllBytesAsync(Path.Combine(Path.Combine(EnvironmentHelper.GetWorkingFolder(), _options.Value.LocalPaths.HTMLTemplateLocation), emailTemplateFileName + ".jpg"));
                string attachmentContentBase64 = System.Convert.ToBase64String(attachmentContent);
                var attachments = new List<Attachment>{
                    new() { Content = attachmentContentBase64, Type = "image/jpg", Filename = "logo.jpg", ContentId = "logo", Disposition = "inline" }
                };
                var client = new SendGridClient(new SendGridClientOptions { ApiKey = _options.Value.SendGridApiKey, HttpErrorAsException = true });
                var msg = new SendGridMessage()
                {
                    From = new EmailAddress(senderEmail, senderDescription),
                    Subject = subject,
                    PlainTextContent = plainTextContent,
                    HtmlContent = htmlContent,
                    Attachments = attachments,
                };
                msg.AddTo(new EmailAddress(emailRecipient, emailRecipientName));
                try
                {
                    var response = await client.SendEmailAsync(msg).ConfigureAwait(false);
                    logging.LogInformation($"SendGrid Response StatusCode - {response.StatusCode}");
                }
                catch (Exception ex)
                {
                    SendGridErrorResponse errorResponse = JsonConvert.DeserializeObject<SendGridErrorResponse>(ex.Message);
                    logging.LogInformation($"Error Message - {ex.Message}");
                    throw new Exception("Could not send email");
                }

                //Update Task Instance
                _taskMetaDataDatabase.LogTaskInstanceCompletion(System.Convert.ToInt64(taskInstanceId), System.Guid.Parse(executionUid), TaskInstance.TaskStatus.Complete, Guid.Empty, "");

                JObject root = new JObject
                {
                    ["Result"] = "Complete"
                };

                return root;
            }
            catch (Exception taskException)
            {
                logging.LogErrors(taskException);
                _taskMetaDataDatabase.LogTaskInstanceCompletion(System.Convert.ToInt64(taskInstanceId), System.Guid.Parse(executionUid), TaskInstance.TaskStatus.FailedRetry, Guid.Empty, "Failed when trying to Generate Sas URI and Send Email");

                JObject root = new JObject
                {
                    ["Result"] = "Failed"
                };

                return root;

            }

        }

        public static string CreateSasToken(string BlobStorageAccountName, string BlobStorageContainerName, string BlobStorageFolderPath, string DataFileName, int accessDuration)
        {

            // Get a credential and create a client object for the blob container. Note using new Azure Core credential flow
            BlobServiceClient blobClient = new BlobServiceClient(new Uri(BlobStorageAccountName),
                                                                            new DefaultAzureCredential());
            
            //blobClient.GetProperties();
            var startDate = DateTimeOffset.UtcNow.AddMinutes(-1);
            var endDate = DateTimeOffset.UtcNow.AddDays(accessDuration);

            // Get a user delegation key for the Blob service that's valid for seven days.
            // You can use the key to generate any number of shared access signatures over the lifetime of the key.
            UserDelegationKey key = blobClient.GetUserDelegationKey(startDate,endDate);
            Uri blobUri = new Uri(BlobStorageAccountName);
            BlobContainerClient containerClient = new BlobContainerClient(blobUri, new DefaultAzureCredential());
            // Create a SAS token
            BlobSasBuilder sasBuilder = new BlobSasBuilder()
            {
                BlobContainerName = BlobStorageContainerName,
                BlobName = $"{BlobStorageFolderPath}{DataFileName}",
                Resource = "b",
                StartsOn = startDate,
                ExpiresOn = endDate,
                Protocol = SasProtocol.Https
            };

            // Specify read permissions for the SAS.
            BlobSasPermissions perms = BlobSasPermissions.Create | BlobSasPermissions.Write;
            
            sasBuilder.SetPermissions(perms);

            // Use the key to get the SAS token.
            string sasToken = sasBuilder.ToSasQueryParameters(key, blobUri.Host.Split('.')[0]).ToString();

            // Construct the full URI, including the SAS token.
            UriBuilder fullUri = new UriBuilder()
            {
                Scheme = "https",
                Host = $"{blobUri.Host.Split('.')[0]}.blob.core.windows.net",
                Path = $"{BlobStorageContainerName}/{BlobStorageFolderPath}{DataFileName}",
                Query = sasToken
            };

            string retvar = "&Path=" + Uri.EscapeDataString(fullUri.Path);
            retvar += "&" + sasToken;

            return retvar;
        }

    }
}

