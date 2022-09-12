using System;
using System.Collections.Generic;
using WebApplication.Models;

namespace WebApplication.Extensions
{
    public static class OptionsExtensions
    {
        public static InputSelectionOptionsFor<T> AsInputSelectionOptions<T>(this IEnumerable<T> selected) where T : Enum => new InputSelectionOptionsFor<T>(selected);
    }
}