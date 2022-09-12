$patterns = ((Get-Content "Patterns.json") | ConvertFrom-Json).Folder | Sort-Object | Get-Unique
$CurDir = $PWD.ToString()

$AllTests = @()
$counter = 0
foreach ($pattern in $patterns) {   

    Write-Verbose "_____________________________"
    Write-Verbose  $pattern
    Write-Verbose "_____________________________"
    $folder = "/pipeline/" + $pattern + "/functionapptests"

    Set-Location -path ($CurDir + $folder)

    if (!(Test-Path "./tests"))
    {
        New-Item -itemType Directory -Name -Force "tests"
    }
    else
    {
        Write-Verbose "Tests Folder already exists"
    }

    $testfile = "./tests/tests.json"
    jsonnet --tla-code seed=$counter "./GenerateTests.jsonnet" | Set-Content($testfile)
    $testfilejson = Get-Content $testfile | ConvertFrom-Json | ForEach-Object {
        $_.TaskMasterId = $counter
        $AllTests += $_
        $counter -= 1
    }    

}

Set-Location -path ($CurDir + '../../../')
Write-Verbose $PWD.ToString()
$AllTests | ConvertTo-Json -Depth 10 | Set-Content -Path  ($PWD.ToString() + '/FunctionApp/FunctionApp.TestHarness/UnitTests/tests.json')
Set-Location $CurDir