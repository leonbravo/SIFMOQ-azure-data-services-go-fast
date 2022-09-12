using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
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

namespace FunctionApp.Functions
{
    // ReSharper disable once UnusedMember.Global
    public class AdfGetInformationSchemaSql
    {
        private readonly ApplicationOptions _appOptions;

        public AdfGetInformationSchemaSql(IOptions<ApplicationOptions> appOptions)
        {
            _appOptions = appOptions.Value; ;
        }

        /// <summary>
        /// The purpose of this function is to provide a SQL query that the Data Factory can use
        /// to retrieve the schema information for a table. 
        /// </summary>
        /// <param name="req"></param>
        /// <param name="log"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        [FunctionName("GetInformationSchemaSQL")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {            
            Guid executionId = context.InvocationId;
            FrameworkRunner frp = new FrameworkRunner(log, executionId);

            FrameworkRunnerWorkerWithHttpRequest worker = GetInformationSchemaSqlCore;
            FrameworkRunnerResult result = await frp.Invoke(req, "GetInformationSchemaSQL", worker);
            if (result.Succeeded)
            {
                return new OkObjectResult(JObject.Parse(result.ReturnObject));
            }
            else
            {
                return new BadRequestObjectResult(new { Error = "Execution Failed...." });
            }
        }

        public async Task<JObject> GetInformationSchemaSqlCore(HttpRequest req, Logging.Logging logging)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            string tableSchema = JObject.Parse(data.ToString())["TableSchema"];
            string tableName = JObject.Parse(data.ToString())["TableName"];
            string sourceType = JObject.Parse(data.ToString())["SourceType"];
            string informationSchemaSql = "";


            Dictionary<string, string> sqlParams = new Dictionary<string, string>
            {
                { "tableName", tableName },
                { "tableSchema", tableSchema }
            };



            string SqlTemplatefile = "SqlServer";
            if (sourceType == "Oracle Server")
            {
                SqlTemplatefile = sourceType.Replace(" ", "");
            }

            informationSchemaSql = GenerateSqlStatementTemplates.GetSql(System.IO.Path.Combine(EnvironmentHelper.GetWorkingFolder(), _appOptions.LocalPaths.SQLTemplateLocation), "GetInformationSchema_"+SqlTemplatefile, sqlParams);

            JObject root = new JObject
            {
                ["InformationSchemaSQL"] = informationSchemaSql
            };

            return root;
        }

    }
}