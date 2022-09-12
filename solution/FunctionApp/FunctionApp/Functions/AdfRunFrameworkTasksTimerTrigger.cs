using System;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using FunctionApp.DataAccess;
using FunctionApp.Models.Options;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace FunctionApp.Functions
{
    /// <summary>
    /// The purpose of this function is to perform the execution of scheduled task instances. It simply iterates over the
    /// available task runners and triggers them to begin executing their tasks
    /// </summary>
    // Azure Function, don't delete unused class/method 
    // ReSharper disable once UnusedMember.Global
    public class AdfRunFrameworkTasksTimerTrigger
    {
        private readonly IOptions<ApplicationOptions> _options;
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;
        private readonly IHttpClientFactory _httpClientFactory;
        
        public string HeartBeatFolder { get; set; }

        public AdfRunFrameworkTasksTimerTrigger(IOptions<ApplicationOptions> options, TaskMetaDataDatabase taskMetaDataDatabase, IHttpClientFactory httpClientFactory)
        {
            _options = options;
            _taskMetaDataDatabase = taskMetaDataDatabase;
            _httpClientFactory = httpClientFactory;            
        }

        /// <summary>
        ///             "0 */5 * * * *" once every five minutes
        ///              "0 0 * * * *"   once at the top of every hour
        ///              "0 0 */2 * * *" once every two hours
        ///              "0 0 9-17 * * *"    once every hour from 9 AM to 5 PM
        ///              "0 30 9 * * *"  at 9:30 AM every day
        ///              "0 30 9 * * 1-5"    at 9:30 AM every weekday
        ///              "0 30 9 * Jan Mon"  at 9:30 AM every Monday in January
        /// 
        /// </summary>
        /// <param name="myTimer"></param>
        /// <param name="log"></param>
        /// <param name="context"></param>
        //[FunctionName("RunFrameworkTasksTimerTrigger")]         
        //public async Task Run([TimerTrigger("0 */2 * * * *")] TimerInfo myTimer, ILogger log, ExecutionContext context)
        //{
        //    log.LogInformation(context.FunctionAppDirectory);
        //    this.HeartBeatFolder = context.FunctionAppDirectory;
        //    await Core(log);        
        //}

        public async Task Core(ILogger log)
        {            
            if (_options.Value.TimerTriggers.EnableRunFrameworkTasks)
            {
                using var client = _httpClientFactory.CreateClient(HttpClients.CoreFunctionsHttpClientName);
                if (client.DefaultRequestHeaders.Authorization == null)
                {
                    await Task.Delay(2000);
                }

                using SqlConnection con = await _taskMetaDataDatabase.GetSqlConnection();

                // Get a list of framework task runners that are currently idle
                var frameworkTaskRunners = con.QueryWithRetry("Exec dbo.GetFrameworkTaskRunners");

                foreach (var runner in frameworkTaskRunners)
                {
                    int taskRunnerId = ((dynamic)runner).TaskRunnerId;
                    DirectoryInfo folder = Directory.CreateDirectory(Path.Combine(this.HeartBeatFolder, "runners"));
                    var files = folder.GetFiles();

                    if (((dynamic)runner).Status == "Running" && ((dynamic)runner).RunNow == "Y")
                    {
                        //Write a runner heartbeat file
                        string FileName = Path.Combine(folder.FullName, $"hb_{taskRunnerId.ToString()}_{DateTime.Now.ToString("yyyyMMddhhmm")}.txt");
                        using (FileStream fs = File.Create(FileName))
                        {
                            Byte[] info = new System.Text.UTF8Encoding(true).GetBytes("");
                            fs.Write(info, 0, info.Length);
                        }

                       
                        
                        try
                        {
                            // Trigger the Http triggered function
                            var secureFunctionApiurl = $"{_options.Value.ServiceConnections.CoreFunctionsURL}/api/RunFrameworkTasksHttpTrigger?TaskRunnerId={taskRunnerId}";
                            using HttpRequestMessage httpRequestMessage = new HttpRequestMessage
                            {
                                Method = HttpMethod.Get,
                                RequestUri = new Uri(secureFunctionApiurl)
                            };

                            //Todo Add some error handling in case function cannot be reached. Note Wait time is there to provide sufficient time to complete post before the HttpClientFactory is disposed.
                            var httpTask = client.SendAsync(httpRequestMessage).Wait(3000);
                           

                        }
                        catch (TaskCanceledException)
                        {
                                                           
                            log.LogInformation($"Framework runner {taskRunnerId} request cancelled... this is expected behaviour.");
                        }
                        catch (Exception)
                        {
                                                           
                            log.LogError($"Framework runner {taskRunnerId} failed to launch.");
                            con.ExecuteWithRetry($"[dbo].[UpdFrameworkTaskRunner] {taskRunnerId}");
                            throw;
                        }
                           
                        
                    }

                    if (((dynamic)runner).Status == "Running" && ((dynamic)runner).RunNow == "N")
                    {
                        var runnerHBFiles = files.Where(f => f.Name.StartsWith($"hb_{taskRunnerId.ToString()}_"));
                        if (runnerHBFiles.Any())
                        {
                            DateTime maxDateTime = new DateTime(1900, 01, 01, 01, 01, 01);
                            //If the runner is not idle check the heartbeat files to ensure it hasn't previously failed on start
                            foreach (var f in runnerHBFiles)
                            {
                                string DateOfFileStr = f.Name.Replace($"hb_{taskRunnerId.ToString()}_", "").Replace(".txt", "");
                                int Year = System.Convert.ToInt16(DateOfFileStr.Substring(0, 4));
                                int Month = System.Convert.ToInt16(DateOfFileStr.Substring(4, 2));
                                int Day = System.Convert.ToInt16(DateOfFileStr.Substring(6, 2));
                                int Hour = System.Convert.ToInt16(DateOfFileStr.Substring(8, 2));
                                int Minute = System.Convert.ToInt16(DateOfFileStr.Substring(10, 2));
                                DateTime DateOfFile = new DateTime(Year, Month, Day, Hour, Minute, 01);
                                if (maxDateTime < DateOfFile)
                                { maxDateTime = DateOfFile; }
                            }

                            if (maxDateTime < DateTime.Now.AddMinutes(-5))
                            {
                                //Delete the files and reset the runner as it has failed to start previously                            
                                foreach (var f in runnerHBFiles)
                                {
                                    f.Delete();
                                }
                                con.ExecuteWithRetry($"[dbo].[UpdFrameworkTaskRunner] {taskRunnerId}");
                            }
                        }
                    }
                }
            }
        }


    }
}