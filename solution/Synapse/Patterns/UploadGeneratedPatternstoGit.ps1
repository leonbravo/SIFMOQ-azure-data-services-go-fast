Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder

function RemoveRepetitiveChars ($string, $char) {
    $string = $string.Split($char).where{$_} -join $char
    return $string
}


$CurrentFolderPath = $PWD
$baseDirectory = "../../../.." 
$folderName = "TempRepo"
$Directory = "$($baseDirectory)/$($folderName)"
$Directory = RemoveRepetitiveChars -string $Directory -char "/"

if($tout.datafactory_name -eq "") {
    $tout.datafactory_name = Read-Host "Enter the name of the data factory"
}
if($tout.resource_group_name -eq "") {
    $tout.resource_group_name = Read-Host "Enter the name of the resource group"
}
if($tout.resource_group_id -eq "") {
    $tout.resource_group_id = Read-Host "Enter the id of the resource group"
}
if($tout.keyvault_name -eq "") {
    $tout.keyvault_name = Read-Host "Enter the name of the key vault"
}
if($tout.functionapp_name -eq "") {
    $tout.functionapp_name = Read-Host "Enter the name of the function app"
}


function UploadADFItem ($items, $directory, $subFolder) {
    
    if ($items.count -gt 0) {
        $items | Foreach-Object -Parallel {
            $_tout = $using:tout
            $_directory = $using:directory
            $_subFolder = $using:subFolder
            $guid = [guid]::NewGuid()
            $lsName = $_.BaseName 
            $fileName = $_.FullName
            $jsonobject = $_ | Get-Content | ConvertFrom-Json
            $name = $jsonobject.name

            <#$dir = "$($_directory)/$($_tout.synapse_git_repository_name)"
            if ($($_tout.synapse_git_repository_root_folder) -ne "") {
                $dir = $dir + "$($_tout.synapse_git_repository_root_folder)/"
            }#>
            $dir = $_directory + "/" +  $_subFolder + "/" + $name + ".json"
            $dir = $dir.Split("/").where{$_} -join "/"

            #ParseOut the Name Attribute
            #Persist File Back
            $jsonobject | ConvertTo-Json  -Depth 100 | set-content $_

            #Make a copy of the file in the repo 
            Copy-Item -Path $fileName -Destination "$($dir)" -Force
            Write-Information ($name) #-ForegroundColor Yellow -BackgroundColor DarkGreen
                        
            
        }
    }
}


#Set up Temp Repo space
New-Item -Path "$($baseDirectory)" -Name "$($folderName)" -ItemType "directory"
if($tout.synapse_git_integration_type -eq "devops") 
{
    #https://dev.azure.com/microsoft/_git/lockBoxProject
    #https://microsoft@dev.azure.com/microsoft/lockBoxProject/_git/lockBoxProject
    #https://dev.azure.com/hugosharpe/_git/lockBoxProject
    #NOTE -> This may need to be changed to include tenant + owner (with if conditional)
    #$owner = $tout.synapse_git_repository_base_url | Select-String -Pattern "dev.azure.com/(.*?)/"
    #$owner = $owner.Matches.Groups[1].Value
    $owner = $tout.synapse_git_repository_owner
    $GitURL = "dev.azure.com/$($owner)/$($tout.synapse_git_devops_project_name)/_git/$($tout.synapse_git_repository_name)"
    $GitURL = RemoveRepetitiveChars -string $GitURL -char "/"
    $GitURL = "https://" + $GitURL
}
else 
{
    #https://github.com/microsoft/azure-data-services-go-fast-codebase
    #$owner = $tout.synapse_git_repository_base_url | Select-String -Pattern "github.com/(.*?)/"
    #$owner = $owner.Matches.Groups[1].Value
    $owner = $tout.synapse_git_repository_owner
    $GitURL = "$($tout.synapse_git_github_host_url)/$($owner)/$($tout.synapse_git_repository_name)"



}



