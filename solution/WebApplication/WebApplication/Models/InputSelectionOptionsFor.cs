using System;
using System.Collections.Generic;
using System.Linq;
using WebApplication.Forms.PIAWizard;

namespace WebApplication.Models
{
  
    public class InputSelectionOptionsFor<T> where T : System.Enum
    {
        public List<InputOption<T>> Options { get; set; } = new List<InputOption<T>>();

        public InputSelectionOptionsFor(IEnumerable<T> selected = null)
        {
            var selectedItems = selected?.ToArray() ?? new T[0];

            foreach (T option in Enum.GetValues(typeof(T)))
            {
                Options.Add(new InputOption<T>
                {
                    Option = option,
                    IsSelected = selectedItems.Contains(option)
                });
            }
        }

        public string TemplateName
        {
            get
            {                
                var genericType = typeof(T).Name;
                return $"EditorFor{genericType}";
            }
        }

        public IList<T> GetSelections() => this.Options.Where(x => x.IsSelected).Select(x => x.Option).ToList();
    }
}
