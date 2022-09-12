using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FunctionApp.DataAccess;
using FunctionApp.Models;

namespace FunctionApp.Services
{
    public class IntegrationRuntimeMappingProvider
    {
        private readonly TaskMetaDataDatabase _taskMetaDataDatabase;

        public IntegrationRuntimeMappingProvider(TaskMetaDataDatabase taskMetaDataDatabase)
        {
            _taskMetaDataDatabase = taskMetaDataDatabase;
        }

        public async Task<List<IntegrationRuntimeMapping>> GetAllActive()
        {
            using var con = await _taskMetaDataDatabase.GetSqlConnection();
            return con.QueryWithRetry<IntegrationRuntimeMapping>("select * from [dbo].[IntegrationRuntimeMapping] Where ActiveYN = 1").ToList();
        }

        
        public static void CheckValidTaskMasterMapping(List<IntegrationRuntimeMapping> all, string SourceSystemId, string TargetSystemId, string IntegrationRuntime)
        {
            /*List<IntegrationRuntimeMapping> filtered = new List<IntegrationRuntimeMapping>();
            foreach (var i in all)
            {
                foreach (var j in all)
                {
                                    var validMapping = all.Where(x =>(x.SystemId.ToString() == SourceSystemId) && x.IntegrationRuntimeName == IntegrationRuntime).ToList();
                if (validMapping.Count >= 1)
                {
                    filtered.AddRange(validMapping);
                }
                }

            }
            */
            var sourceFiltered = all.Where(x =>(x.SystemId.ToString() == SourceSystemId) && x.IntegrationRuntimeName == IntegrationRuntime).ToList();
            var targetFiltered = all.Where(x =>(x.SystemId.ToString() == TargetSystemId) && x.IntegrationRuntimeName == IntegrationRuntime).ToList();

            if (sourceFiltered.Count < 1 || targetFiltered.Count < 1)
            {
                throw (new Exception($"Failed to find IntegrationRuntimeMapping record for SourceSystemId: {SourceSystemId} and TargetSystemId: {TargetSystemId}, IntegrationRuntimeName {IntegrationRuntime}"));

            }

        }
    }
}