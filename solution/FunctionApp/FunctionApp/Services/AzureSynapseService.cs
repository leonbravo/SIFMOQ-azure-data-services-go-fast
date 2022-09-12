using Microsoft.Azure.Management.Synapse;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using FunctionApp.Authentication;
using FunctionApp.Models.Options;
using Microsoft.Extensions.Options;
using Microsoft.Rest;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net.Http;
using Azure.Analytics.Synapse.Artifacts;
using Azure.Core;
using Microsoft.Azure.Management.DataFactory.Models;
using System.Linq;
using FunctionApp.Functions;
using FunctionApp.DataAccess;
using System.IO;
using Azure.Analytics.Synapse.Spark;
using Azure.Analytics.Synapse.Spark.Models;
using Azure;
using Azure.Analytics.Synapse.Artifacts.Models;

namespace FunctionApp.Services
{
    public class AzureSynapseService
    {
        private readonly IAzureAuthenticationProvider _authProvider;
        private readonly IOptions<ApplicationOptions> _options;
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;

        public AzureSynapseService(IAzureAuthenticationProvider authProvider, IOptions<ApplicationOptions> options, TaskMetaDataDatabase taskMetaDataDatabase)
        {
            _authProvider = authProvider;
            _options = options;
            _taskMetaDataDatabase = taskMetaDataDatabase;
        }
        public async Task StartStopSynapseSqlPool(string SubscriptionId, string ResourceGroupName, string SynapseWorkspaceName, string SynapsePoolName, string Action, Logging.Logging logging)
        {
            try
            {
                string token = await _authProvider.GetAzureRestApiToken("https://management.azure.com/").ConfigureAwait(false);
                ServiceClientCredentials cred = new TokenCredentials(token);

                //https://management.azure.com/subscriptions/{subscription-id}/resourceGroups/{resource-group-name}/providers/Microsoft.Synapse/workspaces/{workspace-name}/sqlPools/{database-name}/pause?api-version=2019-06-01-preview

                SynapseManagementClient synapseManagementClient = new SynapseManagementClient(cred);
                synapseManagementClient.SubscriptionId = SubscriptionId;
                //ToDo Add error handling
                var sqlPool = synapseManagementClient.SqlPools.Get(ResourceGroupName, SynapseWorkspaceName, SynapsePoolName);
                logging.LogInformation($"Synapse SQL pool ({SynapsePoolName}) is currently: {sqlPool.Status}");
                if (sqlPool.Status == "Paused" || sqlPool.Status == "Pausing")
                {
                    if (Action.ToLower() == "start")
                    {
                        logging.LogInformation($"Attempting to {Action} ({SynapsePoolName})");
                        synapseManagementClient.SqlPools.Resume(ResourceGroupName, SynapseWorkspaceName, SynapsePoolName);
                        logging.LogInformation($"{SynapsePoolName} now has the status: {sqlPool.Status}");
                    }
                    else
                    {
                        Exception error = new Exception("Cannot execute a " + Action + " action on the dedicated pool " + SynapsePoolName + ". Current status of pool: " + sqlPool.Status);
                        logging.LogErrors(error);
                        throw error;
                    }

                }
                else if (sqlPool.Status == "Online" || sqlPool.Status == "Resuming")
                {
                    if (Action.ToLower() == "pause")
                    {
                        logging.LogInformation($"Attempting to {Action} ({SynapsePoolName})");
                        synapseManagementClient.SqlPools.Pause(ResourceGroupName, SynapseWorkspaceName, SynapsePoolName);
                        logging.LogInformation($"{SynapsePoolName} now has the status: {sqlPool.Status}");
                    }
                    else
                    {
                        Exception error = new Exception("Cannot execute a " + Action + " action on the dedicated pool " + SynapsePoolName + ". Current status of pool: " + sqlPool.Status);
                        logging.LogErrors(error);
                        throw error;
                    }
                }



            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                logging.LogErrors(new Exception($"Initiation of SQLPool command failed for SqlPool: {SynapsePoolName} and Workspase: {SynapseWorkspaceName}"));
                throw;

            }
        }

