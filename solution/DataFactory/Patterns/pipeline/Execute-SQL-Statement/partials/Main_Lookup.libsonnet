function(GenerateArm="false", GFPIR="Azure", SourceType="AzureSqlTable")
{

    local SourceType = {
		"AzureSqlTable": import './typesettings/AzureSqlTable.libsonnet',
    "SqlServerTable": import './typesettings/SqlServerTable.libsonnet',
    "AzureSqlDWTable": import './typesettings/AzureSqlDWTable.libsonnet'
	  },
    
 "TypeProperties":SourceType["AzureSqlTable"](GenerateArm, GFPIR)
}