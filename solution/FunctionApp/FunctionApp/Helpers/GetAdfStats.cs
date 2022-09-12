using System;
using System.Collections.Generic;

namespace FunctionApp.Helpers
{
    public static class GetAdfStats
    {
        public static Dictionary<string, Type> GetKustoDataTypeMapper => new Dictionary<string, Type>
        {
            { "int", typeof(int) },
            { "string", typeof(string) },            
            { "real", typeof(double) },
            { "long", typeof(long) },
            { "datetime", typeof(DateTime) },
            { "guid", typeof(Guid) },
            { "dynamic", typeof(string) }
        };
    }
}