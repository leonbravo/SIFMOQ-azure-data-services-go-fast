using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using WebApplication.Framework;
using WebApplication.Models;
using WebApplication.Models.Wizards;
using WebApplication.Services;
using WebApplication.Models.Forms;
using WebApplication.Models.Options;

namespace WebApplication.Controllers
{
    public class WizardsController : BaseController
    {
        private readonly AdsGoFastContext _context;
        private readonly IMicrosoftGraphService _graphService;
        private readonly IOptions<ApplicationOptions> _options;

        public WizardsController(AdsGoFastContext context,
            Services.ISecurityAccessProvider securityProvider,
            Services.IEntityRoleProvider roleProvider,
            IMicrosoftGraphService graphService,
            IOptions<ApplicationOptions> options)
            : base(securityProvider, roleProvider)
        {
            _context = context;
            _graphService = graphService;
            _options = options;
        }

        [HttpGet]
        public async Task<IActionResult> ExternalFileUpload()
        {
            ViewData["UploadSystemId"] = new SelectList(await _context.SourceAndTargetSystems.Where(t => t.SystemType.ToLower() == "azure blob").OrderBy(t => t.SystemName).ToListAsync(), "SystemId", "SystemName");
            ViewData["EmailSystemId"] = new SelectList(await _context.SourceAndTargetSystems.Where(t => t.SystemType.ToLower() == "sendgrid").OrderBy(t => t.SystemName).ToListAsync(), "SystemId", "SystemName");
            ViewData["TargetSystemId"] = new SelectList(await _context.SourceAndTargetSystems.Where(t => t.SystemType.ToLower() == "azure blob" || t.SystemType.ToLower() == "adls").OrderBy(t => t.SystemName).ToListAsync(), "SystemId", "SystemName");
            ViewData["TaskGroupId"] = new SelectList(await _context.TaskGroup.OrderBy(t => t.TaskGroupName).ToListAsync(), "TaskGroupId", "TaskGroupName");
            ViewData["ScheduleMasterId"] = new SelectList(await _context.ScheduleMaster.OrderBy(t => t.ScheduleDesciption).ToListAsync(), "ScheduleMasterId", "ScheduleDesciption");
            ViewData["EngineId"] = new SelectList(await _context.ExecutionEngine.OrderBy(t => t.EngineName).ToListAsync(), "EngineId", "EngineName");
            ViewData["IntegrationRuntimeId"] = new SelectList(await _context.IntegrationRuntime.OrderBy(t => t.IntegrationRuntimeName).ToListAsync(), "IntegrationRuntimeId", "IntegrationRuntimeName");
            

            return View();
        }

        private async Task SetViewBagDataForPIA()
        {
            ViewBag.SourceSystems = new SelectList(_context.SourceAndTargetSystems
                .OrderBy(x => x.SystemName), "SystemId", "SystemName");

            var sites = new List<Site>() { new Site(){Name = _options.Value.SiteName, Id = _options.Value.SiteId} }; 
            ViewBag.Sites = new SelectList(sites.OrderBy(x => x.Name), "Id", "Name");

            var users = await GetUsers();
            ViewBag.Users = new SelectList(users.OrderBy(x => x.DisplayName),
                "UserId", "DisplayName");
        }

        [HttpGet]
        [ChecksUserAccess]
        [Route("Wizards/PIAWizard/{subjectAreaId}")]
        public async Task<IActionResult> PIAWizard([FromRoute] int subjectAreaId)
        {
            await SetViewBagDataForPIA();

            var subjectAreaRecord = await _context.SubjectArea
                .Include(x => x.SubjectAreaForm)
                .FirstOrDefaultAsync(x => x.SubjectAreaId == subjectAreaId);

            if (subjectAreaRecord == null)
                return View("Error", new ErrorViewModel { Message = "Subject area not found." });

            var hasGlobalPermission = await CanPerformCurrentActionOnRecord(subjectAreaRecord);
            var hasSpecialPermission = await this.CanEditSubjectArea(subjectAreaRecord);
            if (!hasGlobalPermission && !hasSpecialPermission)
                return Forbid();

            if ((SubjectAreaFormStatus?)subjectAreaRecord.SubjectAreaForm.FormStatus == SubjectAreaFormStatus.Complete)
            {
                return RedirectToAction("Revise", "SubjectArea", new {id = subjectAreaId});
            }

            PIAWizardViewModel PIA = PIAWizardViewModel.FromForm(JsonConvert.DeserializeObject<PIAForm>(subjectAreaRecord.SubjectAreaForm.FormJson, PIAForm.JsonSettings));

            if (!await base.CanPerformCurrentActionOnRecord(subjectAreaRecord.SubjectAreaForm))
                return Forbid();

            // Ensure SubjectAreaId is in hidden field
            PIA.SubjectAreaId = subjectAreaId;

            return View("PIAWizard", PIA);
        }

