Import-Module ./GatherOutputsFromTerraform_SynapseFolder.psm1 -Force
$tout = GatherOutputsFromTerraform_SynapseFolder
$newfolder = "./output/"


#Generate Patterns.json
(jsonnet "./patterns.jsonnet") | Set-Content("./Patterns.json")

$GenerateArm="false"

if (!(Test-Path "./output"))
{
    $fld = New-Item -itemType Directory -Name "output"
}
else
{
    Write-Verbose "Output Folder already exists"
}

#Remove Previous Outputs
$hiddenoutput = Get-ChildItem ./output | foreach {
    Remove-item $_ -force
}
#create tout json to be used for git integration
$toutjson = $tout | ConvertTo-Json -Depth 10 | Set-Content($newfolder + "tout.json")
#Copy Static Pipelines
$folder = "./pipeline/static"
$templates = (Get-ChildItem -Path $folder -Filter "*.json"  -Verbose)
foreach ($file in $templates)
{ 
    $content = Get-Content $file
    $outfile = ('./output/' + $File.Name)
    $content | Set-Content -Path $outfile 
}


#Copy IR Specific Pipelines
$patterns = (Get-Content "Patterns.json") | ConvertFrom-Json -Depth 10
foreach ($ir in $tout.integration_runtimes)
{    

    $GFPIR = $ir
    if (($tout.synapse_spark_pool_name -eq ""))
    {
        Write-Verbose "Skipping Synapse pipeline generation as there is no Synapse Spark Pool"
    }
    else
    {        
        foreach ($pattern in $patterns)
        {    
            $folder = "./pipeline/" + $pattern.Folder
            $templates = (Get-ChildItem -Path $folder -Filter "*.libsonnet"  -Verbose)

            Write-Verbose "_____________________________"
            Write-Verbose $folder 
            Write-Verbose "_____________________________"

            foreach ($t in $templates) {        
                $GFPIR = $pattern.GFPIR
                $SourceType = $pattern.SourceType
                $SourceFormat = $pattern.SourceFormat
                $TargetType = $pattern.TargetType
                $TargetFormat = $pattern.TargetFormat
                $SparkPoolName = $tout.synapse_spark_pool_name

                $newname = ($t.PSChildName).Replace(".libsonnet",".json")        
                Write-Verbose $newname        
                (jsonnet --tla-str GenerateArm=$GenerateArm  --tla-str SparkPoolName="$SparkPoolName"  --tla-str GFPIR="$GFPIR" $t.FullName) | Set-Content('./output/' + $newname)

            }

        }
    }
}

