/****** Object:  Table [dbo].[IntegrationRuntimeMapping]    Script Date: 26/04/2022 9:35:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IntegrationRuntimeMapping](
	[IntegrationRuntimeMappingId] [int] IDENTITY(1,1) NOT NULL,
	[IntegrationRuntimeId] [int] NOT NULL,
	[IntegrationRuntimeName] [varchar](255) NULL,
	[SystemId] [bigint] NOT NULL,
	[ActiveYN] [bit] NULL
PRIMARY KEY CLUSTERED 
(
	[IntegrationRuntimeMappingId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/* TEMP INSERTS UNTIL IMPROVEMENTS IMPLEMENETED */


SET IDENTITY_INSERT [dbo].[IntegrationRuntimeMapping] ON 
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (1, 1, 'Azure', -1, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (2, 1, 'Azure', -2, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (3, 1, 'Azure', -3, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (4, 1, 'Azure', -4, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (5, 1, 'Azure', -7, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (6, 1, 'Azure', -8, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (7, 1, 'Azure', -9, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (8, 1, 'Azure', -10, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (9, 1, 'Azure', -16, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (10, 2, 'OnPrem', -14, 1)
GO
INSERT [dbo].[IntegrationRuntimeMapping] ([IntegrationRuntimeMappingId], [IntegrationRuntimeId], [IntegrationRuntimeName], [SystemId], [ActiveYN]) VALUES (11, 2, 'OnPrem', -15, 1)
GO
SET IDENTITY_INSERT [dbo].[IntegrationRuntimeMapping] OFF
GO