        [HttpPost]
        [ChecksUserAccess]
        [Route("Wizards/PIAWizard/{subjectAreaId}")]
        public async Task<IActionResult> PIAWizardPost([FromRoute] int subjectAreaId, [FromForm] PIAWizardViewModel PIA)
        {
            if (subjectAreaId == 0)
                return RedirectToAction("IndexDataTable", "SubjectArea");

            var subjectAreaRecord = await _context.SubjectArea
                .Include(x => x.SubjectAreaForm)
                .FirstOrDefaultAsync(x => x.SubjectAreaId == subjectAreaId);

            if (subjectAreaRecord == null)
                return View("Error", new ErrorViewModel { Message = "Subject area not found." });

            var hasGlobalPermission = await CanPerformCurrentActionOnRecord(subjectAreaRecord);
            var hasSpecialPermission = await this.CanEditSubjectArea(subjectAreaRecord);
            if (!hasGlobalPermission && !hasSpecialPermission)
                return Forbid();

            await SetViewBagDataForPIA();

            // not sure if this will break anything but surely we do want the user to be able to save the form on step 0?
            if (PIA.Step >= 0 || PIA.SubmissionMethod == 1) // If wizard has been started or submitting page 0
            {
                SubjectAreaForm subjectAreaForm;

                if (PIA.SubjectAreaId == 0) // If database entry has not been created
                {
                    ModelState.Remove("Step"); // Remove so we can manually set
                    PIA.Step++;
                    subjectAreaForm = CreatePIADataEntry(PIA);

                    _context.Add(subjectAreaForm);

                    await _context.SaveChangesAsync();

                    ModelState.Remove("SubjectAreaId"); // remove so we can manually set
                    PIA.SubjectAreaId = subjectAreaId; // Set dbid to keep track for next time

                    // Reserialize json now that we have our auto generated id
                    subjectAreaForm.FormJson = JsonConvert.SerializeObject(PIA.ToForm());
                    _context.Update(subjectAreaForm);
                    await _context.SaveChangesAsync();
                }
                else // Database entry exists
                {
                    subjectAreaForm = await UpdatePIAData(PIA);

                    _context.Update(subjectAreaForm);

                    await _context.SaveChangesAsync();

                    // If submitted form
                    if (subjectAreaForm.FormStatus == (int)SubjectAreaFormStatus.Complete)
                    {
                        // notify all users whose roles are set throgh the form by email
                        string[] stewards = PIA.DataStewards.Select(ds => ds.UserId).ToArray();

                        SendNotificationToSubjectAreaUsers(stewards);

                        DoProcessingAndAutomationForSubjectArea();
                        
                        // Redirect out of wizard and
                        return RedirectToAction("Details", "SubjectArea", new { id = PIA.SubjectAreaId });
                    }
                    else
                    {
                        IncrementStep(PIA);
                    }
                }
            }
            else
            {
                ModelState.Remove("Step"); // Remove so we can manually set
                PIA.Step = 0;

                IncrementStep(PIA);
            }

            return View(nameof(PIAWizard), PIA);
        }

        private void DoProcessingAndAutomationForSubjectArea()
        {
            // TODO:
            // If there are any automation steps like setting up security access / Azure AD security groups etc
        }

        private void SendNotificationToSubjectAreaUsers(string[] stewards)
        {
            //TODO: Send emails to PIA.DataOwner.UserId, PIA.DataCustodian.UserId, and stewards
        }

        private async Task<SubjectAreaForm> UpdatePIAData(PIAWizardViewModel PIA)
        {
            var subjectArea = await _context.SubjectArea.FindAsync(PIA.SubjectAreaId);
            var subjectAreaForm = await _context.SubjectAreaForm.FindAsync(subjectArea.SubjectAreaFormId);
            if (PIA.Step == 8 && PIA.SubmissionMethod == 1) // only formally submits on summary page
            {
                if (ModelState.IsValid) // server side validation performed on last step
                {
                    subjectAreaForm.FormStatus = (int)SubjectAreaFormStatus.Complete; // Set status to submitted
                }
            }

            subjectAreaForm.FormJson = JsonConvert.SerializeObject(PIA.ToForm()); // Update json
            return subjectAreaForm;
        }

        private SubjectAreaForm CreatePIADataEntry(PIAWizardViewModel PIA)
        {
            // Construct Base Database entry
            SubjectAreaForm subjectAreaForm = new SubjectAreaForm();
            subjectAreaForm.Revision = 1;
            subjectAreaForm.UpdatedBy = User.Identity.Name;
            subjectAreaForm.FormStatus = (int)SubjectAreaFormStatus.Incomplete;
            subjectAreaForm.FormJson = JsonConvert.SerializeObject(PIA.ToForm());
            return subjectAreaForm;
        }

        private void IncrementStep(PIAWizardViewModel PIA)
        {
            // If pressed next, increment step
            if (PIA.SubmissionMethod == 1)
            {
                PIA.Step++;
            }
        }