#foreach unique folder used by pattern.json
$patternFolders = $patterns.Folder | Get-Unique 
$schemafiles = @()
foreach ($patternFolder in $patternFolders)
 {  
    #clear previous runs
    if (Test-Path ("./pipeline/" + $patternFolder + "/output/schemas/taskmasterjson/"))
    {
        $hiddenoutput = Get-ChildItem ("./pipeline/" + $patternFolder + "/output/schemas/taskmasterjson/") | Remove-item -Recurse
    }
    
    $patternsInFolder = ($patterns | where-object {$_.Folder -eq $patternFolder})
    #get all patterns for that folder and generate the schema files
    $patternsInFolder | ForEach-Object {
        $guid = [guid]::NewGuid() 
        $item = $_
        $schemafile = [PSCustomObject]@{
            Guid = $guid            
            SourceType = $item.SourceType
            SourceFormat = $item.SourceFormat
            TargetType = $item.TargetType
            TargetFormat = $item.TargetFormat
            TaskTypeId = $item.TaskTypeId
            SourceFolder = "./pipeline/" + $item.Folder
            TargetFolder = ""
            Pipeline = $item.pipeline
        }               
        $schemafiles += $schemafile
        Write-Verbose "_____________________________"
        Write-Verbose "Generating ADF Schema Files: " 
        Write-Verbose ($schemafile.SourceFolder)
        Write-Verbose "_____________________________"
        
        $newfolder = ($schemafile.SourceFolder + "/output")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Name $newfolder -Force) : ($F = "")
        $newfolder = ($newfolder + "/schemas")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Name $newfolder -Force) : ($F = "")
        $newfolder = ($newfolder + "/taskmasterjson/")
        $hiddenoutput = !(Test-Path $newfolder) ? ($F = New-Item -itemType Directory -Name $newfolder -Force) : ($F = "")
        
        $schemafile.TargetFolder = $newfolder
        $schemafiletemplate = (Get-ChildItem -Path ($schemafile.SourceFolder+"/jsonschema/") -Filter "Main.libsonnet")

        $newname = ($schemafiletemplate.PSChildName).Replace(".libsonnet",".json").Replace("Main", $guid);

        $SourceType = $schemafile.SourceType
        $SourceFormat = $schemafile.SourceFormat
        $TargetType = $schemafile.TargetType
        $TargetFormat = $schemafile.TargetFormat

        (jsonnet --tla-str SourceType="$SourceType" --tla-str SourceFormat="$SourceFormat" --tla-str TargetType="$TargetType" --tla-str TargetFormat="$TargetFormat" $schemafiletemplate) | Set-Content($newfolder + $newname)
        
        
    }    
    
    $sql = @"
    BEGIN 
    Select * into #TempTTM from ( VALUES
