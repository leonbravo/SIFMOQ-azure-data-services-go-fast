param (
    [Parameter(Mandatory=$true)]
    [string]$user=$false,
    [Parameter(Mandatory=$true)]
    [string]$sqlserver_name=$false,
    [Parameter(Mandatory=$true)]
    [string]$database=$false
)

$token=$(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)

$sqlcommand = "

IF NOT EXISTS (SELECT *
FROM [sys].[database_principals]
WHERE [type] = N'E' AND [name] = N'$user') 
BEGIN
    CREATE USER [$user] FROM EXTERNAL PROVIDER;		
END
ALTER ROLE db_datareader ADD MEMBER [$user];
ALTER ROLE db_datawriter ADD MEMBER [$user];
GRANT EXECUTE ON SCHEMA::[dbo] TO [$user];
GO
        
"

write-host "Granting MSI Privileges on $database DB to $user"
Invoke-Sqlcmd -ServerInstance "$sqlserver_name.database.windows.net,1433" -Database $database -AccessToken $token -query $sqlcommand    