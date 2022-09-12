using System;
using System.Data.SqlClient;
using System.IO;
using System.Threading.Tasks;
using FunctionApp.Authentication;
using FunctionApp.DataAccess;
using FunctionApp.Helpers;
using FunctionApp.Models;
using FunctionApp.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace FunctionApp.Functions
{
    /// <summary>
    /// Generate Merge Statement
    /// </summary>
    public class GetSqlMergeStatement
    {
        private readonly IAzureAuthenticationProvider _authProvider;
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;

        public GetSqlMergeStatement(IAzureAuthenticationProvider authProvider, TaskMetaDataDatabase taskMetaDataDatabase)
        {
            _authProvider = authProvider;
            _taskMetaDataDatabase = taskMetaDataDatabase;
        }

        [FunctionName("GetSQLMergeStatement")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            Guid executionId = context.InvocationId;
            FrameworkRunner frp = new FrameworkRunner(log, executionId);

            FrameworkRunnerWorkerWithHttpRequest worker = GetSqlMergeStatementCore;
            FrameworkRunnerResult result = await frp.Invoke(req, "GetSqlMergeStatement", worker);
            if (result.Succeeded)
            {
                return new OkObjectResult(JObject.Parse(result.ReturnObject));
            }
            else
            {
                return new BadRequestObjectResult(new { Error = "Execution Failed...." });
            }
        }
        public async Task<JObject> GetSqlMergeStatementCore(HttpRequest req,
            Logging.Logging logging)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);


            JObject root = new JObject();
            using (SqlConnection con = await _taskMetaDataDatabase.GetSqlConnection())
            {
                String g = Guid.NewGuid().ToString().Replace("-", "");
                JArray arrStage = (JArray)data["Stage"];
                string stagingTableSchema = data["StagingTableSchema"].ToString();
                string stagingTableName = "#Temp_" + data["StagingTableName"].ToString() + g.ToString();
                string createStatementStage = GenerateSqlStatementTemplates.GetCreateTable(arrStage, stagingTableSchema, stagingTableName, "Azure SQL",false);
                TaskMetaDataDatabase.ExecuteSql(createStatementStage, con);

                JArray arrTarget = (JArray)data["Target"];
                string targetTableSchema = data["TargetTableSchema"].ToString();
                string targetTableName = "#Temp_" + data["TargetTableName"].ToString() + g.ToString();
                string createStatementTarget = GenerateSqlStatementTemplates.GetCreateTable(arrTarget, targetTableSchema, targetTableName, "Azure SQL",false);

                TaskMetaDataDatabase.ExecuteSql(createStatementTarget, con);

                string mergeStatement = _taskMetaDataDatabase.GenerateMergeSql(stagingTableSchema, stagingTableName, targetTableSchema, targetTableName, con, true, logging);
                string fullStagingTableName = $"[{stagingTableSchema}].[{stagingTableName.Replace("#Temp_", "").Replace(g, "")}]";
                string fullTargetTableName = $"[{targetTableSchema}].[{targetTableName.Replace("#Temp_", "").Replace(g, "")}]";
                mergeStatement = mergeStatement.Replace(targetTableName, fullTargetTableName);
                mergeStatement = mergeStatement.Replace(stagingTableName, fullStagingTableName);
                //Add Select for ADF Lookup Activity 
                mergeStatement += Environment.NewLine + "Select 1 ";

                root["MergeStatement"] = mergeStatement;

                logging.LogInformation("GetSQLMergeStatement Function complete.");
            }
            return root;


        }
    }
}