        public async Task<string> RunSynapsePipeline(Uri endpoint, string pipelineName, Dictionary<string, object> pipelineParams, Logging.Logging logging)
        {

            try
            {
                string token = await _authProvider.GetAzureRestApiToken("https://dev.azuresynapse.net").ConfigureAwait(false);
                HttpClient c = new HttpClient();
                c.DefaultRequestHeaders.Accept.Clear();
                c.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                c.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
                JObject jsonContent = new JObject();
                jsonContent["TaskObject"] = JsonConvert.SerializeObject(pipelineParams["TaskObject"]);
                var postContent = new StringContent(jsonContent.ToString(), System.Text.Encoding.UTF8, "application/json");
                HttpResponseMessage response = await c.PostAsync($"{endpoint.ToString()}/pipelines/{pipelineName}/createRun?api-version=2020-12-01", postContent);
                HttpContent responseContent = response.Content;
                var status = response.StatusCode;
                var content = await responseContent.ReadAsStringAsync();
                if (response.StatusCode != System.Net.HttpStatusCode.Accepted)
                {
                    throw new Exception($"Synapse Pipeline Activation via Rest Failed. StatusCode: {status}; Message: {content}");
                }

                return content;

            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                throw e;
            }

        }

        public async Task<string> ExecuteNotebook(Uri endpoint, string taskName, string poolName, Logging.Logging logging, string sessionFolder, JObject TaskObject)
        {
            int tryCount = 0;
            bool success = false;
            SparkNotebookExecutionResult sner = new SparkNotebookExecutionResult();
            sner.Endpoint = endpoint.ToString();
            sner.PoolName = poolName;
            sner.TaskName = taskName;
            sner.TaskObject = TaskObject;
            sner.SessionFolder = sessionFolder + "/sessions/";
            sner.TaskInstanceId = System.Convert.ToInt32(TaskObject["TaskInstanceId"]);
            var ssc = GetSessionClient(new Uri(sner.Endpoint), sner.PoolName);
            var sc = await GetSynapseClient();
            var nc = GetNotebookClient(new Uri(sner.Endpoint));

            SparkNotebookExecutionHelper sneh = new SparkNotebookExecutionHelper(sner, sc,ssc, nc, logging);

            //Loop through to retry if fails
            while (tryCount < 5)
            {
                sneh.Sner = await ExecuteNotebookCore(logging, sneh);
                if (sneh.Sner.StatementResult == SparkNotebookExecutionResult.statementResult.succeeded)
                {
                    logging.LogInformation("Task Named " + taskName + " Succeeded. Attempts: " + tryCount.ToString());
                    success = true;
                    break;
                }
                logging.LogWarning($"Task Named {taskName} Failed To Start. Result status was '{sneh.Sner.StatementResult}' Attempt Number {tryCount.ToString()}");
                tryCount++;
                await Task.Delay(20000);
            }
            if (success)
            {
                return Newtonsoft.Json.JsonConvert.SerializeObject(sneh.Sner);
            }
            else
            {
                throw new Exception("Task failed to get a spark session after waiting 10 seconds. Try increasing the number of allowed concurrent spark sessions.");
                //return Newtonsoft.Json.JsonConvert.SerializeObject(sneh.Sner);

            }
        }

        public async Task StopIdleSessions(Uri endpoint, string poolName, Logging.Logging logging, JObject TaskObject)
        {                                 
            Int32 TaskInstanceId = System.Convert.ToInt32(TaskObject["TaskInstanceId"]);
            var ssc = GetSessionClient(endpoint, poolName);
            var sc = await GetSynapseClient();

            int reqSessionCount = 20;
            int reqFromSession = 0;
            while (reqSessionCount >= 20)
            {
                
                Response<SparkSessionCollection> ss = await ssc.GetSparkSessionsAsync(reqFromSession, 20, true);
                foreach (SparkSession s in ss.Value.Sessions)
                {
                    string SessionName = "";
                    if (string.IsNullOrEmpty(s.Name)) { SessionName = ""; } else { SessionName = s.Name; }
                    if (s.State == Azure.Analytics.Synapse.Spark.Models.LivyStates.Idle && SessionName.StartsWith("AdsGoFast_"))
                    {
                        //Azure.Response response = await ssc.CancelSparkSessionAsync(s.Id);
                        HttpResponseMessage response = await sc.DeleteAsync($"{endpoint.ToString()}/livyApi/versions/2019-11-01-preview/sparkPools/{poolName}/sessions/" + s.Id.ToString());
                        var responseContent = response.Content;
                        var status = response.StatusCode;
                        var content = await responseContent.ReadAsStringAsync();                        

                        if (response.StatusCode != System.Net.HttpStatusCode.OK)
                        {
                            logging.LogErrors(new Exception($"Synapse Session Cancellation via Rest Failed. StatusCode: {status}; Message: {content}"));
                        }
                    }

                }

                reqSessionCount = ss.Value.Total;
                if (reqSessionCount > 0)
                {
                    reqFromSession += ss.Value.Total;
                }
            }           
        }

