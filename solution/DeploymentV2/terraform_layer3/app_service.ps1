#----------------------------------------------------------------------------------------------------------------
#   Web App Admin User
#----------------------------------------------------------------------------------------------------------------
param (
    [Parameter(Mandatory=$true)]
    [string]$aad_webreg_id=""
)
#----------------------------------------------------------------------------------------------------------------

write-host "Adding Admin Role To WebApp for specific user"
$authapp = (az ad app show --id $aad_webreg_id) | ConvertFrom-Json
$authappid = $authapp.appId
$authappobjectid = (az ad sp show --id $authapp.appId | ConvertFrom-Json).id
$body = '{"principalId": "@principalid","resourceId":"@resourceId","appRoleId": "@appRoleId"}' | ConvertFrom-Json
$body.resourceId = $authappobjectid
$body.appRoleId = ($authapp.appRoles | Where-Object {$_.value -eq "Administrator" }).id
$body.principalId = [System.Environment]::GetEnvironmentVariable('WEB_APP_ADMIN_USER')
$body = ($body | ConvertTo-Json -compress | Out-String).Replace('"','\"')

$result = az rest --method post --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$authappobjectid/appRoleAssignedTo" --headers '{\"Content-Type\":\"application/json\"}' --body $body


