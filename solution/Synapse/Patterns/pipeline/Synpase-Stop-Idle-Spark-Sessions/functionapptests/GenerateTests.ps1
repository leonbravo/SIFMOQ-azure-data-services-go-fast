param($SynapseSqlPoolName="Test")
  
$testfile = "./tests/tests.json"
jsonnet "./GenerateTests.jsonnet" --tla-str SynapseSqlPoolName="$SynapseSqlPoolName" | Set-Content($testfile)
Copy-Item -Path $testfile -Destination '../../../../../FunctionApp/consoleapp/UnitTests/tests.json' -force