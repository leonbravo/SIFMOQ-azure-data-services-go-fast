using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.ApplicationInsights.DataContracts;

namespace FunctionApp.Helpers
{
    public class SuccessfulDependencyFilter : ITelemetryProcessor
    {
        private ITelemetryProcessor Next { get; set; }

        // next will point to the next TelemetryProcessor in the chain.
        public SuccessfulDependencyFilter(ITelemetryProcessor next)
        {
            this.Next = next;
        }

        public void Process(ITelemetry item)
        {
            // To filter out an item, return without calling the next processor.
            if (!OKtoSend(item)) { 
                return; 
            }

            this.Next.Process(item);
        }

        // Filter out Cancelled Http Requests for the RunFrameworkTasksHttpTrigger.
        private bool OKtoSend(ITelemetry item)
        {
            var dependency = item as DependencyTelemetry;
            if (dependency != null)
            {
                if (dependency.ResultCode == "Canceled" &&  dependency.Name == "GET //api/RunFrameworkTasksHttpTrigger" || dependency.Name == "GET /api/RunFrameworkTasksHttpTrigger")
                { 
                    return false; 
                }
            }

            return true;
        }
    }
}