        [HttpPost]
        public async Task<IActionResult> AddDataSteward([Bind("DataStewards")] PIAWizardViewModel pia)
        {
            var users = await GetUsers();

            ViewBag.Users = new SelectList(users, "UserId", "DisplayName");

            var dataSteward = new UserReference();

            pia.DataStewards.Add(dataSteward);

            return PartialView("_DataStewards", pia);
        }

        [HttpPost]
        public async Task<IActionResult> RemoveDataSteward([Bind("DataStewards")] PIAWizardViewModel pia)
        {
            var users = await GetUsers();

            ViewBag.Users = new SelectList(users, "UserId", "DisplayName"); // find better way to do this

            if (pia.DataStewards.Count > 1)
            {
                pia.DataStewards.RemoveAt(pia.DataStewards.Count - 1);
            }

            return PartialView("_DataStewards", pia);
        }

        private async Task<List<UserReference>> GetUsers()
        {
            var members = await _graphService.GetMembers();

            return members.OrderBy(m => m.DisplayName).ToList();
        }

        [HttpGet]
        public async Task<IActionResult> PIASummary(int? id)
        {
            if (id == null)
            {
                return RedirectToAction("IndexDataTable", "SubjectArea");
            }

            var subjectArea = await _context.SubjectArea.FindAsync(id);

            var saform = await _context.SubjectAreaForm.FindAsync(subjectArea.SubjectAreaFormId);

            PIAWizardViewModel PIA = PIAWizardViewModel.FromForm(JsonConvert.DeserializeObject<PIAForm>(saform.FormJson, PIAForm.JsonSettings));

            return View(PIA);
        }

        [HttpPost]
        [ChecksUserAccess]
        public async Task<IActionResult> PostEFN(ExternalFileUpload upload)
        {

            if (!ModelState.IsValid)
            {
                return View(nameof(ExternalFileUpload), upload);
            }

            TaskMaster taskMaster = new TaskMaster()
            {
                TaskMasterName = upload.TaskMasterName,
                TaskTypeId = (int)upload.TaskTypeId,
                TaskGroupId = upload.TaskGroupId,
                ScheduleMasterId = upload.ScheduleMasterId,
                SourceSystemId = upload.EmailSystemId,
                TargetSystemId = upload.TargetSystemId,
                AllowMultipleActiveInstances = upload.AllowMultipleActiveInstances,
                TaskDatafactoryIr = upload.TaskDatafactoryIr,
                // data on external parties is not being stored currently
                TaskMasterJson = upload.ExternalParties,
                ActiveYn = upload.IsActive,
                DependencyChainTag = upload.DependencyChainTag,
                EngineId = upload.EngineId,
                DegreeOfCopyParallelism = upload.DegreeOfCopyParallelism,
            };

            taskMaster.ScheduleMaster = await _context.ScheduleMaster.FindAsync(taskMaster.ScheduleMasterId);
            taskMaster.SourceSystem = await _context.SourceAndTargetSystems.FindAsync(taskMaster.SourceSystemId);
            taskMaster.TargetSystem = await _context.SourceAndTargetSystems.FindAsync(taskMaster.TargetSystemId);
            taskMaster.TaskGroup = await _context.TaskGroup.FindAsync(taskMaster.TaskGroupId);
            var tt = await _context.TaskType
                .Where(t => string.Equals(t.TaskTypeName.ToLower(), "generate and send sas uri file upload link"))
                .ToListAsync();

            taskMaster.TaskType = tt.FirstOrDefault();
            taskMaster.TaskTypeId = taskMaster.TaskType?.TaskTypeId ?? 0;

            var masterJson = new
            {
                Source = new
                {
                    Type = "SASUri",
                    SasURIDaysValid = 7,
                    RelativePath = upload.RelativePath,
                    DataFileName = upload.UploadFileName,
                    TargetSystem = upload.TargetSystemId,
                    FileUploaderWebAppURL = upload.FileUploaderWebAppURL,
                    TargetSystemUidInPHI = upload.TargetSystemUidInPHI // target system guid user inputs?
                },
                Target = new
                {
                    Type = "Email",
                    EmailSubject = upload.EmailSubject,
                    EmailRecipient = upload.OperatorEmail,
                    EmailRecipientName = upload.OperatorName,
                    EmailTemplateFileName = "SasUriEmailTemplate"
                }
            };

            taskMaster.TaskMasterJson = JsonConvert.SerializeObject(masterJson);

            await _context.TaskMaster.AddAsync(taskMaster);
            if (!await CanPerformCurrentActionOnRecord(taskMaster))
            {
                return new ForbidResult();
            }

            await _context.SaveChangesAsync();

            return RedirectToAction("Details", "TaskMaster", new { id = taskMaster.TaskMasterId });
        }
    }
}
