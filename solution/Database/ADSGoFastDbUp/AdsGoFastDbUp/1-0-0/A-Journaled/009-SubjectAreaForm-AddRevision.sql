GO
PRINT N'Dropping system-versioning from [dbo].[SubjectAreaForm]...';


GO
IF EXISTS (SELECT TOP 1 1 
           FROM   [sys].[tables]
           WHERE  [name] = N'SubjectAreaForm'
                  AND SCHEMA_NAME(schema_id) = N'dbo'
                  AND temporal_type = 2)
    BEGIN
        ALTER TABLE [dbo].[SubjectAreaForm] SET (SYSTEM_VERSIONING = OFF);
    END


GO
PRINT N'Altering [dbo].[SubjectAreaFormHistory]...';


GO
ALTER TABLE [dbo].[SubjectAreaFormHistory]
    ADD [Revision] TINYINT NOT NULL;


GO
PRINT N'Altering [dbo].[SubjectAreaForm]...';


GO
ALTER TABLE [dbo].[SubjectAreaForm]
    ADD [Revision] TINYINT NOT NULL;


GO
PRINT N'Adding system-versioning to [dbo].[SubjectAreaForm]...';


GO
ALTER TABLE [dbo].[SubjectAreaForm] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[SubjectAreaFormHistory], DATA_CONSISTENCY_CHECK=ON));


GO
PRINT N'Update complete.';



PRINT N'Disable system-versioning to [dbo].[SubjectArea]...';
IF EXISTS (SELECT TOP 1 1 
           FROM   [sys].[tables]
           WHERE  [name] = N'SubjectArea'
                  AND SCHEMA_NAME(schema_id) = N'dbo'
                  AND temporal_type = 2)
    BEGIN
        ALTER TABLE [dbo].[SubjectArea] SET (SYSTEM_VERSIONING = OFF);
    END
GO

PRINT N'Adding [dbo].[SubjectAreaHistory].[ShortCode]';
ALTER TABLE [dbo].[SubjectAreaHistory]  
    ADD [ShortCode]  VARCHAR (10) NULL;
GO
UPDATE [dbo].[SubjectAreaHistory] set [ShortCode] = SubjectAreaId
    where [ShortCode] is null;
GO
ALTER TABLE [dbo].[SubjectAreaHistory]  
    ALTER COLUMN [ShortCode]  VARCHAR (10) NOT NULL;
GO

PRINT N'Adding [dbo].[SubjectArea].[ShortCode]';
ALTER TABLE [dbo].[SubjectArea]  
    ADD [ShortCode]  VARCHAR (10) NULL;
GO
UPDATE [dbo].[SubjectArea] set [ShortCode] = SubjectAreaId
    where [ShortCode] is null;
GO
ALTER TABLE [dbo].[SubjectArea]  
    ALTER COLUMN [ShortCode]  VARCHAR (10) NOT NULL;
GO

PRINT N'Adding system-versioning to [dbo].[SubjectArea]...';
GO
ALTER TABLE [dbo].[SubjectArea] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[SubjectAreaHistory], DATA_CONSISTENCY_CHECK=ON));

ALTER TABLE [dbo].[SubjectArea]  
ADD CONSTRAINT UQ_ShortCode UNIQUE([ShortCode]);   

GO
PRINT N'Update complete.';