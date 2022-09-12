/*

Delete [dbo].[TaskGroupDependency]  
where AncestorTaskGroupid in (-8, -9)

Delete TaskGroup
where TaskGroupId in (-8,-9, -10)

Delete TaskMaster
where TaskMasterId <= -2000


*/


         
SET IDENTITY_INSERT [dbo].[TaskGroup] ON
Insert into TaskGroup
([TaskGroupId],[SubjectAreaId], [TaskGroupName], [TaskGroupPriority],[TaskGroupConcurrency],[TaskGroupJSON],[MaximumTaskRetries],[ActiveYN])
VALUES
(-8, 1, N'SIF - Create Codesets & Load Raw Entities to Delta', 0, 10, N'{}', 3, 1),
(-9, 1, N'SIF - Load Dimensions & Facts', 0, 10, N'{}', 3, 1),
(-10, 1, N'SIF - Shutdown Idle Spark Sessions', 0, 10, N'{}', 3, 1)

SET IDENTITY_INSERT [dbo].[TaskGroup] OFF


/* TASK MASTER */
SET
    IDENTITY_INSERT [dbo].[TaskMaster] ON
    /* Load Codesets */
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2100,
        N'Load SIF Codesets',
        -5,
        -8,
        -4,
        -4,
        -10,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFLoadCodeSets","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"jsonSchemaCreate_AU.json","RelativePath":"/samples/sif/SifOpenApi/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"","RelativePath":"","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
    /* Load Raw Entities */
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2000,
        N'Load SIF Raw - CalendarDate',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif,EntityPrimaryKey=CalendarDateRefId","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"CalendarDate.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"CalendarDate.parquet","RelativePath":"/samples/sif/delta/CalendarDate/","SchemaFileName":"CalendarDate.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2001,
        N'Load SIF Raw - GradingAssignment',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"GradingAssignment.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"GradingAssignment.parquet","RelativePath":"/samples/sif/delta/GradingAssignment/","SchemaFileName":"GradingAssignment.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2002,
        N'Load SIF Raw - GradingAssignmentScore',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"GradingAssignmentScore.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"GradingAssignmentScore.parquet","RelativePath":"/samples/sif/delta/GradingAssignmentScore/","SchemaFileName":"GradingAssignmentScore.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2003,
        N'Load SIF Raw - LearningStandardItem',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"LearningStandardItem.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"LearningStandardItem.parquet","RelativePath":"/samples/sif/delta/LearningStandardItem/","SchemaFileName":"LearningStandardItem.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2004,
        N'Load SIF Raw - MarkValueInfo',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"MarkValueInfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"MarkValueInfo.parquet","RelativePath":"/samples/sif/delta/MarkValueInfo/","SchemaFileName":"MarkValueInfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2005,
        N'Load SIF Raw - SchoolInfo2',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"SchoolInfo2.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"SchoolInfo2.parquet","RelativePath":"/samples/sif/delta/SchoolInfo2/","SchemaFileName":"SchoolInfo2.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2006,
        N'Load SIF Raw - SectionInfo',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"SectionInfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"SectionInfo.parquet","RelativePath":"/samples/sif/delta/SectionInfo/","SchemaFileName":"SectionInfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2007,
        N'Load SIF Raw - StaffAssignment',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StaffAssignment.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StaffAssignment.parquet","RelativePath":"/samples/sif/delta/StaffAssignment/","SchemaFileName":"StaffAssignment.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2008,
        N'Load SIF Raw - StaffPersonal',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StaffPersonal.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StaffPersonal.parquet","RelativePath":"/samples/sif/delta/StaffPersonal/","SchemaFileName":"StaffPersonal.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2009,
        N'Load SIF Raw - StudentContactPersonal',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentContactPersonal.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentContactPersonal.parquet","RelativePath":"/samples/sif/delta/StudentContactPersonal/","SchemaFileName":"StudentContactPersonal.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2010,
        N'Load SIF Raw - StudentContactRelationship',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif,EntityPrimaryKey=StudentContactRelationshipRefId","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentContactRelationship.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentContactRelationship.parquet","RelativePath":"/samples/sif/delta/StudentContactRelationship/","SchemaFileName":"StudentContactRelationship.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2011,
        N'Load SIF Raw - StudentDailyAttendance',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentDailyAttendance.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentDailyAttendance.parquet","RelativePath":"/samples/sif/delta/StudentDailyAttendance/","SchemaFileName":"StudentDailyAttendance.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2012,
        N'Load SIF Raw - StudentGrade',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentGrade.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentGrade.parquet","RelativePath":"/samples/sif/delta/StudentGrade/","SchemaFileName":"StudentGrade.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2013,
        N'Load SIF Raw - StudentPersonal',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentPersonal.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentPersonal.parquet","RelativePath":"/samples/sif/delta/StudentPersonal/","SchemaFileName":"StudentPersonal.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2014,
        N'Load SIF Raw - StudentSchoolEnrollment',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentSchoolEnrollment.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentSchoolEnrollment.parquet","RelativePath":"/samples/sif/delta/StudentSchoolEnrollment/","SchemaFileName":"StudentSchoolEnrollment.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2015,
        N'Load SIF Raw - StudentScoreJudgementAgainstStandard',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentScoreJudgementAgainstStandard.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentScoreJudgementAgainstStandard.parquet","RelativePath":"/samples/sif/delta/StudentScoreJudgementAgainstStandard/","SchemaFileName":"StudentScoreJudgementAgainstStandard.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2016,
        N'Load SIF Raw - StudentSectionEnrollment',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"StudentSectionEnrollment.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"StudentSectionEnrollment.parquet","RelativePath":"/samples/sif/delta/StudentSectionEnrollment/","SchemaFileName":"StudentSectionEnrollment.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2017,
        N'Load SIF Raw - TeachingGroup',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"TeachingGroup.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"TeachingGroup.parquet","RelativePath":"/samples/sif/delta/TeachingGroup/","SchemaFileName":"TeachingGroup.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2018,
        N'Load SIF Raw - TermInfo',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"TermInfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"TermInfo.parquet","RelativePath":"/samples/sif/delta/TermInfo/","SchemaFileName":"TermInfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2019,
        N'Load SIF Raw - TermInfo2',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"TermInfo2.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"TermInfo2.parquet","RelativePath":"/samples/sif/delta/TermInfo2/","SchemaFileName":"TermInfo2.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2020,
        N'Load SIF Raw - TermInfo3',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"TermInfo3.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"TermInfo3.parquet","RelativePath":"/samples/sif/delta/TermInfo3/","SchemaFileName":"TermInfo3.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2021,
        N'Load SIF Raw - schoolinfo',
        -5,
        -8,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFParameterizedJson","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"schoolinfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"schoolinfo.parquet","RelativePath":"/samples/sif/delta/schoolinfo/","SchemaFileName":"schoolinfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )

