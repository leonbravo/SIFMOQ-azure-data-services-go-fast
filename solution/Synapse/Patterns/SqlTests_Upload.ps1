
Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder

$sqlserver_name=$tout.sqlserver_name
$stagingdb_name=$tout.stagingdb_name
$metadatadb_name=$tout.metadatadb_name


$SqlInstalled = Get-InstalledModule SqlServer
if($null -eq $SqlInstalled)
{
    Write-Information "Installing SqlServer Module"
    Install-Module -Name SqlServer -Scope CurrentUser -Force
}

$sqlcommand = (Get-Content ./SqlTests.sql -raw)
$token=$(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)
Invoke-Sqlcmd -ServerInstance "$sqlserver_name.database.windows.net,1433" -Database $metadatadb_name -AccessToken $token -query $sqlcommand   

#Insert Dependency Relationships"
$sqlcommand = @"
insert into [dbo].[TaskMasterWaterMark]
Select a.TaskMasterId, 'lsn', 'lsn', null, null, '', null, 1, getdate() 
from [dbo].[TaskMaster] a left outer join [dbo].[TaskMasterWaterMark] b on a.TaskMasterID=  b.TaskMasterId
where a.[TaskTypeId] = -4 and b.TaskMasterId is null
"@
#Invoke-Sqlcmd -ServerInstance "$sqlserver_name.database.windows.net,1433" -Database $metadatadb_name -AccessToken $token -query $sqlcommand   