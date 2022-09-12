using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebApplication.Services;
using WebApplication.Framework;
using WebApplication.Models;
using Newtonsoft.Json.Linq;
using System;
using Newtonsoft.Json;
using WebApplication.Forms;
using WebApplication.Models.Forms;
using WebApplication.Models.Wizards;

namespace WebApplication.Controllers
{
    public partial class SubjectAreaFormController : BaseController
    {
        protected readonly AdsGoFastContext _context;


        public SubjectAreaFormController(AdsGoFastContext context, ISecurityAccessProvider securityAccessProvider, IEntityRoleProvider roleProvider) : base(securityAccessProvider, roleProvider)
        {
            Name = "SubjectAreaForm";
            _context = context;
        }

        // GET: SubjectAreaForm
        public async Task<IActionResult> Index()
        {
            return View(await _context.SubjectAreaForm.ToListAsync());
        }

        // GET: SubjectAreaForm/Details/5
        [ChecksUserAccess]
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var subjectAreaForm = await _context.SubjectAreaForm
                .FirstOrDefaultAsync(m => m.SubjectAreaFormId == id);
            if (subjectAreaForm == null)
                return NotFound();
            if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                return new ForbidResult();


            return View(subjectAreaForm);
        }

        // GET: SubjectAreaForm/Create
        public IActionResult Create()
        {
     SubjectAreaForm subjectAreaForm = new SubjectAreaForm();
            return View(subjectAreaForm);
        }