/* Dimensions & Facts Codesets */
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2022,
        N'Load SIF Dimension - Student Personal',
        -5,
        -9,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFLoadDimStudentPersonal","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"schoolinfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"schoolinfo.parquet","RelativePath":"/samples/sif/delta/schoolinfo/","SchemaFileName":"schoolinfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )

	
INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2023,
        N'Load SIF Dimension - Staff Personal',
        -5,
        -9,
        -4,
        -4,
        -4,
        1,
        0,
        N'Azure',
        N'{"CustomDefinitions":"SparkDatabaseName=sif","ExecuteNotebook":"SIFLoadDimStaffPersonal","Purview":"Disabled","QualifiedIDAssociation":"TaskMasterId","Source":{"DataFileName":"schoolinfo.json","RelativePath":"/samples/sif/","SchemaFileName":"","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"Target":{"DataFileName":"schoolinfo.parquet","RelativePath":"/samples/sif/delta/schoolinfo/","SchemaFileName":"schoolinfo.json","Type":"Notebook-Optional","WriteSchemaToPurview":"Disabled"},"UseNotebookActivity":"Disabled"}',
        0,
        NULL,
        -2,
        0
    )

INSERT
    [dbo].[TaskMaster] (
        [TaskMasterId],
        [TaskMasterName],
        [TaskTypeId],
        [TaskGroupId],
        [ScheduleMasterId],
        [SourceSystemId],
        [TargetSystemId],
        [DegreeOfCopyParallelism],
        [AllowMultipleActiveInstances],
        [TaskDatafactoryIR],
        [TaskMasterJSON],
        [ActiveYN],
        [DependencyChainTag],
        [EngineId],
        [InsertIntoCurrentSchedule]
    )
VALUES
    (
        -2024,
        N'SIF - Stop Idle Spark Sessions',
        -10,
        -10,
        -4,
        -16,
        -10,
        1,
        0,
        N'Azure',
        N'{"Source": {"Type":"Not-Applicable"},"Target": {"Type":"Not-Applicable"}, "SparkPoolName": ""}',
        0,
        NULL,
        -2,
        0
    )


SET
    IDENTITY_INSERT [dbo].[TaskMaster] OFF
GO


/* Task Group Dependencies */
insert into [dbo].[TaskGroupDependency]  
(
	[AncestorTaskGroupid]                          ,
	[DescendantTaskGroupId]                        ,
	[DependencyType]                                   
)
Select a.* from 
(
	Select 
		-8 AncestorTaskGroupid,
		-9 DescendantTaskGroupId,
		'EntireGroup' DependencyType
    union 
    Select 
		-9 AncestorTaskGroupid,
		-10 DescendantTaskGroupId,
		'EntireGroup' DependencyType
) a
left outer join [dbo].[TaskGroupDependency]  b on a.AncestorTaskGroupid = b.AncestorTaskGroupid and a.DescendantTaskGroupId = b.DescendantTaskGroupId
where b.AncestorTaskGroupid is null