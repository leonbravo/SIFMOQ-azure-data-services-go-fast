using System;
using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace WebApplication.Models
{
    public class UserReference
    {
        public string DisplayName { get; set; }
        [Required(ErrorMessage = "You must select a user")]
        public string UserId { get; set; }

        [JsonIgnore]
        [Obsolete("Property has been renamed to UserId and now contains either the UPN or the ObjectId depending on available claims", true)]
        public string UserPrincipalName { get => UserId; set => UserId = value; }
    }
}