        private async Task<SparkNotebookExecutionResult> ExecuteNotebookCore(Logging.Logging logging, SparkNotebookExecutionHelper sneh)
        {

            try
            {
                //ToDo Delete Old Sessions waiting to Start                
                //Get Sessions Waiting To Start
                sneh.GetSessionsWaitingToStartFromDisk();
                //logging.LogInformation($"TaskInstance:{sneh.Sner.TaskInstanceId}; SessionsFromDisk:{sneh.Sner.sessionsWaitingToStart.ToString()}; SessionsTotal:{sneh.SessionCount.ToString()}");
                await sneh.GetCandidateSessions();
                //logging.LogInformation($"TaskInstance:{sneh.Sner.TaskInstanceId}; SessionsFromDisk:{sneh.Sner.sessionsWaitingToStart.ToString()}; SessionsTotal:{sneh.SessionCount.ToString()}");
                await sneh.ProcessCandidateSessions();
                logging.LogInformation($"TaskInstance:{sneh.Sner.TaskInstanceId}; SessionsFromDisk:{sneh.Sner.sessionsWaitingToStart.ToString()}; SessionsTotal:{sneh.SessionCount.ToString()}");
                await sneh.NewSessionCheck();

                //Run code                
                await sneh.RunCode();                

            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                sneh.Sner.StatementResult = SparkNotebookExecutionResult.statementResult.failed;                
            }

            return sneh.Sner;

        }

        public async Task<string> CheckStatementExecution(JObject Params, Logging.Logging logging)
        {
            SparkSessionClient ssc = GetSessionClient(new Uri(Params["Endpoint"].ToString()), Params["PoolName"].ToString());
            SparkStatement statement = ssc.GetSparkStatement(System.Convert.ToInt32(Params["SessionId"]), System.Convert.ToInt32(Params["StatementId"]));
            logging.LogInformation($"Statememt for task {Params["TaskName"].ToString()} is currently {statement.State.ToString()} on session {Params["SessionId"]}");
            return statement.State.ToString();

        }

        public async Task<string> PostToSynapseApi(Uri endpoint, string Path, string postContent, Logging.Logging logging)
        {

            try
            {
                var c = await GetSynapseClient();
                JObject jsonContent = new JObject();
                var postStringContent = new StringContent(postContent, System.Text.Encoding.UTF8, "application/json");
                HttpResponseMessage response = await c.PostAsync($"{endpoint.ToString()}/{Path}", postStringContent);
                HttpContent responseContent = response.Content;
                var status = response.StatusCode;
                var content = await responseContent.ReadAsStringAsync();
                if (response.StatusCode != System.Net.HttpStatusCode.Accepted && response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    throw new Exception($"PostToSynapseApi Failed via Rest Failed. StatusCode: {status}; Message: {content}");
                }

                return content;

            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                throw e;
            }

        }

        public async Task<string> GetFromSynapseApi(Uri endpoint, string Path, Logging.Logging logging)
        {

            try
            {
                var c = await GetSynapseClient();
                HttpResponseMessage response = await c.GetAsync($"{endpoint.ToString()}/{Path}");
                HttpContent responseContent = response.Content;
                var status = response.StatusCode;
                var content = await responseContent.ReadAsStringAsync();
                if (response.StatusCode != System.Net.HttpStatusCode.Accepted && response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    throw new Exception($"GetFromSynapseApi Failed via Rest Failed. StatusCode: {status}; Message: {content}");
                }

                return content;

            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                throw e;
            }

        }


        public async Task<string> GetSparkSession(Uri endpoint, string SessionName, Logging.Logging logging)
        {

            try
            {
                var c = await GetSynapseClient();

                HttpResponseMessage response = await c.GetAsync($"{endpoint.ToString()}/livyApi/versions/2019-11-01-preview/sparkPools/adsdevsynspads/sessions?detailed=True");
                HttpContent responseContent = response.Content;
                var status = response.StatusCode;
                var content = await responseContent.ReadAsStringAsync();
                if (response.StatusCode != System.Net.HttpStatusCode.Accepted)
                {
                    throw new Exception($"Synapse Pipeline Activation via Rest Failed. StatusCode: {status}; Message: {content}");
                }

                return content;

            }
            catch (Exception e)
            {
                logging.LogErrors(e);
                throw e;
            }

        }



        public async Task<HttpClient> GetSynapseClient()
        {
            string token = await _authProvider.GetAzureRestApiToken("https://dev.azuresynapse.net");
            HttpClient c = new HttpClient();
            c.DefaultRequestHeaders.Accept.Clear();
            c.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            c.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            return c;
        }

