using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.Graph;
using WebApplication.Services;
using WebApplication.Framework;
using WebApplication.Models;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using WebApplication.Forms;
using WebApplication.Models.Forms;
using WebApplication.Models.Options;
using WebApplication.Models.Wizards;
using Site = WebApplication.Models.Site;

namespace WebApplication.Controllers
{
    public partial class EntityRoleMapController : BaseController
    {
        protected readonly AdsGoFastContext _context;
        private readonly IOptions<ApplicationOptions> _options;

        List<SelectListItem> entityType = new List<SelectListItem>
        {
            new SelectListItem { Text = "SourceAndTargetSystems", Value = "SourceAndTargetSystems"},
            new SelectListItem { Text = "ExecutionEngine", Value = "ExecutionEngine"},
            new SelectListItem { Text = "ScheduleMaster", Value = "ScheduleMaster"},
            new SelectListItem { Text = "SubjectArea", Value = "SubjectArea"},

        };


        List<SelectListItem> roles = new List<SelectListItem>
        {
            new SelectListItem { Text = "Administrator", Value = "Administrator"},
        };

        public EntityRoleMapController(AdsGoFastContext context, ISecurityAccessProvider securityAccessProvider, IEntityRoleProvider roleProvider, IOptions<ApplicationOptions> options) : base(securityAccessProvider, roleProvider)
        {
            Name = "EntityRoleMap";
            _context = context;
            _options = options;
        }

        // GET: SubjectArea
        public async Task<IActionResult> Index()
        {
            var adsGoFastContext = _context.EntityRoleMap;
            return View(await adsGoFastContext.ToListAsync());
        }

        // GET: SubjectArea/Details/5
        [ChecksUserAccess]
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var roleMap = await _context.EntityRoleMap
                .FirstOrDefaultAsync(m => m.EntityRoleMapId == id);
            if (roleMap == null)
                return NotFound();
            if (!await CanPerformCurrentActionOnRecord(roleMap))
                return new ForbidResult();


            return View(roleMap);
        }

        // GET: SubjectArea/Create
        public IActionResult Create()
        {
        	if (!CanPerformCurrentActionGlobally())
            {
                return Forbid();
            }
            //TODO: Create the correct drop downs
            ViewData["EntityTypes"] = new SelectList(entityType, "Value", "Text");
            ViewData["ApplicationRoles"] = new SelectList(roles, "Value", "Text");

            EntityRoleMap entity = new EntityRoleMap();
            entity.ActiveYN = true;
            return View(entity);
        }

