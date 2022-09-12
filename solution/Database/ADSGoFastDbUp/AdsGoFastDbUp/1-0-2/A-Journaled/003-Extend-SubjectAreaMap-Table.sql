-- DROP and recreate should be fine for these because they shouldn't have been used by any customers yet.

ALTER TABLE [dbo].[SubjectAreaRoleMap] SET ( SYSTEM_VERSIONING = OFF)
GO
DROP TABLE [dbo].[SubjectAreaRoleMap]
GO
DROP TABLE [dbo].[SubjectAreaRoleMapHistory]
GO

ALTER TABLE [dbo].[SubjectAreaSystemMap] SET ( SYSTEM_VERSIONING = OFF)
GO
DROP TABLE [dbo].[SubjectAreaSystemMap]
GO
DROP TABLE [dbo].[SubjectAreaSystemMapHistory]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EntityRoleMap](
	[EntityRoleMapId] [int] IDENTITY(1,1) NOT NULL,
	[EntityId] [int] NOT NULL,
	[EntityTypeName] [varchar](255) NOT NULL,
	[AadGroupUid] [uniqueidentifier] NOT NULL,
	[ApplicationRoleName] [varchar](255) NOT NULL,
	[ExpiryDate] [date] NOT NULL,
	[ActiveYN] [bit] NOT NULL,
	[UpdatedBy] [varchar](255) NULL
CONSTRAINT [EntityRoleMap_PK] PRIMARY KEY CLUSTERED
(
	[EntityRoleMapId] ASC
))
GO

ALTER TABLE EntityRoleMap
    ADD
        ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
            CONSTRAINT DF_EntityRoleMap_ValidFrom DEFAULT SYSUTCDATETIME()
      , ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
            CONSTRAINT DF_EntityRoleMap_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999')
      , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE EntityRoleMap
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = History.EntityRoleMap));
GO