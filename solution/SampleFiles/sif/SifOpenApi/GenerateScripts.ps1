

$r = Get-Content("./jsonSchemaCreate_AU.json") | ConvertFrom-Json 
$template = ( (Get-Content -Path ./LakeDbTableTemplate.json).Replace("{StorageContainer}",$tout.synapse_lakedatabase_container_name).Replace("{StorageAccount}",$tout.adlsstorage_name).Replace("{SynapseWorkSpace}",$tout.synapse_workspace_name) )
$alldataitems = [System.Collections.ArrayList]::new()


foreach ($prop in $r.definitions | Get-Member)
{
    if ($prop.MemberType -eq "NoteProperty")
    {
        $add = $alldataitems.Add($prop)                
        $propdetail = $r.definitions |  Select-Object -Property $prop.Name -ExpandProperty $prop.Name
        $OneOfCheck =  $propdetail.oneOf
        if(![string]::IsNullOrEmpty($OneOfCheck))
        {
            $entity = "ref_" + $prop.Name.ToLower()
            #Write-Host "PersistRefData(""$entity"", dict1)"
            #Set-Content -Path "../../../Synapse/Patterns/database/siflake/table/$entity.json" -Value $template.Replace("{EntityName}",$entity)
        }       

    }
    
    
    
}

$sqlcommand = @"
Select tbl.name TableName,  c.name ColName, t.name as ColType
from 
sys.tables tbl 
inner join sys.columns c on c.object_id = tbl.object_id
inner join sys.types t on c.System_Type_Id = t.System_Type_Id
--where c.object_id = OBJECT_ID('{TableName}')
order by TableName DESC
--for json path 
"@

$coltemplate = @"
{
    "Name": "{Name}",
    "OriginDataTypeName": {
        "TypeName": "{Type}",
        "IsComplexType": false,
        "IsNullable": true,
        "Length": {Length},
        "Properties": {
            "HIVE_TYPE_STRING": "string"
        }
    }
}
"@

$token=$(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)
$Columns= Invoke-Sqlcmd -ServerInstance ($tout.synapse_workspace_name + "-ondemand.sql.azuresynapse.net") -Database "sif" -AccessToken $token -query $sqlcommand   
$Entities = $Columns | Select-Object -Property "TableName" -unique

foreach ($e in $Entities)
{    
    $cols = @()
    $ecols = $Columns | Where-Object {$_.TableName -eq $e.TableName}
    foreach ($ecol in $ecols)
    {
        $type = "string"
        $length = 8000
        if($ecol.ColType -eq "varchar") {$type = "string"}
        if($ecol.ColType -eq "float") {$type = "float"}
        if($ecol.ColType -eq "bigint") 
        {
            $type = "integer"
            $length = 0
        }
        $cols += ($coltemplate.Replace("{Name}",$ecol.ColName).Replace("{Type}",$type).Replace("{Length}",$length) | ConvertFrom-Json)
    }
    $cols

}
