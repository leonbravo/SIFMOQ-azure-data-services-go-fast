using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using WebApplication.Models;

namespace WebApplication.Services
{
    /// <summary>
    /// Centralised goo that provides the lokup form entity to subject area role map (or other future role maps) 
    /// </summary>
    public class EntityRoleProvider : IEntityRoleProvider
    {
        private readonly AdsGoFastContext _context;

        public EntityRoleProvider(AdsGoFastContext context)
        {
            _context = context;
        }

        public async Task<string[]> GetUserRoles(object entity, params Guid[] groups)
        {
            switch (entity)
            {
                case FrameworkTaskRunner x:
                    return await LoadFrameworkTaskRunnerRoles(x.TaskRunnerId, groups);
                case SubjectArea x:
                    return await LoadSubjectAreaRoles(x.SubjectAreaId, groups);
                case SubjectAreaForm x:
                    return await LoadSubjectAreaFormRoles(x.SubjectAreaFormId, groups);
                case TaskGroup x:
                    return await LoadSubjectAreaRoles(x.SubjectAreaId, groups);
                case TaskInstance x:
                    return await LoadTaskInstanceRoles(x.TaskInstanceId, groups);
                case TaskInstanceExecution x:
                    return await LoadTaskInstanceRoles(x.TaskInstanceId, groups);
                case TaskMaster x:
                    return await LoadTaskMasterRoles(x.TaskMasterId, groups);
                case TaskMasterWaterMark x:
                    return await LoadTaskMasterRoles(x.TaskMasterId, groups);
                //these don't link back to subject area.
                case SourceAndTargetSystems x:
                    return await LoadSourceAndTargetSystemRoles(x.SystemId, groups);
                case ScheduleInstance x:
                    if (!x.ScheduleMasterId.HasValue)
                    {
                        return new string[0];
                    }
                    return await LoadScheduleMasterRoles(x.ScheduleMasterId.Value, groups);
                case ScheduleMaster x:
                    return await LoadScheduleMasterRoles(x.ScheduleMasterId, groups);
                case ExecutionEngine x:
                    return await LoadExecutionEngineRoles(x.EngineId, groups);
                default:
                    return new string[0];
            }
        }

        private Task<string[]> LoadExecutionEngineRoles(long xEngineId, Guid[] groups) =>
        (
            from tr in _context.ExecutionEngine
            join rm in ActiveRoleMaps(groups)
                on tr.EngineId equals rm.EntityId
            where rm.EntityTypeName == EntityRoleMap.ExecutionEngineTypeName
                  && rm.EntityId == xEngineId
            select rm.ApplicationRoleName
        ).ToArrayAsync();

        private Task<string[]> LoadScheduleMasterRoles(long systemId, Guid[] groups)
        {
            return (from tr in _context.ScheduleMaster
                    join rm in ActiveRoleMaps(groups)
                on tr.ScheduleMasterId equals rm.EntityId
                    where rm.EntityTypeName == EntityRoleMap.ScheduleMasterTypeName
                    && rm.EntityId == systemId
                    select rm.ApplicationRoleName
            ).ToArrayAsync();
        }

        private Task<string[]> LoadSourceAndTargetSystemRoles(long systemId, Guid[] groups) =>
            (
                from tr in _context.SourceAndTargetSystems
                join rm in ActiveRoleMaps(groups)
                    on tr.SystemId equals rm.EntityId
                where rm.EntityTypeName == EntityRoleMap.SourceAndTargetTypeName
                      && rm.EntityId == systemId
                select rm.ApplicationRoleName
            ).ToArrayAsync();

        private Task<string[]> LoadFrameworkTaskRunnerRoles(long taskRunnerId, Guid[] groups) =>
            (
                from tr in _context.FrameworkTaskRunner
                join ti in _context.TaskInstance
                    on tr.TaskRunnerId equals ti.TaskRunnerId
                join tm in _context.TaskMaster
                    on ti.TaskMasterId equals tm.TaskMasterId
                join tg in _context.TaskGroup
                    on tm.TaskGroupId equals tg.TaskGroupId
                join rm in ActiveRoleMaps(groups)
                    on tg.SubjectAreaId equals rm.EntityId
                where tr.TaskRunnerId == taskRunnerId
                && rm.EntityTypeName == EntityRoleMap.SubjectAreaTypeName
                select rm.ApplicationRoleName
            ).ToArrayAsync();

        private Task<string[]> LoadSubjectAreaRoles(long subjectAreaId, Guid[] groups) =>
            (
                from rm in ActiveRoleMaps(groups)
                where rm.EntityId == subjectAreaId
                      && rm.EntityTypeName == EntityRoleMap.SubjectAreaTypeName
                select rm.ApplicationRoleName
            ).ToArrayAsync();

        private Task<string[]> LoadSubjectAreaFormRoles(long subjectAreaFormId, Guid[] groups) =>
            (
                from rm in ActiveRoleMaps(groups)
                join sa in _context.SubjectArea
                    on rm.EntityId equals sa.SubjectAreaId
                where sa.SubjectAreaFormId == subjectAreaFormId
                      && rm.EntityTypeName == EntityRoleMap.SubjectAreaTypeName
                select rm.ApplicationRoleName
            ).ToArrayAsync();

        private Task<string[]> LoadTaskInstanceRoles(long taskInstanceId, Guid[] groups) =>
            (
                from ti in _context.TaskInstance
                join tm in _context.TaskMaster
                    on ti.TaskMasterId equals tm.TaskMasterId
                join tg in _context.TaskGroup
                   on tm.TaskGroupId equals tg.TaskGroupId
                join rm in ActiveRoleMaps(groups)
                   on tg.SubjectAreaId equals rm.EntityId
                where ti.TaskInstanceId == taskInstanceId
                      && rm.EntityTypeName == EntityRoleMap.SubjectAreaTypeName
                select rm.ApplicationRoleName
            ).ToArrayAsync();

        private Task<string[]> LoadTaskMasterRoles(long taskMasterId, Guid[] groups) =>
            (
                from tm in _context.TaskMaster
                join tg in _context.TaskGroup
                   on tm.TaskGroupId equals tg.TaskGroupId
                join rm in ActiveRoleMaps(groups)
                   on tg.SubjectAreaId equals rm.EntityId
                where tm.TaskMasterId == taskMasterId
                      && rm.EntityTypeName == EntityRoleMap.SubjectAreaTypeName
                select rm.ApplicationRoleName
            ).ToArrayAsync();



        IQueryable<EntityRoleMap> ActiveRoleMaps(Guid[] groups) =>
            _context.EntityRoleMap.Where(rm => groups.Contains(rm.AadGroupUid) && rm.ActiveYN && rm.ExpiryDate > DateTimeOffset.Now);
    }
}