Write-Information $GitURL
Write-Information "$($Directory)/$($tout.synapse_git_repository_name)"
Write-Information "$($tout.synapse_git_repository_branch_name)"

#Clone Repo
$FolderPath = "$($Directory)/$($tout.synapse_git_repository_name)"
$FolderPath = RemoveRepetitiveChars -string $FolderPath -char "/"
if ($tout.synapse_git_use_pat) {
    $B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($tout.synapse_git_pat)"))
    git -c http.extraHeader="Authorization: Basic $B64Pat" clone -b "$($tout.synapse_git_repository_branch_name)" "$($GitURL)" "$($FolderPath)"
} else {
    git clone -b "$($tout.synapse_git_repository_branch_name)" "$($GitURL)" "$($FolderPath)" 
}
$FolderPath = "$($FolderPath)/$($tout.synapse_git_repository_root_folder)/"
$FolderPath = RemoveRepetitiveChars -string $FolderPath -char "/"

#Check for Folders / Creating Folders
$repoDirectories = @(
    "", 
    "/pipeline",
    "/notebook", 
    "/linkedService", 
    "/integrationRuntime", 
    "/managedVirtualNetwork",
    "/managedVirtualNetwork/default", 
    "/managedVirtualNetwork/default/managedPrivateEndpoint", 
    "/credential")
<#unused:
    /dataset
    /sqlscript
    /trigger
    
#>
foreach($repoDirectory in $repoDirectories)
{
    $fullDir = "$($FolderPath)$($repoDirectory)"
    if (Test-Path -Path $fullDir) {
        "$($fullDir) directory exists, skipping."
    } else {
        Write-Information "Creating $($fullDir) directory in repo"
        New-Item -Path $($fullDir) -ItemType "directory"
    }
}




#Move Items into rep
#NOTE: USE '_' to represent '/' in directories (this will be needed for virtual network)
$children = [ordered]@{
    pipeline = @("SPL_*.json", "GPL0_*.json","GPL1_*.json", "GPL2_*.json", "GPL-1_*.json", "GPL_*.json"); 
    notebook = @("NB_*.json");
    linkedService = @("LS_*.json");
    integrationRuntime = @("IR_*.json");
    credential = @("CR_*.json");
    managedVirtualNetwork = @("MVN_*.json");
    managedVirtualNetwork_default_managedPrivateEndpoint = @("MVN_default-managedPrivateEndpoint_*.json");
}
#Name = Directory in repo, Value = files to be placed in that directory

foreach($child in $children.GetEnumerator()) {
    $subFolder = $child.Name + "/"
    $subFolder = $subFolder -replace "_", "/"
    $inclusions = $child.Value
    $items = (Get-ChildItem -Path "./output/" -Include ($inclusions) -Verbose -recurse)
    Write-Information "Copying output $($child.Name) items to $($FolderPath)/$($subFolder)"
    UploadADFItem -items $items -directory $FolderPath -subFolder $subFolder
}

#Commit and remove
Set-Location "$($Directory)/$($tout.synapse_git_repository_name)"

#Set user ID / Email

if ($tout.synapse_git_user_name -ne "") {
    git config user.name "$($tout.synapse_git_user_name)"
}
if ($tout.synapse_git_email_address -ne "") {
    git config user.name "$($tout.synapse_git_email_address)"
}

git add .
Write-Information ("Committing to " + $tout.synapse_git_repository_name + "/" + $tout.synapse_git_repository_branch_name)
git commit -m "Deployment commit" --quiet
if ($tout.synapse_git_use_pat) {
    $B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($tout.synapse_git_pat)"))
    git -c http.extraHeader="Authorization: Basic $B64Pat" push origin $($tout.synapse_git_repository_branch_name)
} else {
    git push origin $($tout.synapse_git_repository_branch_name)
}
Set-Location $CurrentFolderPath
Write-Information "Deleting Temporary Repo"
Remove-Item $Directory -Recurse -Force
Write-Information "Complete!"
