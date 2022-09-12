/****** Object:  StoredProcedure [dbo].[GetFrameworkTaskRunners]    Script Date: 3/03/2022 1:10:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-----------------------------------------------------------------------

 Copyright (c) Microsoft Corporation.
 Licensed under the MIT license.

-----------------------------------------------------------------------*/
Alter procedure [dbo].[GetFrameworkTaskRunners] as 

declare @Output as Table (TaskRunnerId int)

Update FrameworkTaskRunner
Set Status = 'Running', LastExecutionStartDateTime = GETUTCDATE()
OUTPUT inserted.TaskRunnerId into @Output (TaskRunnerId)
where ActiveYN = 1 and Status = 'Idle'

Select FTR.*,case when O.TaskRunnerId is null then 'N' else 'Y' end as RunNow from FrameworkTaskRunner FTR left outer join @Output O on O.TaskRunnerId = FTR.TaskRunnerId
GO
/****** Object:  StoredProcedure [dbo].[GetTaskGroups]    Script Date: 3/03/2022 1:10:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO