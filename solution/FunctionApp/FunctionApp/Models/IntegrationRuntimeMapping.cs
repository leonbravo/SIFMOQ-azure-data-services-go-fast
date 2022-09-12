/*-----------------------------------------------------------------------

 Copyright (c) Microsoft Corporation.
 Licensed under the MIT license.

-----------------------------------------------------------------------*/

using System;

namespace FunctionApp.Models
{
    public class IntegrationRuntimeMapping
    {
        public Int64 IntegrationRuntimeMappingId { get; set; }
        public Int64 IntegrationRuntimeId { get; set; }
        public string IntegrationRuntimeName { get; set; }
        public Int64 SystemId { get; set; }



    }
}
