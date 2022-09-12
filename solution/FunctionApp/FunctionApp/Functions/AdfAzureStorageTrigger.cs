/*-----------------------------------------------------------------------

 Copyright (c) Microsoft Corporation.
 Licensed under the MIT license.

-----------------------------------------------------------------------*/


using FunctionApp.Authentication;
using FunctionApp.DataAccess;
using FunctionApp.Models.Options;
using FunctionApp.Services;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.IO;

namespace FunctionApp.Functions
{

    /// <summary>
    /// Still WIP. Not yet in use
    /// </summary>
    public static class AzureStorageTrigger
    {


       /*[FunctionName("AzureStorageTrigger")]
        public static void Run([BlobTrigger("datalakeraw/samples/{name}")] Stream myBlob, IBinder binder, string name, ILogger log)
        {
            var path = string.Empty;
            var storageAccount = "Datalake";
            var attributes = SetAttributes(path, storageAccount);

            log.LogInformation($"C# Blob trigger function Processed blob\n Name:{name} \n Size: {myBlob.Length} Bytes");
        }
        private static System.Attribute[] SetAttributes(string path, string storageAccount)
        {
            var attributes = new System.Attribute[]
            {
                new BlobAttribute(path, FileAccess.Write),
                new StorageAccountAttribute(storageAccount)
            };

            return attributes;
        }*/

    }

}