        public SparkSessionClient GetSessionClient(Uri endpoint, string poolName)
        {
            TokenCredential credential = _authProvider.GetAzureRestApiTokenCredential("https://dev.azuresynapse.net//.default");
            SparkSessionClient ssc = new SparkSessionClient(endpoint, poolName, credential, "2019-11-01-preview", null);
            return ssc;
        }
        public NotebookClient GetNotebookClient(Uri endpoint)
        {
            TokenCredential credential = _authProvider.GetAzureRestApiTokenCredential("https://dev.azuresynapse.net//.default");
            NotebookClient nc = new NotebookClient(endpoint, credential);
            return nc;
        }

       




        private class SparkNotebookExecutionHelper
        {
            private HttpClient c { get; set;}
            private Logging.Logging _logging { get; set; }
            private SparkSessionClient ssc { get; set; }
            NotebookClient nc { get; set; }
            private List<SparkSession> sscl = new List<SparkSession>();
            private List<SparkSession> busySessions = new List<SparkSession>();
            private int SessionsCurrentlyRunning { get; set; }
            private string CandidateSessionId { get; set; }

            private bool CandidateAllowedToRun { get; set; }

            private Guid ProcessingGuid { get; set; }
            public int SessionCount { get; set; }

            public SparkNotebookExecutionHelper(SparkNotebookExecutionResult sner, HttpClient httpClient, SparkSessionClient sparkSessionClient, NotebookClient notebookClient, Logging.Logging logging)
            {
                Sner = sner;
                c = httpClient;
                ssc = sparkSessionClient;
                nc = notebookClient;
                this.Sner.UsingBusySession = false;
                this.Sner.Guid = Guid.NewGuid();
                this.Sner.sessionsWaitingToStart = 0;
                this.ProcessingGuid = Guid.NewGuid();
                _logging = logging;
            }


            public SparkNotebookExecutionResult Sner;

            public void GetSessionsWaitingToStartFromDisk()
            {
                //Todo Remove very old Files
                
                DirectoryInfo folder = Directory.CreateDirectory(Path.Combine(Sner.SessionFolder));
                var files = folder.GetFiles();
                var matchedFiles = files.Where(f => f.Name.StartsWith($"cs_"));

                List<int> snums = new List<int>();
                if (matchedFiles.Any())
                {
                    foreach (var f in matchedFiles)
                    {
                        int s = System.Convert.ToInt16(f.Name.Split("_")[1]);
                        snums.Add(s);
                    }

                    var snumsd = snums.Distinct();
                    Sner.sessionsWaitingToStart = snums.Max() + 1;
                }
                SessionCount = 0 + Sner.sessionsWaitingToStart;                
            }

            public async Task GetCandidateSessions()
            {                                
                int reqSessionCount = 20;
                int reqFromSession = 0;
                while (reqSessionCount >= 20)
                {

                    Response<SparkSessionCollection> ss = await ssc.GetSparkSessionsAsync(reqFromSession, 20, false);
                    foreach (SparkSession s in ss.Value.Sessions)
                    {
                        if (s.State != Azure.Analytics.Synapse.Spark.Models.LivyStates.Killed && s.State != Azure.Analytics.Synapse.Spark.Models.LivyStates.Dead && s.State != Azure.Analytics.Synapse.Spark.Models.LivyStates.Error && s.State != Azure.Analytics.Synapse.Spark.Models.LivyStates.ShuttingDown)
                        {
                            //Azure.Analytics.Synapse.Spark.Models.LivyStates.Running;
                            //Azure.Analytics.Synapse.Spark.Models.LivyStates.Idle;
                            //Azure.Analytics.Synapse.Spark.Models.LivyStates.Success;
                            //Azure.Analytics.Synapse.Spark.Models.LivyStates.NotStarted;
                            //Azure.Analytics.Synapse.Spark.Models.LivyStates.Recovering;
                            sscl.Add(s);
                        }
                        
                    }

                    reqSessionCount = ss.Value.Total;
                    if (reqSessionCount > 0)
                    {
                        reqFromSession += ss.Value.Total;
                    }
                }
            }