"@
    $folder = "./pipeline/" + $patternFolder    
    foreach ($pattern in  $patternsInFolder)
    {  
        $pipeline = $pattern.Pipeline                
                
        #Write-Verbose "_____________________________"
        #Write-Verbose "Inserting into TempTTM: " 
        #Write-Verbose $pipeline
        #Write-Verbose "_____________________________"        
        $psplit = $pipeline.split("_")
        $SourceType = $pattern.SourceType
        $SourceFormat = $pattern.SourceFormat
        $TargetType = $pattern.TargetType
        $TargetFormat = $pattern.TargetFormat
        $TaskTypeId = $pattern.TaskTypeId

        $schemafileguid = ($schemafiles | where-object {$_.SourceFormat -eq $SourceFormat -and $_.SourceType -eq $SourceType -and $_.TargetFormat -eq $TargetFormat -and $_.TargetType -eq $TargetType -and $_.Pipeline -eq $pipeline}).Guid
        $tschemafile = $folder + "/output/schemas/taskmasterjson/"+ $schemafileguid + ".json"

        #$SourceType = $psplit[1]
        $SourceType = ($SourceType -eq "AzureBlobStorage") ? "Azure Blob":$SourceType
        $SourceType = ($SourceType -eq "AzureBlobFS") ? "ADLS" : $SourceType
        $SourceType = ($SourceType -eq "AzureSqlTable") ? "Azure SQL" : $SourceType
        $SourceType = ($SourceType -eq "AzureSqlDWTable") ? "Azure Synapse" : $SourceType
        $SourceType = ($SourceType -eq "SqlServerTable") ? "SQL Server" : $SourceType

        #$SourceFormat = $psplit[2]
        $SourceFormat = ($SourceFormat -eq "DelimitedText") ? "Csv":$SourceFormat

        #$TargetType = $psplit[3]
        $TargetType = ($TargetType -eq "AzureBlobStorage") ? "Azure Blob":$TargetType
        $TargetType = ($TargetType -eq "AzureBlobFS") ? "ADLS" : $TargetType
        $TargetType = ($TargetType -eq "AzureSqlTable") ? "Azure SQL" : $TargetType
        $TargetType = ($TargetType -eq "AzureSqlDWTable") ? "Azure Synapse" : $TargetType
        $TargetType = ($TargetType -eq "SqlServerTable") ? "SQL Server" : $TargetType

        #$TargetFormat = $psplit[4]        
        $TargetFormat = ($TargetFormat -eq "DelimitedText") ? "Csv":$TargetFormat

        if ($TaskTypeId -eq -1)
        {
        $TargetFormat = "Table"
        }

        if ($TaskTypeId -eq -6 -or $TaskTypeId -eq -10) 
        {
            $MappingType = 'DLL'
        }
        else 
        {
            $MappingType = 'ADF'
        }

        $content = Get-Content $tschemafile -raw
        $sql += "("
        $sql += "$TaskTypeId, N'$MappingType', N'$pipeline', N'$SourceType', N'$SourceFormat', N'$TargetType', N'$TargetFormat', NULL, 1,N'$content',N'{}'"
        $sql += "),"
    }
    if ($sql.endswith(","))
    {   $sql = $sql.Substring(0,$sql.Length-1) }
    $sql += @"
    ) a([TaskTypeId], [MappingType], [MappingName], [SourceSystemType], [SourceType], [TargetSystemType], [TargetType], [TaskTypeJson], [ActiveYN], [TaskMasterJsonSchema], [TaskInstanceJsonSchema])
    
    
    Update [dbo].[TaskTypeMapping]
    Set 
    MappingName = ttm2.MappingName,
    TaskMasterJsonSchema = ttm2.TaskMasterJsonSchema,
    TaskInstanceJsonSchema = ttm2.TaskInstanceJsonSchema
    from 
    [dbo].[TaskTypeMapping] ttm  
    inner join #TempTTM ttm2 on 
        ttm2.TaskTypeId = ttm.TaskTypeId 
        and ttm2.MappingType = ttm.MappingType
        and ttm2.SourceSystemType = ttm.SourceSystemType 
        and ttm2.SourceType = ttm.SourceType 
        and ttm2.TargetSystemType = ttm.TargetSystemType 
        and ttm2.TargetType = ttm.TargetType 

    Insert into 
    [dbo].[TaskTypeMapping]
    ([TaskTypeId], [MappingType], [MappingName], [SourceSystemType], [SourceType], [TargetSystemType], [TargetType], [TaskTypeJson], [ActiveYN], [TaskMasterJsonSchema], [TaskInstanceJsonSchema])
    Select ttm2.* 
    from [dbo].[TaskTypeMapping] ttm  
    right join #TempTTM ttm2 on 
        ttm2.TaskTypeId = ttm.TaskTypeId 
        and ttm2.MappingType = ttm.MappingType
        and ttm2.SourceSystemType = ttm.SourceSystemType 
        and ttm2.SourceType = ttm.SourceType 
        and ttm2.TargetSystemType = ttm.TargetSystemType 
        and ttm2.TargetType = ttm.TargetType 
    where ttm.TaskTypeMappingId is null

    END 
"@

        $sql | Set-Content ($folder + "/output/schemas/taskmasterjson/TaskTypeMapping.sql")    
}

# This will copy the output pipeline files into the locations required for the terraform deployment
if($GenerateArm -eq "true") {
    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "GPL*.json", "GPL_Sql*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_selfhosted/arm/"  
    }
        
    Write-Verbose "Copied $($templates.Count) to Self Hosted Pipelines Module in Terraform folder"

    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "GPL*.json", "GPL_Az*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_azure/arm/"  
    }
    Write-Verbose "Copied $($templates.Count) to Azure Hosted Pipelines Module in Terraform folder"

    $templates = Get-ChildItem -Path './output/*' -Exclude '*_Azure.json', '*_Azure.json' -Include "SPL_Az*.json" -Name
    foreach($template in $templates) {
        Copy-Item -Path "./output/$template" -Destination "../../DeploymentV2\terraform\modules\data_factory_pipelines_azure/arm/"  
    }
    Write-Verbose "Copied $($templates.Count) to Static Hosted Pipelines Module in Terraform folder"
}


