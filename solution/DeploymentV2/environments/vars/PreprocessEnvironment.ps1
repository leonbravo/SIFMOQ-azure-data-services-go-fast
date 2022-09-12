<# 

This script processes common_vars_values.jsonc in the selected folder 

#>
param (
    [Parameter(Mandatory=$true)]
    [string]$Environment="staging",
    [Parameter(Mandatory=$true)]
    [string]$FeatureTemplate="basic_deployment",
    [Parameter(Mandatory=$false)]
    [bool]$gitDeploy=$false
)

$Environment = $Environment.ToLower()

#First Convert Terraform Commons to YAML
#Install-Module powershell-yaml -Force
$GithubEnvTemplate = ""
$GithubEnvTemplateSensitive = ""

#Preprocessing common_vars_template.jsonnet
#Feature Templates
$cvjns = Get-Content "./common_vars_template.jsonnet" -raw
$cvjnss = $cvjns.Split("/*DONOTREMOVETHISCOMMENT:SOFTS*/")
$fts = (Get-ChildItem -Path ./../featuretemplates | Select-Object -Property Name).Name.replace(".jsonc","")
$str = "/*DONOTREMOVETHISCOMMENT:SOFTS*/" + [System.Environment]::NewLine
foreach($ft in $fts)
{
    $str = $str + "     " + "'$ft' : import './../featuretemplates/$ft.jsonc'," + [System.Environment]::NewLine
}
$str = $str + "/*DONOTREMOVETHISCOMMENT:SOFTS*/"
($cvjnss[0] + $Str + $cvjnss[2]) | Set-Content "./common_vars_template.jsonnet"
#Environments
$cvjns = Get-Content "./common_vars_template.jsonnet" -raw
$cvjnss = $cvjns.Split("/*DONOTREMOVETHISCOMMENT:ENVS*/")
$fts = (Get-ChildItem -Directory | Select-Object -Property Name).Name
$str = "/*DONOTREMOVETHISCOMMENT:ENVS*/" + [System.Environment]::NewLine
foreach($ft in $fts)
{
    $str = $str + "     " + "'$ft' : import './$ft/common_vars_values.jsonc'," + [System.Environment]::NewLine
}
$str = $str + "/*DONOTREMOVETHISCOMMENT:ENVS*/"
($cvjnss[0] + $Str + $cvjnss[2]) | Set-Content "./common_vars_template.jsonnet"


Write-Debug "Preparing Environment: $Environment Using $FeatureTemplate Template"

#Prep Output Folder
$newfolder = "./../../bin/environments/$Environment/"
$hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Force -Name $newfolder) : ($F = "")

(jsonnet "./common_vars_template.jsonnet" --tla-str featuretemplatename=$FeatureTemplate --tla-str environment=$Environment --tla-str gitDeploy=$gitDeploy  ) | Set-Content($newfolder +"/common_vars.json")
$obj = Get-Content ($newfolder + "/common_vars.json") | ConvertFrom-Json


$envarprops = ($obj.ForEnvVar | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"})
foreach($t in $envarprops)
{
    $Name = $t.Name
    $Value = $obj.ForEnvVar[0].$Name    
    
    if($Value.GetType().Name -eq "Boolean")
    {
        $Value = $Value.ToString().ToLower()
    }  
    if($Value.GetType().Name -eq "PSCustomObject")
    {
        $Value = ($Value | ConvertTo-Json -Depth 10)
    }  
    #Write-Warning "Checking Value change $Value"
    if([string]::IsNullOrEmpty($Value) -eq $false -and $Value -ne '#####')
    {          
        [Environment]::SetEnvironmentVariable($Name, $Value)
    }      
}

#Feature Template Value Overrides
$fto_vals = ((Get-Content -Path  "./$Environment/common_vars_values.jsonc") | ConvertFrom-Json -Depth 10).FeatureTemplateOverrides
$fto_keys = $fto_vals | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}

foreach($fto in $fto_keys)
{
    $Name = $fto.Name
    if (($envarprops | Where-Object {$_.Name -eq "TF_VAR_$Name"}).Count -gt 0)
    {
        $ev_prop = ($envarprops | Where-Object {$_.Name -eq "TF_VAR_$Name"}).Name        
        $Value = $fto_vals.$Name
        Write-Debug "Overriding Feature Template value for $ev_prop with value of $Value"        
    }
    else {
        $ev_prop = "TF_VAR_$Name"
        Write-Debug "Inserting Feature Template value for $ev_prop with value of $Value" 
        $Value = $fto_vals.$Name
    }

    if($Value.GetType().Name -eq "Boolean")
    {
        #Write-Warning $Value.GetType().Name
        $Value = $Value.ToString().ToLower()
    }  
    if($Value.GetType().Name -eq "PSCustomObject")
    {   
        #Write-Warning $Value.GetType().Name
        $Value = ($Value | ConvertTo-Json -Depth 10)
    }  

    if([string]::IsNullOrEmpty($Value) -eq $false -and $Value -ne '#####')
    {       
        #Write-Warning "Injecting Envar 'TF_VAR_$Name': $Value"   
        [Environment]::SetEnvironmentVariable("TF_VAR_$Name", $Value) 
    }
    else 
    {
        #Write-Warning "Value Supressed"
    }
}


foreach($t in ($obj.ForSecretFile | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}))
{
    $Name = $t.Name
    $Value = $obj.ForSecretFile[0].$Name
    #Add to GitHubSecretFile    
    $GithubEnvTemplate = $GithubEnvTemplate + "$Name=$Value" + [System.Environment]::NewLine
}

foreach($t in ($obj.ForSecretFileSensitive | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}))
{
    $Name = $t.Name
    $Value = $obj.ForSecretFile[0].$Name
    #Add to GitHubSecretFile    
    $GithubEnvTemplateSensitive = $GithubEnvTemplateSensitive + "$Name=$Value" + [System.Environment]::NewLine
}


#Write the Terraform Element common_vars_for_hcl.json - this is then injected into the hcl file
($obj.ForHCL | ConvertTo-Json -Depth 10) | Set-Content ($newfolder+"/common_vars_for_hcl.json")

if($gitDeploy -eq $false)
{
    #Write the Git Secrets to the Git Template .env
    ($GithubEnvTemplateSensitive + [System.Environment]::NewLine + $GithubEnvTemplate)|Set-Content ($newfolder+"/GetSecretsTemplate.env")
}