            public async Task ProcessCandidateSessions()
            {

                foreach (SparkSession s in sscl)
                {
                    //Session number for current loop iteration
                    var loopSession = s.Id.ToString();
                    double timeSinceStarted = 0;
                    SparkSession sd = await ssc.GetSparkSessionAsync(s.Id, true);
                    if (!string.IsNullOrEmpty(sd.LivyInfo.StartingAt.ToString()))
                    {
                        timeSinceStarted = (DateTimeOffset.Now - (DateTimeOffset)sd.LivyInfo.StartingAt).TotalSeconds;
                    }
                    string SessionName = "";
                    if (string.IsNullOrEmpty(sd.Name)) { SessionName = ""; } else { SessionName = sd.Name; }
                    switch (sd.State.ToString())
                    {
                        case "idle":
                            if (timeSinceStarted > 180)
                            {

                                if ((string.IsNullOrEmpty(CandidateSessionId)) && (SessionName.StartsWith("AdsGoFast_")))
                                {

                                    if (CheckForHeartBeatFiles("us", System.Convert.ToInt32(loopSession)))
                                    {
                                        //Write a session heartbeat file
                                        _logging.LogInformation($"Processing Task {Sner.TaskName}. PreExisting Session number {loopSession} detected for application AdsGoFast {SessionCount}. Signaling intent to use...");
                                        WriteSessionHeartBeat(loopSession, ProcessingGuid, "us");
                                        await Task.Delay(1000);
                                        //Now Check again To Make sure that you locked the session first                                        
                                        if (CheckForHeartBeatFiles("us", System.Convert.ToInt32(loopSession), ProcessingGuid))
                                        {
                                            _logging.LogInformation($"Processing Task {Sner.TaskName}. PreExisting Session number {loopSession} detected for application AdsGoFast {SessionCount}. Succeeded in signalling intent to use.");
                                            CandidateSessionId = loopSession; 
                                        }
                                        else
                                        {
                                            //Consider this session busy
                                            busySessions.Add(sd);
                                            _logging.LogWarning($"Processing Task {Sner.TaskName}. PreExisting Session number {loopSession} detected for application AdsGoFast {SessionCount}. Failed in signalling intent to use.");
                                        }

                                    }
                                    else
                                    {
                                        //Consider this session busy
                                        busySessions.Add(sd);
                                    }
                                }
                                SessionCount += 1;
                            }
                            else
                            {
                                //Consider this session busy
                                if (SessionName.StartsWith("AdsGoFast_"))
                                {
                                    busySessions.Add(sd);
                                }
                                SessionCount += 1;
                            }
                            break;
                        case "busy":
                            SessionCount += 1;
                            if (SessionName.StartsWith("AdsGoFast_"))
                            {
                                busySessions.Add(sd);
                            }
                            break;
                        case "not_started":
                            SessionCount += 1;                           
                            break;
                        case "starting":
                            SessionCount += 1;                            
                            break;
                        default:
                            SessionCount += 1;
                            _logging.LogInformation("Unexpected Session State:" + sd.State.ToString());
                            break;

                    }
                    


                }
            }

