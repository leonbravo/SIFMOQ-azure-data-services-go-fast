using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebApplication.Services;
using WebApplication.Framework;
using WebApplication.Models;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

namespace WebApplication.Controllers
{
    public partial class IntegrationRuntimeMappingController : BaseController
    {
        protected readonly AdsGoFastContext _context;


        public IntegrationRuntimeMappingController(AdsGoFastContext context, ISecurityAccessProvider securityAccessProvider, IEntityRoleProvider roleProvider) : base(securityAccessProvider, roleProvider)
        {
            Name = "IntegrationRuntimeMapping";
            _context = context;
        }

        // GET: IntegrationRuntimeMappingController
        public async Task<IActionResult> Index()
        {
            var adsGoFastContext = _context.IntegrationRuntimeMapping.Include(t => t.SourceAndTargetSystem);
            return View(await adsGoFastContext.ToListAsync());
        }

        // GET: IntegrationRuntimeMappingController/Details/5
        [ChecksUserAccess]
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var integrationRuntimeMapping = await _context.IntegrationRuntimeMapping
                .Include(t => t.SourceAndTargetSystem)
                .FirstOrDefaultAsync(m => m.IntegrationRuntimeMappingId == id);
            if (integrationRuntimeMapping == null)
                return NotFound();
            if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                return new ForbidResult();


            return View(integrationRuntimeMapping);
        }

        // GET: TaskTypeMapping/Create
        public IActionResult Create()
        {
            ViewData["SystemId"] = new SelectList(_context.SourceAndTargetSystems.OrderBy(x => x.SystemName), "SystemId", "SystemName");
            IntegrationRuntimeMapping integrationRuntimeMapping = new IntegrationRuntimeMapping();
            integrationRuntimeMapping.ActiveYn = true;
            return View(integrationRuntimeMapping);
        }

