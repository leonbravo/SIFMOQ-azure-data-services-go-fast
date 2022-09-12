using System;
using FunctionApp.Helpers;
using Newtonsoft.Json.Linq;

namespace FunctionApp.Models
{
    public static class TaskInstance
    {
        public enum TaskStatus { Untried, Complete, FailedRetry, FailedNoRetry, Expired }

        public static string CreateSqlStatement(JObject taskMasterJson, JObject TaskInstanceJson, Logging.Logging logging)
        {
            string sqlStatement = "";
            JObject tmSource = (JObject)taskMasterJson["Source"];
            if (taskMasterJson["Source"]["IncrementalType"] != null)
            {
                JToken incrementalType = taskMasterJson["Source"]["IncrementalType"];
                JToken incrementalField = TaskInstanceJson["IncrementalField"];
                JToken incrementalColumnType = TaskInstanceJson["IncrementalColumnType"];
                JToken chunkField = taskMasterJson["Source"]["ChunkField"];
                JToken tableSchema = taskMasterJson["Source"]["TableSchema"];
                JToken tableName = taskMasterJson["Source"]["TableName"];
                JToken tableSchemaUpper = JToken.Parse((taskMasterJson["Source"]["TableSchema"].ToString()).ToUpper());
                JToken tableNameUpper = JToken.Parse((taskMasterJson["Source"]["TableName"].ToString()).ToUpper());
                string extractionSql =
                    JsonHelpers.GetStringValueFromJson(logging, "ExtractionSQL", tmSource, "", false);
                dynamic chunkSize = JsonHelpers.GetDynamicValueFromJson(logging, "ChunkSize", tmSource, "", false);

                //If Extraction SQL Explicitly set then overide _SQLStatement with that explicit value
                if (!string.IsNullOrWhiteSpace(extractionSql.ToString()))
                {
                    sqlStatement = extractionSql.ToString();
                    goto EndOfSQLStatementSet;
                }


                //Chunk branch
                if (taskMasterJson["Source"]["ChunkSize"] != null &&
                    taskMasterJson["Source"]["ChunkSize"].ToString() != "0")
                {
                    if (incrementalType.ToString() == "Full" &&
                        string.IsNullOrWhiteSpace(taskMasterJson["Source"]["ChunkSize"].ToString()))
                    {
                        if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                        {
                            sqlStatement = $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper}";
                        }
                        else {
                            sqlStatement = $"SELECT * FROM {tableSchema}.{tableName}";
                        }
                    }
                    else if (incrementalType.ToString() == "Full" &&
                             !string.IsNullOrWhiteSpace(taskMasterJson["Source"]["ChunkSize"].ToString()))
                    {
                        if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                        {
                            sqlStatement =
                            $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1. ";
                        }
                        else {
                            sqlStatement =
                            $"SELECT * FROM {tableSchema}.{tableName} WHERE CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1. ";
                        }
                    }
                    else if (incrementalType.ToString() == "Watermark" &&
                             string.IsNullOrWhiteSpace(taskMasterJson["Source"]["ChunkSize"].ToString()))
                    {
                        if (incrementalColumnType.ToString() == "DateTime")
                        {
                            DateTime incrementalValueDateTime = (DateTime)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime)";
                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime)";
                            }
                        }
                        else if (incrementalColumnType.ToString() == "BigInt")
                        {
                            int incrementalValueBigInt = (int)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= cast('<newWatermark>' as bigint)";
                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= cast('<newWatermark>' as bigint)";
                            }
                        }
                    }
                    else if (incrementalType.ToString() == "Watermark" &&
                             !string.IsNullOrWhiteSpace(taskMasterJson["Source"]["ChunkSize"].ToString()))
                    {
                        if (incrementalColumnType.ToString() == "DateTime")
                        {
                            DateTime incrementalValueDateTime = (DateTime)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime) AND CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1.";
                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime) AND CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1.";
                            }
                        }
                        else if (incrementalColumnType.ToString() == "BigInt")
                        {
                            int incrementalValueBigInt = (int)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= Cast('<newWatermark>' as bigint) AND CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1.";
                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= Cast('<newWatermark>' as bigint) AND CAST({chunkField} AS BIGINT) %  <batchcount> = <item> -1.";
                            }
                        }
                    }
                }
                else
                //Non Chunk
                {
                    if (incrementalType.ToString() == "Full")
                    {
                        if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                        {
                            sqlStatement = $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper}";
                        }
                        else {
                            sqlStatement = $"SELECT * FROM {tableSchema}.{tableName}";
                        }
                    }
                    else if (incrementalType.ToString() == "Watermark")
                    {
                        if (incrementalColumnType.ToString() == "DateTime")
                        {
                            DateTime incrementalValueDateTime = (DateTime)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime)";

                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")}' as datetime) AND {incrementalField} <= Cast('<newWatermark>' as datetime)";

                            }
                        }
                        else if (incrementalColumnType.ToString() == "BigInt")
                        {
                            int incrementalValueBigInt = (int)TaskInstanceJson["IncrementalValue"];
                            if (taskMasterJson["Source"]["System"]["Type"].ToString() == "Oracle Server")
                            {
                                sqlStatement =
                                $"SELECT * FROM {tableSchemaUpper}.{tableNameUpper} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= cast('<newWatermark>' as bigint)";

                            }
                            else {
                                sqlStatement =
                                $"SELECT * FROM {tableSchema}.{tableName} WHERE {incrementalField} > Cast('{incrementalValueBigInt}' as bigint) AND {incrementalField} <= cast('<newWatermark>' as bigint)";

                            }
                        }
                    }
                    else
                    if (incrementalType.ToString() == "CDC")
                    {
                        sqlStatement = $"";
                    }
                }

            }

        EndOfSQLStatementSet:
            return sqlStatement;
        }

        public static string CreateIncrementalSqlStatement(JObject Extraction)
        {
            string sqlStatement = "";

            if (Extraction["IncrementalType"] != null)
            {

                if (Extraction["IncrementalType"].ToString().ToLower() == "full")
                {
                    sqlStatement = "";
                }

                if (Extraction["IncrementalType"].ToString().ToLower() == "full-chunk")
                {
                    sqlStatement = @$"
                       SELECT 
		                    CAST(CEILING(count(*)/{Extraction["ChunkSize"]} + 0.00001) as int) as  batchcount
	                    FROM [{Extraction["TableSchema"]}].[{Extraction["TableName"]}] 
                    ";
                }

                if (Extraction["IncrementalType"].ToString().ToLower() == "watermark" &&
                    Extraction["IncrementalColumnType"].ToString().ToLower() == "datetime")
                {
                    sqlStatement = @$"
                        SELECT 
	                        MAX([{Extraction["IncrementalField"]}]) AS newWatermark
                        FROM 
	                        [{Extraction["TableSchema"]}].[{Extraction["TableName"]}] 
                        WHERE [{Extraction["IncrementalField"]}] > CAST('{Extraction["IncrementalValue"]}' as datetime)
                    ";
                }

                if (Extraction["IncrementalType"].ToString().ToLower() == "watermark" &&
                    Extraction["IncrementalColumnType"].ToString().ToLower() != "datetime")
                {
                    sqlStatement = @$"
                        SELECT 
	                        MAX({Extraction["IncrementalField"]}]) AS newWatermark
                        FROM 
	                        [{Extraction["TableSchema"]}].[{Extraction["TableName"]}] 
                        WHERE [{Extraction["IncrementalField"]}] > {Extraction["IncrementalValue"]}
                    ";
                }

                if (Extraction["IncrementalType"].ToString().ToLower() == "watermark-chunk" &&
                    Extraction["IncrementalColumnType"].ToString().ToLower() == "datetime")
                {
                    sqlStatement = @$"
                        SELECT MAX([{Extraction["IncrementalField"]}]) AS newWatermark, 
		                       CAST(CASE when count(*) = 0 then 0 else CEILING(count(*)/{Extraction["ChunkSize"]} + 0.00001) end as int) as  batchcount
	                    FROM  [{Extraction["TableSchema"]}].[{Extraction["TableName"]}] 
	                    WHERE [{Extraction["IncrementalField"]}] > CAST('{Extraction["IncrementalValue"]}' as datetime)
                    ";
                }

                if (Extraction["IncrementalType"].ToString().ToLower() == "watermark-chunk" &&
                    Extraction["IncrementalColumnType"].ToString().ToLower() != "datetime")
                {
                    sqlStatement = @$"
                        SELECT MAX([{Extraction["IncrementalField"]}]) AS newWatermark, 
		                       CAST(CASE when count(*) = 0 then 0 else CEILING(count(*)/{Extraction["ChunkSize"]} + 0.00001) end as int) as  batchcount
	                    FROM  [{Extraction["TableSchema"]}].[{Extraction["TableName"]}] 
	                    WHERE [{Extraction["IncrementalField"]}] > {Extraction["IncrementalValue"]}
                    ";
                }

            }

            return sqlStatement;
        }


        public static string DetermineIncrementalLoadType(JObject jsonValue)
        {
            string type = "";
            if (jsonValue["Source"]["IncrementalType"] != null)
            {
                JToken incrementalType = jsonValue["Source"]["IncrementalType"];

                if (jsonValue["Source"]["ChunkSize"] != null)
                {
                    if (incrementalType.ToString() == "Full" &&
                        (string.IsNullOrWhiteSpace(jsonValue["Source"]["ChunkSize"].ToString()) ||
                         jsonValue["Source"]["ChunkSize"].ToString() == "0"))
                    {
                        type = "Full";
                    }
                    else if (incrementalType.ToString() == "Full" &&
                             !string.IsNullOrWhiteSpace(jsonValue["Source"]["ChunkSize"].ToString()) &&
                             jsonValue["Source"]["ChunkSize"].ToString() != "0")
                    {
                        type = "Full-Chunk";
                    }
                    else if (incrementalType.ToString() == "Watermark" &&
                             string.IsNullOrWhiteSpace(jsonValue["Source"]["ChunkSize"].ToString()))
                    {
                        type = "Watermark";
                    }
                    else if (incrementalType.ToString() == "Watermark" &&
                             !string.IsNullOrWhiteSpace(jsonValue["Source"]["ChunkSize"].ToString()))
                    {
                        type = "Watermark-Chunk";
                    }
                }
                else
                {
                    type = incrementalType.ToString();
                }


            }

            return type;
        }
    }
}