            public async Task RunCode()
            {
                if (!string.IsNullOrEmpty(CandidateSessionId))
                {
                    SparkSession idleSession = await ssc.GetSparkSessionAsync(System.Convert.ToInt16(CandidateSessionId), true);
                    string code = "";
                    //Get the Notebook 

                    string Notebookname = "";
                    if (Helpers.JsonHelpers.CheckForJsonProperty("TMOptionals", this.Sner.TaskObject))
                    {
                        if (Helpers.JsonHelpers.CheckForJsonProperty("ExecuteNotebook", (JObject)this.Sner.TaskObject["TMOptionals"]))
                        {
                            Notebookname = this.Sner.TaskObject["TMOptionals"]["ExecuteNotebook"].ToString();                            
                        }
                    }

                    if (string.IsNullOrEmpty(Notebookname))
                    {
                        if (Helpers.JsonHelpers.CheckForJsonProperty("ExecutionEngine", this.Sner.TaskObject))
                        {
                            if (Helpers.JsonHelpers.CheckForJsonProperty("JsonProperties", (JObject)this.Sner.TaskObject["ExecutionEngine"]))
                            {
                                if (Helpers.JsonHelpers.CheckForJsonProperty("DeltaProcessingNotebook", (JObject)(this.Sner.TaskObject["ExecutionEngine"]["JsonProperties"])))
                                {
                                    Notebookname = this.Sner.TaskObject["ExecutionEngine"]["JsonProperties"]["DeltaProcessingNotebook"].ToString();
                                }
                            }
                        }

                    }

                    if (string.IsNullOrEmpty(Notebookname))
                    {
                        throw new Exception("Notebookname is null or empty");
                    }

                    NotebookResource Notebook = await nc.GetNotebookAsync(Notebookname);
                    foreach (NotebookCell cell in Notebook.Properties.Cells)
                    {
                        bool cellIsParam = false;
                        if (cell.CellType == "code")
                        {
                            Dictionary<string, object> metadata = (Dictionary<string, object>)cell.Metadata;
                            if (metadata.ContainsKey("tags"))
                            {
                                object[] tags = (object[])metadata["tags"];
                                if (!string.IsNullOrEmpty((string)Array.Find<object>(tags, t => t.ToString() == "parameters")))
                                {
                                    cellIsParam = true;
                                    //Insert the TaskObject as a Parameter
                                    var t = Sner.TaskObject;
                                    var t1 = JsonConvert.SerializeObject(t);
                                    var t2 = t1.Replace("\\", "\\\\");
                                    var t3 = t2.Replace(@"""", @"\""");
                                    code += "TaskObject = " + "\"" + t3 + "\"";
                                    code += System.Environment.NewLine;
                                }

                            }

                            if (!cellIsParam)
                            {
                                foreach (var line in cell.Source)
                                {
                                    code += line.ToString();
                                }
                                code += System.Environment.NewLine;
                            }
                        }
                    }

                    if (string.IsNullOrEmpty(code))
                    {
                        _logging.LogInformation($"Processing Task {Sner.TaskName}. Failed!!!. The called Synapse Notebook appears to contain no code. Check that the notebook exists!");
                        Sner.StatementResult = SparkNotebookExecutionResult.statementResult.failed;
                    }
                    else
                    {
                        SparkStatementOptions sso = new SparkStatementOptions();
                        sso.Kind = "pyspark";

                        sso.Code = "spark.sparkContext.setLocalProperty(\"spark.scheduler.pool\", \"pool1\")" + System.Environment.NewLine + code;
                        SparkStatementOperation statemento = ssc.StartCreateSparkStatement(System.Convert.ToInt32(idleSession.Id), sso);
                        //sso.Code = "spark.sparkContext.setLocalProperty(\"spark.scheduler.pool\", \"pool2\")" + System.Environment.NewLine + code.Replace("-1000", "-1001");
                        //sso.Code =  code.Replace("-1000", "-1001");
                        //SparkStatementOperation statemento2 = ssc.StartCreateSparkStatement(System.Convert.ToInt32(idleSession.Id), sso);
                        DeleteHeartBeatFiles("us", idleSession.Id);

                        SparkStatement statement = ssc.GetSparkStatement(System.Convert.ToInt32(idleSession.Id), System.Convert.ToInt32(statemento.Id));

                        _logging.LogInformation($"Processing Task {Sner.TaskName}. PySpark Statement Created and Executing using Session {idleSession.Id}. 'UsingBusySession':{Sner.UsingBusySession}");
                        Sner.StatementResult = SparkNotebookExecutionResult.statementResult.succeeded;
                        Sner.SessionId = idleSession.Id;
                        Sner.StatementId = statement.Id;
                        Sner.StatementState = statement.State;
                    }
                }
                else
                {
                    _logging.LogErrors(new Exception($"No CandidateSession Found. Guid: {ProcessingGuid}, Task: {Sner.TaskName}"));
                }
            }
            
            public async Task NewSessionCheck()
            {

                for (int i = 0; i < 3; i++)
                {

                    switch (await StartNewSession())
                    {
                        case 0:
                            _logging.LogErrors(new Exception("Start New Session Returned an Invalid Result"));
                            i = 3;
                            break;
                        case 1:
                            //Do Nothing as Idle Session Already Found
                            i = 3;
                            break;
                        case 2:
                            //Session Limit Hit.. Go To Busy Sessions 
                            CheckBusySessions();
                            i = 3;
                            break;
                        case 3:
                            //Unable to Start Due to Concurrency Issues... Add One to SessionCount and try again
                            SessionCount++;
                            break;
                        case 4:
                            //Unable to Start Due to Startup Timeout... Go To Busy Sessions
                            CheckBusySessions();
                            i = 3;
                            break;
                        case 5:
                            //Startup Succeeded
                            i = 3;
                            break;
                        default:
                            i = 3;
                            break;

                    }
                }

            }

            public void CheckBusySessions() {

                //If no idle sessions then create new one
                if (string.IsNullOrEmpty(CandidateSessionId))
                {
                    //At this point we have not found an idle session AND we have no capacity to create additional sessions so now submit to existing BUSY sesson if available
                    if (busySessions.Any())
                    {
                        int? MinStatements = null;
                        int MinStatementSessonId = -1;
                        bool ValidBusySessionFound = false;
                        foreach (SparkSession session in busySessions)
                        {
                            Int64 RunningStatementCount = 0;
                            if (session.State == Azure.Analytics.Synapse.Spark.Models.LivyStates.Busy || session.State == Azure.Analytics.Synapse.Spark.Models.LivyStates.Idle )
                            {
                                ValidBusySessionFound = true;
                                var sss = this.ssc.GetSparkStatements(session.Id);

                                foreach (var ss in sss.Value.Statements)
                                {
                                    if (ss.State == LivyStatementStates.Running || ss.State == LivyStatementStates.Waiting || ss.State == LivyStatementStates.Cancelling)
                                    {
                                        RunningStatementCount++;
                                    }
                                }
                                                                                          
                                if (MinStatements == null)
                                {
                                    MinStatements = (int?)RunningStatementCount;
                                    MinStatementSessonId = session.Id;
                                }
                                if (RunningStatementCount <= MinStatements)
                                {
                                    MinStatements = (int?)RunningStatementCount;
                                    MinStatementSessonId = session.Id;
                                }
                            }

                        }


                        if (ValidBusySessionFound)
                        {
                            CandidateSessionId = MinStatementSessonId.ToString();
                            Sner.UsingBusySession = true;
                        }
                    }
                    else
                    {
                        _logging.LogErrors(new Exception($"No Capacity for New Sessions and No Busy Sessions. Guid: {ProcessingGuid}, Task: {Sner.TaskName}"));
                    }

                }
            }

   
            /// <summary>
            /// Returns 0 should never occur 
            /// Returns 1 if CandidateSessionId already set so no need to start new session
            /// Returns 2 if session limit already hit
            /// Returns 3 if unable to start session due to concurrency issue 
            /// Returns 4 if unable to start due to timeout
            /// Returns 5 if successfully started session
            /// </summary>
            /// <returns></returns>
            public async Task<int> StartNewSession()
            {
                int ret = 0;

                if (!string.IsNullOrEmpty(this.CandidateSessionId))
                {
                    return 1;
                }


                if (this.SessionCount <= 2)
                {
                    var startTimer = DateTime.Now;
                    string sessionName = "AdsGoFast_" + (SessionCount + 1).ToString();
                    //string jsonContent = "{\"tags\": null,\"Name\": \"" + sessionName + "\", \"driverMemory\": \"4g\",  \"driverCores\": 1,  \"executorMemory\": \"2g\", \"executorCores\": 2, \"numExecutors\": 2, \"artifactId\": \"dldj\"}";
                    SparkSessionOptions sso = new SparkSessionOptions(sessionName);
                    sso.DriverCores = 1;
                    sso.DriverMemory = "4g";
                    sso.ExecutorCores = 2;
                    sso.ExecutorMemory = "2g";
                    sso.ExecutorCount = 2;
                    sso.ArtifactId = "test";


                    if (CheckForHeartBeatFiles("cs", SessionCount))
                    {
                        WriteSessionHeartBeat(SessionCount.ToString(), ProcessingGuid, "cs");
                        await Task.Delay(1000);
                        if (CheckForHeartBeatFiles("cs", SessionCount, ProcessingGuid))
                        {
                            //JObject newSession = JObject.Parse(await PostToSynapseApi(endpoint, $"livyApi/versions/2019-11-01-preview/sparkPools/{poolName}/sessions?detailed=True", jsonContent, logging));
                            SparkSessionOperation ns = ssc.StartCreateSparkSession(sso, true);
                            CandidateSessionId = ns.Id.ToString();
                            SparkSession newSession = await ssc.GetSparkSessionAsync(System.Convert.ToInt16(ns.Id), true);

                            WriteSessionHeartBeat(CandidateSessionId, ProcessingGuid, "us");
                            //Wait for session to start
                            if (newSession.State == Azure.Analytics.Synapse.Spark.Models.LivyStates.NotStarted)
                            {
                                //Will Wait for up to 200 seconds
                                for (int i = 0; i < 40; i++)
                                {
                                    await Task.Delay(5000);
                                    var startUpTime = (DateTime.Now - startTimer).TotalSeconds;
                                    newSession = await ssc.GetSparkSessionAsync(System.Convert.ToInt16(newSession.Id), true);
                                    if (newSession.State == Azure.Analytics.Synapse.Spark.Models.LivyStates.Idle)
                                    {
                                        _logging.LogInformation($"Processing Task {Sner.TaskName}. Session {CandidateSessionId}. Started in {startUpTime.ToString()} seconds.");
                                        //Wait a tiny bit longer just to make sure session is ready
                                        await Task.Delay(1000);
                                        DeleteHeartBeatFiles("cs", SessionCount);
                                        ret = 5;
                                        break;
                                    }
                                    else
                                    {
                                        _logging.LogInformation($"Processing Task {Sner.TaskName}. Waiting for Session {CandidateSessionId} for application {sessionName}. Current state is {newSession.State.ToString()}. Startup time has been {startUpTime.ToString()} seconds.");
                                    }
                                }
                                //Failed to Start Session within time limit.
                                ret = 4; //No Candidate Task and unable to start session;
                            }
                        }
                        else
                        {
                            //Couldn;t Start Session due to concurrency issue on startup
                            ret = 3; //No Candidate Task and unable to start session;
                        }
                    }
                    else
                    {
                        //Couldn;t Start Session
                        _logging.LogInformation($"Processing Task {Sner.TaskName}. This thread has not been allowed to start session {sessionName} due to concurrency issue. Attempting retry.");
                        ret = 3; //No Candidate Task and unable to start session;
                    }



                }
                else
                {
                    ret = 2; //No Candidate Task and no new sessions allowed;
                }

                return ret;

            }


            private void WriteSessionHeartBeat(string id, Guid guid, string prefix)
            {
                DirectoryInfo folder = new DirectoryInfo(Sner.SessionFolder);
                //Write a session heartbeat file                                
                string FileName = Path.Combine(folder.FullName, $"{prefix}_{id}_{guid.ToString()}.txt");
                using (FileStream fs = File.Create(FileName))
                {
                    Byte[] info = new System.Text.UTF8Encoding(true).GetBytes("");
                    fs.Write(info, 0, info.Length);
                }
            }

            private bool CheckForHeartBeatFiles(string prefix, int id)
            {
                return CheckForHeartBeatFiles(prefix, id, Guid.Empty);
            }

            private bool CheckForHeartBeatFiles(string prefix, int id, Guid guid)
            {
                bool ret = false;
                DirectoryInfo folder = new DirectoryInfo(Sner.SessionFolder);
                
                //Check if heartbeat files exist
                var files = folder.GetFiles();
                //Remove very old files 
                foreach (var file in files)
                {
                    if (file.CreationTimeUtc < DateTime.UtcNow.AddHours(-48))
                    {
                        //Wrapping Delete in Try Catch in case another thread has already deleted the old files
                        try { 

                            file.Delete(); 
                        } 
                        catch { }
                    }
                }

                files = folder.GetFiles();
                var matchedFiles = files.Where(f => f.Name.StartsWith($"{prefix}_{id.ToString()}_"));
                if (matchedFiles.Any())
                {
                    //Skip this session and move on to the next
                    //logging.LogInformation($"Processing Task {taskName}. Session {loopSession} for application AdsGoFast {sessionCount} is idle but marked for use.");
                    if (Guid.Empty == guid)
                    {
                        ret = false;
                    }
                    else
                    {
                        Guid minGuid = Guid.Empty;
                        //If the runner is not idle check the heartbeat files to ensure it hasn't previously failed on start
                        foreach (var f in matchedFiles)
                        {
                            Guid GuidInFileStr = Guid.Parse(f.Name.Replace($"{prefix}_{id.ToString()}_", "").Replace(".txt", ""));
                            if (Guid.Empty.CompareTo(minGuid) == 0) { minGuid = GuidInFileStr; }
                            if (minGuid.CompareTo(GuidInFileStr) == -1)
                            { minGuid = GuidInFileStr; }
                        }

                        //If current thread has wrote the first heartbeat then allow it to continue
                        if (minGuid == guid)
                        {
                            ret = true;
                        }
                        else 
                        {
                            ret = false;
                        }
                    }
                }
                else
                {
                    ret = true;
                }
                return ret;
            }

            private void DeleteHeartBeatFiles(string prefix, int id)
            {                
                DirectoryInfo folder = new DirectoryInfo(Sner.SessionFolder);
                //Check if heartbeat files exist
                var files = folder.GetFiles();
                var matchedFiles = files.Where(f => f.Name.StartsWith($"{prefix}_{id.ToString()}_"));
                foreach (var f in matchedFiles)
                {
                    f.Delete();
                }

            }

        }

    }
    public class SparkNotebookExecutionResult
    {
        public SparkNotebookExecutionResult()
        { }

        public enum statementResult { failed, retry, succeeded, nosessions }

        public statementResult StatementResult { get; set; }

        public int StatementId { get; set; }

        public int SessionId { get; set; }

        public string Endpoint { get; set; }

        public string PoolName { get; set; }

        public string TaskName { get; set; }

        public string SessionFolder { get; set; }

        public int TaskInstanceId { get; set; }

        public JObject TaskObject { get; set; }

        public Guid Guid { get; set; }

        public bool UsingBusySession { get; set; }

        public int sessionsWaitingToStart { get; set; }

        public string StatementResultString
        {
            get
            {
                return this.StatementResult.ToString();
            }
        }

        public LivyStatementStates? StatementState { get; set; }

    }

}