        // POST: SubjectArea/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Create(
            [Bind("EntityRoleMapId,EntityId,EntityTypeName,AadGroupUid, ApplicationRoleName,ExpiryDate,ActiveYN,UpdatedBy")]
            EntityRoleMap entityRoleMap)
        {
            if (ModelState.IsValid)
            {
                entityRoleMap.UpdatedBy = User.Identity.Name;
                _context.Add(entityRoleMap);
                if (!await CanPerformCurrentActionOnRecord(entityRoleMap))
                {
                    return new ForbidResult();
                }

                await _context.SaveChangesAsync();
                try
                {
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateException e)
                {
                    ModelState.AddModelError("EntityRoleMapId", e.InnerException.Message);
                    return View(entityRoleMap);
                }

                /*if (entityRoleMap.EntityRoleMapId == 0)
                {
                    await CreateEmptyEntityRoleMapAndPIAAsync(entityRoleMap);
                }*/

                
            }
            return RedirectToAction(nameof(IndexDataTable));
        }


        // GET: SubjectArea/Edit/5
        [ChecksUserAccess()]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var entityRoleMap = await _context.EntityRoleMap.FindAsync(id);
            if (entityRoleMap == null)
                return NotFound();
            ViewData["EntityTypes"] = new SelectList(entityType, "Value", "Text");
            ViewData["ApplicationRoles"] = new SelectList(roles, "Value", "Text");
            if (!await CanPerformCurrentActionOnRecord(entityRoleMap))
                return new ForbidResult();
            return View(entityRoleMap);
        }

        // POST: SubjectArea/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Edit(int id, [Bind("EntityRoleMapId,EntityId,EntityTypeName,AadGroupUid, ApplicationRoleName,ExpiryDate,ActiveYN,UpdatedBy")] EntityRoleMap entityRoleMap)
        {
            if (id != entityRoleMap.EntityRoleMapId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    entityRoleMap.UpdatedBy = User.Identity.Name;
                    _context.Update(entityRoleMap);

                    if (!await CanPerformCurrentActionOnRecord(entityRoleMap))
                        return new ForbidResult();

                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!EntityRoleMapExists(entityRoleMap.EntityRoleMapId))
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
            return View(entityRoleMap);
        }

        [ChecksUserAccess]
        // GET: SourceAndTargetSystems/Delete/5
        public async Task<IActionResult> Delete(long? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var entityRoleMap = await _context.EntityRoleMap
                .FirstOrDefaultAsync(m => m.EntityRoleMapId == id);
            if (entityRoleMap == null)
                return NotFound();

            if (!await CanPerformCurrentActionOnRecord(entityRoleMap))
                return new ForbidResult();

            return View(entityRoleMap);
        }

        // POST: SourceAndTargetSystems/Delete/5
        [HttpPost, ActionName("Delete")]
        [ChecksUserAccess()]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(long id)
        {
            var entityRoleMap = await _context.EntityRoleMap.FindAsync(id);

            if (!await CanPerformCurrentActionOnRecord(entityRoleMap))
                return new ForbidResult();

            _context.EntityRoleMap.Remove(entityRoleMap);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(IndexDataTable));
        }

        private bool EntityRoleMapExists(long id)
        {
            return _context.EntityRoleMap.Any(e => e.EntityRoleMapId == id);
        }

        public IActionResult IndexDataTable()
        {
            return View();
        }

        public JObject GridCols()
        {
            JObject GridOptions = new JObject();

            JArray cols = new JArray();
            cols.Add(JObject.Parse("{ 'data':'EntityRoleMapId', 'name':'EntityRoleMapId', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'EntityId', 'name':'EntityId', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'EntityTypeName', 'name':'EntityTypeName', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'AadGroupUid', 'name':'AadGroupUid', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'ApplicationRoleName', 'name':'ApplicationRoleName', 'autoWidth':true }"));
            cols.Add(JObject.Parse("{ 'data':'ExpiryDate', 'name':'ExpiryDate', 'autoWidth':true, 'ads_format': 'DateTime' }"));
            cols.Add(JObject.Parse("{ 'data':'ActiveYN', 'name':'ActiveYN', 'autoWidth':true, 'ads_format':'bool'}"));
            cols.Add(JObject.Parse("{ 'data':'UpdatedBy', 'name':'UpdatedBy', 'autoWidth':true }"));

            HumanizeColumns(cols);
            JArray Navigations = new JArray();

            JArray pkeycols = new JArray();
            pkeycols.Add("EntityRoleMapId");

            GridOptions["GridColumns"] = cols;
            GridOptions["ModelName"] = "EntityRoleMap";
            GridOptions["PrimaryKeyColumns"] = pkeycols;
            GridOptions["Navigations"] = Navigations;
            GridOptions["CrudController"] = "EntityRoleMap";
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
                var modelDataAll = (from temptable in _context.EntityRoleMap
                                    select temptable);

                //Sorting    
                if (!(string.IsNullOrEmpty(sortColumn) && string.IsNullOrEmpty(sortColumnDir)))
                {
                    modelDataAll = modelDataAll.OrderBy(sortColumn + " " + sortColumnDir);
                }
                //Search    
                if (!string.IsNullOrEmpty(searchValue))
                {
                    modelDataAll = modelDataAll.Where(m => m.EntityTypeName == searchValue);
                }

                //total number of rows count     
                recordsTotal = await modelDataAll.CountAsync();
                //Paging     
                var data = await modelDataAll.Skip(skip).Take(pageSize).ToListAsync();
                //Returning Json Data    
                return new OkObjectResult(JsonConvert.SerializeObject(new { draw = draw, recordsFiltered = recordsTotal, recordsTotal = recordsTotal, data = data }, new Newtonsoft.Json.Converters.StringEnumConverter()));

            }
            catch (Exception)
            {
                throw;
            }

        }


    }
}