if($($tout.synapse_git_toggle_integration)) {
    $newfolder = "./output/"
    #LINKED SERVICES
    $folder = "./linkedService/"
    $templates = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse linked services for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $templates){
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "LS_" + $newName
        $newName = $newName.Replace("(workspaceName)", $($tout.synapse_workspace_name))
        (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }
    #NOTEBOOKS
    $folder = "./notebook/"
    $notebooks = (Get-ChildItem -Path $folder -Filter "*.ipynb" -Verbose)
    $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "*.libsonnet"  -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse notebooks for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $notebooks){
        $jsonobject = $file | Get-Content 
        $newName = ($file.PSChildName).Replace(".ipynb",".json")
        $newName = "NB_" + $newName
        $jsonobject | Set-Content($newfolder + "cells.json") -Force
        $jsonobject = (Get-ChildItem -Path ($newfolder) -Filter "cells.json" -Verbose)
        $jsonobject = $jsonobject | Get-Content | ConvertFrom-Json -Depth 50
        $cells = $jsonobject.cells
        #Write-Verbose $cells
        $notebookName = $file.BaseName
        (jsonnet --tla-str notebookName="$notebookName" $schemafiletemplate | Set-Content($newfolder + $newName) -Force)

    }
    #delete cells temp file
    Remove-Item "$($newfolder)/cells.json"

    #INTEGRATED RUNTIMES

    $folder = "./integrationRuntime/"
    $IRS = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse integration runtimes for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $IRS)
    {
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "IR_" + $newName
        (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))

    }

    #CREDENTIAL
    $folder = "./credential/"
    $credentials = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse credentials for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $credentials)
    {
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "CR_" + $newName
        (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))

    }
    #MANAGED VIRTUAL NETWORK

    $folder = "./managedVirtualNetwork/"
    $files = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse managed virtual networks for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $files)
    {
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "MVN_" + $newName
        (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }

    #managedPrivateEndpoint/default folder within MANAGED VIRTUAL NETWORK
    $folder = "./managedVirtualNetwork/default/managedPrivateEndpoint"
    #if our vnet isolation isnt on, we only want the standard files
    if (!$tout.is_vnet_isolated) {
        $files = (Get-ChildItem -Path $folder -Exclude *is_vnet_isolated*)
    } else {
        $files = (Get-ChildItem -Path $folder -Filter "*.libsonnet" -Verbose)

    }
    Write-Verbose "_____________________________"
    Write-Verbose "Generating Synapse managed private endpoints for Git Integration: " 
    Write-Verbose "_____________________________"
    foreach ($file in $files)
    {
        $schemafiletemplate = (Get-ChildItem -Path ($folder) -Filter "$($file.PSChildName)"  -Verbose)
        $newName = ($file.PSChildName).Replace(".libsonnet",".json")
        $newName = "MVN_default-managedPrivateEndpoint_" + $newName
        $newName = $newName.Replace("[is_vnet_isolated]", "")
        $newName = $newName.Replace("(workspaceName)", $($tout.synapse_workspace_name))
        (jsonnet $schemafiletemplate | Set-Content($newfolder + $newName))
    }

    #REPLACING FQDNS grabbed from az synapse
    #REASON: FQDNS Contains a GUID on these files that I cannot identify where it is retrieved from otherwise

    $files = (Get-ChildItem -Path $newFolder -Filter *fqdns*)
    foreach ($file in $files)
    {
        $fileSysObj = Get-Content $file -raw | ConvertFrom-Json
        $fileAZ = az synapse managed-private-endpoints show --workspace-name $($tout.synapse_workspace_name) --pe-name $fileSysObj.name
        $fileAZ = $fileAZ | ConvertFrom-Json
        $fileSysObj.properties.fqdns = $fileAZ.properties.fqdns
        $newName = $($file.PSChildName).Replace("{fqdns}", "")
        $fileSysObj | ConvertTo-Json -depth 32| Set-Content($($newfolder) + $($newName))
    }


}