        // POST: SubjectAreaForm/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Create([Bind("SubjectAreaFormId,FormJson,FormStatus,UpdatedBy,ValidFrom,ValidTo,Revision")] SubjectAreaForm subjectAreaForm)
        {
            if (ModelState.IsValid)
            {
                _context.Add(subjectAreaForm);
                if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                {
                    return new ForbidResult();
                }
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(IndexDataTable));
            }
            return View(subjectAreaForm);
        }

        // GET: SubjectAreaForm/Edit/5
        [ChecksUserAccess()]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var subjectAreaForm = await _context.SubjectAreaForm.FindAsync(id);
            if (subjectAreaForm == null)
                return NotFound();

            if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                return new ForbidResult();
            return View(subjectAreaForm);
        }

        public async Task<IActionResult> EditInWizard(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var subjectAreaForm = await _context.SubjectAreaForm.FindAsync(id);
            if (subjectAreaForm == null)
            {
                return NotFound();
            }
            return RedirectToAction("PIAWizardResume", "Wizards", new { id = id });
        }

        // POST: SubjectAreaForm/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ChecksUserAccess]
        public async Task<IActionResult> Edit(int id, [Bind("SubjectAreaFormId,FormJson,FormStatus,UpdatedBy,ValidFrom,ValidTo,Revision")] SubjectAreaForm subjectAreaForm)
        {
            if (id != subjectAreaForm.SubjectAreaFormId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(subjectAreaForm);

                    if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                        return new ForbidResult();
			
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SubjectAreaFormExists(subjectAreaForm.SubjectAreaFormId))
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
            return View(subjectAreaForm);
        }

        // GET: SubjectAreaForm/Delete/5
        [ChecksUserAccess]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var subjectAreaForm = await _context.SubjectAreaForm
                .FirstOrDefaultAsync(m => m.SubjectAreaFormId == id);
            if (subjectAreaForm == null)
                return NotFound();
		
            if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                return new ForbidResult();

            return View(subjectAreaForm);
        }

        // POST: SubjectAreaForm/Delete/5
        [HttpPost, ActionName("Delete")]
        [ChecksUserAccess()]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var subjectAreaForm = await _context.SubjectAreaForm.FindAsync(id);

            if (!await CanPerformCurrentActionOnRecord(subjectAreaForm))
                return new ForbidResult();
		
            _context.SubjectAreaForm.Remove(subjectAreaForm);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(IndexDataTable));
        }

        private bool SubjectAreaFormExists(int id)
        {
            return _context.SubjectAreaForm.Any(e => e.SubjectAreaFormId == id);
        }
        [ChecksUserAccess]
        public IActionResult IndexDataTable()
        {
            return View();
        }

        public JObject GridCols()
        {
            JObject GridOptions = new JObject();

            JArray cols = new JArray();
            cols.Add(JObject.Parse("{ 'data':'SubjectAreaFormId', 'name':'Id' }"));
            cols.Add(JObject.Parse("{ 'data':'FormStatus', 'name':'Status', }"));
            cols.Add(JObject.Parse("{ 'data':'UpdatedBy', 'name':'Updated By'}"));
            cols.Add(JObject.Parse("{ 'data':'ValidFrom', 'name':'Valid From'}"));
            cols.Add(JObject.Parse("{ 'data':'ValidTo', 'name':'Valid To' }"));
            cols.Add(JObject.Parse("{ 'data':'Revision', 'name':'Target' }"));

            HumanizeColumns(cols);

            JArray pkeycols = new JArray();
            pkeycols.Add("SubjectAreaFormId");

            JArray Navigations = new JArray();

            GridOptions["GridColumns"] = cols;
            GridOptions["ModelName"] = nameof(SubjectAreaForm);
            GridOptions["PrimaryKeyColumns"] = pkeycols;
            GridOptions["Navigations"] = Navigations;
            GridOptions["AutoWidth"] = false;
            //todo: put the button settings on the row!!
            //GridOptions["CrudButtons"] = GetSecurityFilteredActions("Create,Edit,Details,Delete");
            GridOptions["CrudButtons"] = new JArray("Create", "Edit", "Details", "Delete");

            return GridOptions;
        }


        [ChecksUserAccess]
        public ActionResult GetGridOptions()
        {
            return new OkObjectResult(JsonConvert.SerializeObject(GridCols()));
        }

        [ChecksUserAccess]
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
                var modelDataAll = (from temptable in _context.SubjectAreaForm
                                    select temptable);

                //filter the list by permitted roles
                if (!CanPerformCurrentActionGlobally())
                {
                    var permittedRoles = GetPermittedGroupsForCurrentAction();

                    modelDataAll =
                        (from md in modelDataAll
                         join sa in _context.SubjectArea
                            on md.SubjectAreaFormId equals sa.SubjectAreaFormId
                         join rm in _context.GetEntityRoleMapsFor(EntityRoleMap.SubjectAreaTypeName,GetUserAdGroupUids(), permittedRoles)
                            on sa.SubjectAreaId equals rm.EntityId
                         select md).Distinct();
                }

                //Sorting    
                if (!(string.IsNullOrEmpty(sortColumn) && string.IsNullOrEmpty(sortColumnDir)))
                {
                    modelDataAll = modelDataAll.OrderBy(sortColumn + " " + sortColumnDir);
                }
                //Search    
                if (!string.IsNullOrEmpty(searchValue))
                {
                    modelDataAll = modelDataAll.Where(m => m.FormJson.Contains(searchValue));
                }

                //Filter based on querystring params
                if (!(string.IsNullOrEmpty(Request.Form["QueryParams[FormStatus]"])))
                {
                    var formStatusFilter = System.Convert.ToInt64(Request.Form["QueryParams[FormStatus]"]);
                    modelDataAll = modelDataAll.Where(t => t.FormStatus == formStatusFilter);
                }

                if (!(string.IsNullOrEmpty(Request.Form["QueryParams[UpdatedBy]"])))
                {
                    var filter = Request.Form["QueryParams[UpdatedBy]"];
                    modelDataAll = modelDataAll.Where(t => t.UpdatedBy == filter);
                }

                //Custom Includes
                //modelDataAll = modelDataAll
                //    .Include(t => t).AsNoTracking();


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


        // GET: SubjectAreaForm/Revise/5
        [ChecksUserAccess]
        public async Task<IActionResult> Revise(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var subjectAreaForm = await _context.SubjectAreaForm.FindAsync(id);
            if (subjectAreaForm == null)
            {
                return NotFound();
            }
            if (!await base.CanPerformCurrentActionOnRecord(subjectAreaForm))
                return Forbid();

            // Create new SubjectAreaForm with copied values
            // Increment revision num and set form status back to 1
            var revisedSubjectAreaForm = new SubjectAreaForm
            {
                FormStatus = (byte)SubjectAreaFormStatus.Complete,
                FormJson = subjectAreaForm.FormJson,
                SubjectAreas = subjectAreaForm.SubjectAreas,
                Revision = (byte)(subjectAreaForm.Revision + 1)
            };

            // Add to db
            _context.SubjectAreaForm.Add(revisedSubjectAreaForm);
            await _context.SaveChangesAsync();

            // Deserialize model so we can reset some values
            var PIA = PIAWizardViewModel.FromForm(JsonConvert.DeserializeObject<PIAForm>(subjectAreaForm.FormJson, PIAForm.JsonSettings));

            // Set SubjectAreaId within the json after getting id of new SubjectAreaForm
            PIA.SubjectAreaId = revisedSubjectAreaForm.SubjectAreaFormId;
            PIA.MaxStep = 0;
            PIA.Step = 0;

            // Re-serialize and update db again
            revisedSubjectAreaForm.FormJson = JsonConvert.SerializeObject(PIA.ToForm());
            _context.Update(revisedSubjectAreaForm);
            await _context.SaveChangesAsync();

            // Now we can redireect to the wizard with our new SubjectAreaForm
            return RedirectToAction("PIAWizardResume", "Wizards", new { id = revisedSubjectAreaForm.SubjectAreaFormId });
        }
    }
}
