
Import-Module ./GatherOutputsFromTerraform_DataFactoryFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_DataFactoryFolder

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

            $dir = $_directory + "/" +  $_subFolder + "/" + $name + ".json"
            $dir = $dir.Split("/").where{$_} -join "/"

            #ParseOut the Name Attribute
            #Persist File Back
            $jsonobject | ConvertTo-Json  -Depth 100 | set-content $_

            #Make a copy of the file in the repo 
            Copy-Item -Path $fileName -Destination "$($dir)" -Force
            Write-Verbose ($name) #-ForegroundColor Yellow -BackgroundColor DarkGreen
                        
            
        }
    }
}


#Set up Temp Repo space
New-Item -Path "$($baseDirectory)" -Name "$($folderName)" -ItemType "directory"

$owner = $tout.adf_git_repository_owner
$GitURL = "$($tout.adf_git_host_url)/$($owner)/$($tout.adf_git_repository_name)"



Write-Verbose $GitURL
Write-Verbose "$($Directory)/$($tout.adf_git_repository_name)"
Write-Verbose "$($tout.adf_git_repository_branch_name)"

#Clone Repo
$FolderPath = "$($Directory)/$($tout.adf_git_repository_name)"
$FolderPath = RemoveRepetitiveChars -string $FolderPath -char "/"
if ($tout.adf_git_use_pat) {
    $B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($tout.adf_git_pat)"))
    git -c http.extraHeader="Authorization: Basic $B64Pat" clone -b "$($tout.adf_git_repository_branch_name)" "$($GitURL)" "$($FolderPath)"
} else {
    git clone -b "$($tout.adf_git_repository_branch_name)" "$($GitURL)" "$($FolderPath)" 
}
$FolderPath = "$($FolderPath)/$($tout.adf_git_repository_root_folder)/"
$FolderPath = RemoveRepetitiveChars -string $FolderPath -char "/"

#Check for Folders / Creating Folders
$repoDirectories = @(
    "", 
    "/pipeline", 
    "/linkedService", 
    "/integrationRuntime", 
    "/managedVirtualNetwork",
    "/managedVirtualNetwork/default", 
    "/managedVirtualNetwork/default/managedPrivateEndpoint", 
    "/factory",
    "/dataset")
    
foreach($repoDirectory in $repoDirectories)
{
    $fullDir = "$($FolderPath)$($repoDirectory)"
    if (Test-Path -Path $fullDir) {
        "$($fullDir) directory exists, skipping."
    } else {
        Write-Verbose "Creating $($fullDir) directory in repo"
        New-Item -Path $($fullDir) -ItemType "directory"
    }
}




#Move Items into rep
#NOTE: USE '_' to represent '/' in directories (this will be needed for virtual network)
$children = [ordered]@{
    pipeline = @("SPL_*.json", "GPL0_*.json","GPL1_*.json", "GPL2_*.json", "GPL-1_*.json", "GPL_*.json"); 
    linkedService = @("LS_*.json");
    integrationRuntime = @("IR_*.json");
    dataset = @("GDS_*.json");
    factory = @("FA_*.json");
    managedVirtualNetwork = @("MVN_*.json");
    managedVirtualNetwork_default_managedPrivateEndpoint = @("MVN_default-managedPrivateEndpoint_*.json");
}
#Name = Directory in repo, Value = files to be placed in that directory
foreach($child in $children.GetEnumerator()) {
    $subFolder = $child.Name + "/"
    $subFolder = $subFolder -replace "_", "/"
    $inclusions = $child.Value
    $items = (Get-ChildItem -Path "./output/" -Include ($inclusions) -Verbose -recurse)
    Write-Verbose "Copying output $($child.Name) items to $($FolderPath)/$($subFolder)"
    UploadADFItem -items $items -directory $FolderPath -subFolder $subFolder
}

#Commit and remove

Set-Location "$($Directory)/$($tout.adf_git_repository_name)"

#Set user ID / Email

if ($tout.adf_git_user_name -ne "") {
    git config user.name "$($tout.adf_git_user_name)"
}
if ($tout.adf_git_email_address -ne "") {
    git config user.name "$($tout.adf_git_email_address)"
}

git add .
Write-Verbose ("Committing to " + $tout.adf_git_repository_name + "/" + $tout.adf_git_repository_branch_name)
git commit -m "Deployment commit" --quiet
if ($tout.adf_git_use_pat) {
    $B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($tout.adf_git_pat)"))
    git -c http.extraHeader="Authorization: Basic $B64Pat" push origin $($tout.adf_git_repository_branch_name)
} else {
    git push origin $($tout.adf_git_repository_branch_name)  
}
Set-Location $CurrentFolderPath
Write-Verbose "Deleting Temporary Repo"
Remove-Item $Directory -Recurse -Force
Write-Verbose "Complete!"