        // POST: TaskTypeMapping/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Create([Bind("IntegrationRuntimeMappingId,IntegrationRuntimeId,IntegrationRuntimeName,SystemId,ActiveYN")] IntegrationRuntimeMapping integrationRuntimeMapping)
        {
            if (ModelState.IsValid)
            {
                _context.Add(integrationRuntimeMapping);
                if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                {
                    return new ForbidResult();
                }
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(IndexDataTable));
            }
            ViewData["SystemId"] = new SelectList(_context.SourceAndTargetSystems.OrderBy(x => x.SystemName), "SystemId", "SystemName", integrationRuntimeMapping.SystemId);
            return View(integrationRuntimeMapping);
        }

        // GET: TaskTypeMapping/Edit/5
        [ChecksUserAccess()]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var integrationRuntimeMapping = await _context.IntegrationRuntimeMapping.FindAsync(id);
            if (integrationRuntimeMapping == null)
                return NotFound();

            if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                return new ForbidResult();
            ViewData["SystemId"] = new SelectList(_context.SourceAndTargetSystems.OrderBy(x => x.SystemName), "SystemId", "SystemName", integrationRuntimeMapping.SystemId);
            return View(integrationRuntimeMapping);
        }

        // POST: TaskTypeMapping/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Edit(int id, [Bind("IntegrationRuntimeMappingId,IntegrationRuntimeId,IntegrationRuntimeName,SystemId,ActiveYN")] IntegrationRuntimeMapping integrationRuntimeMapping)
        {
            if (id != integrationRuntimeMapping.IntegrationRuntimeMappingId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(integrationRuntimeMapping);

                    if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                        return new ForbidResult();

                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!IntegrationRuntimeMappingExists(integrationRuntimeMapping.IntegrationRuntimeMappingId))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(IndexDataTable));
            }
            ViewData["SystemId"] = new SelectList(_context.SourceAndTargetSystems.OrderBy(x => x.SystemName), "SystemId", "SystemName", integrationRuntimeMapping.SystemId);
            return View(integrationRuntimeMapping);
        }

        // GET: TaskTypeMapping/Delete/5
        [ChecksUserAccess]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var integrationRuntimeMapping = await _context.IntegrationRuntimeMapping
                .Include(t => t.SourceAndTargetSystem)
                .FirstOrDefaultAsync(m => m.IntegrationRuntimeMappingId == id);
            if (integrationRuntimeMapping == null)
                return NotFound();

            if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                return new ForbidResult();

            return View(integrationRuntimeMapping);
        }

        // POST: TaskTypeMapping/Delete/5
        [HttpPost, ActionName("Delete")]
        [ChecksUserAccess()]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var integrationRuntimeMapping = await _context.IntegrationRuntimeMapping.FindAsync(id);

            if (!await CanPerformCurrentActionOnRecord(integrationRuntimeMapping))
                return new ForbidResult();

            _context.IntegrationRuntimeMapping.Remove(integrationRuntimeMapping);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(IndexDataTable));
        }

        private bool IntegrationRuntimeMappingExists(int id)
        {
            return _context.IntegrationRuntimeMapping.Any(e => e.IntegrationRuntimeMappingId == id);
        }

        public async Task<IActionResult> IndexDataTable()
        {
            var adsGoFastContext = _context.IntegrationRuntimeMapping.Take(1);
            return View(await adsGoFastContext.ToListAsync());
        }

        public JObject GridCols()
        {
            JObject GridOptions = new JObject();
            JArray cols = new JArray();
            cols.Add(JObject.Parse("{ 'data':'IntegrationRuntimeMappingId', 'name':'IntegrationRuntimeMappingId', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'SourceAndTargetSystems.SystemName', 'name':'SystemName', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'IntegrationRuntimeId', 'name':'IntegrationRuntimeId', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'IntegrationRuntimeName', 'name':'IntegrationRuntimeName', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'SystemId', 'name':'SystemId', 'autoWidth':true }"));


            HumanizeColumns(cols);

            JArray pkeycols = new JArray();
            pkeycols.Add("IntegrationRuntimeMappingId");

            JArray Navigations = new JArray();

            GridOptions["GridColumns"] = cols;
            GridOptions["ModelName"] = "IntegrationRuntimeMapping";
            GridOptions["PrimaryKeyColumns"] = pkeycols;
            GridOptions["Navigations"] = Navigations;
            GridOptions["CrudButtons"] = GetSecurityFilteredActions("Create,Edit,Details,Delete");

            return GridOptions;
        }

        public ActionResult GetGridOptions()
        {
            return new OkObjectResult(JsonConvert.SerializeObject(GridCols()));
        }

        public async Task<ActionResult> GetGridData()
        {
            try
            {

                string draw = Request.Form["draw"];
                string start = Request.Form["start"];
                string length = Request.Form["length"];
                string sortColumn = Request.Form["columns[" + Request.Form["order[0][column]"] + "][data]"];
                string sortColumnDir = Request.Form["order[0][dir]"];

                string searchValue = Request.Form["search[value]"];

                //Paging Size (10,20,50,100)    
                int pageSize = length != null ? Convert.ToInt32(length) : 0;
                int skip = start != null ? Convert.ToInt32(start) : 0;
                int recordsTotal = 0;

                // Getting all Customer data    
                var modelDataAll = (from temptable in _context.IntegrationRuntimeMapping
                                    select temptable);

                //Sorting    
                if (!(string.IsNullOrEmpty(sortColumn) && string.IsNullOrEmpty(sortColumnDir)))
                {
                    modelDataAll = modelDataAll.OrderBy(sortColumn + " " + sortColumnDir);
                }
                //Search    
                if (!string.IsNullOrEmpty(searchValue))
                {
                    modelDataAll = modelDataAll.Where(m => m.IntegrationRuntimeName.Contains(searchValue));
                }

                //Filter based on querystring params
                if (!(string.IsNullOrEmpty(Request.Form["QueryParams[SystemId]"])))
                {
                    var tasktypefilter = System.Convert.ToInt64(Request.Form["QueryParams[SystemId]"]);
                    modelDataAll = modelDataAll.Where(t => t.SystemId == tasktypefilter);
                }

                //Custom Includes
                modelDataAll = modelDataAll
                    .Include(t => t.SourceAndTargetSystem).AsNoTracking();

                //total number of rows count     
                recordsTotal = await modelDataAll.CountAsync();

                //Paging               
                var data = await modelDataAll.Skip(skip).Take(pageSize).ToListAsync();

                //Returning Json Data    
                var jserl = new JsonSerializerSettings
                {
                    ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                    Converters = { new Newtonsoft.Json.Converters.StringEnumConverter() }
                };

                return new OkObjectResult(JsonConvert.SerializeObject(new { draw = draw, recordsFiltered = recordsTotal, recordsTotal = recordsTotal, data = data }, jserl));

            }
            catch (Exception)
            {
                throw;
            }
        }

        public async Task<IActionResult> FindMapping()
        {




            List<TaskTypeMapping> taskTypeMappings = new List<TaskTypeMapping>();
            List<IntegrationRuntimeMapping> sourceIntegrationRuntimeMappings = new List<IntegrationRuntimeMapping>();
            List<IntegrationRuntimeMapping> targetIntegrationRuntimeMappings = new List<IntegrationRuntimeMapping>();

            Int64 SourceSystemId = System.Convert.ToInt64(Request.Form["SourceSystemId"]);
            Int64 TargetSystemId = System.Convert.ToInt64(Request.Form["TargetSystemId"]);
            sourceIntegrationRuntimeMappings = await _context.IntegrationRuntimeMapping.Where(m => m.SystemId == SourceSystemId && m.ActiveYn == true).ToListAsync();
            targetIntegrationRuntimeMappings = await _context.IntegrationRuntimeMapping.Where(m => m.SystemId == TargetSystemId && m.ActiveYn == true).ToListAsync();



            if (sourceIntegrationRuntimeMappings.Count == 0 || targetIntegrationRuntimeMappings.Count == 0)
            {
                return NotFound("Integration Runtime Mappings do not exist (or may not be active) for EITHER this Source or this Target System");
            }
            List<IntegrationRuntime> ValidIRs = new List<IntegrationRuntime>();
            foreach (var i in sourceIntegrationRuntimeMappings)
            {
                //var ValidIR = _context.IntegrationRuntime.Where(s => targetIntegrationRuntimeMappings.Contains(i));
                //we want to grab IRs where the source and target both have permissions within the IntegrationRuntimeMapping table and are currently set to active
                foreach (var j in targetIntegrationRuntimeMappings)
                {
                    var ValidIR = await _context.IntegrationRuntime.Where(s => s.IntegrationRuntimeName == i.IntegrationRuntimeName && s.IntegrationRuntimeName == j.IntegrationRuntimeName && s.ActiveYn == true).ToListAsync();
                    if (ValidIR.Any())
                    {
                        ValidIRs.Add(ValidIR.ToList<IntegrationRuntime>()[0]);
                    }
                }
                
            }
            if (ValidIRs.Count == 0)
            {
                return NotFound("Integration Runtime Mappings do not exist (or may not be active) for this current Source and Target System COMBINATION");
            }
            
            return new OkObjectResult(JsonConvert.SerializeObject(new { ValidIRs = ValidIRs }));
        }
        public async Task<ActionResult> BulkUpdateTaskTypeMappingTaskMasterJsonSchema()
        {
            List<Int64> Pkeys = JsonConvert.DeserializeObject<List<Int64>>(Request.Form["Pkeys"]);
            string Json = Request.Form["Json"];
            var entitys = _context.TaskTypeMapping.Where(ti => Pkeys.Contains(ti.TaskTypeMappingId));

            entitys.ForEachAsync(ti =>
            {
                ti.TaskMasterJsonSchema = Json;
            }).Wait();

            await _context.SaveChangesAsync();

            return new OkObjectResult(new { });
        }
    }
}
