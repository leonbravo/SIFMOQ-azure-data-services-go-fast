$r = Get-Content("./jsonSchemaCreate_AU.json") | ConvertFrom-Json 
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
            $entity = $prop.Name
            Write-Host "PersistRefData(""$entity"", dict1)"
        }

    }
    
    
    
}