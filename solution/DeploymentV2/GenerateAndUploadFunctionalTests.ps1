$CurrDir = $PWD
Write-Host "Starting ADF Patterns" -ForegroundColor Yellow
Set-Location ../DataFactory/Patterns/
Invoke-Expression  ./EnvVarsToFile.ps1
Invoke-Expression  ./FuncAppTests_Generate.ps1
Invoke-Expression  ./SqlTests_Generate.ps1
Invoke-Expression  ./SqlTests_Upload.ps1
#Below is temporary - we want to make a parent folder for the both of these directories in the future.
#Currently there are duplicate powershell scripts. Plan is to iterate through each subfolder (datafactory / synapse) with one script
Write-Host "Starting Synapse Patterns" -ForegroundColor Yellow
Set-Location ../../Synapse/Patterns/
Invoke-Expression  ./EnvVarsToFile.ps1
Invoke-Expression  ./FuncAppTests_Generate.ps1
Invoke-Expression  ./SqlTests_Generate.ps1
Invoke-Expression  ./SqlTests_Upload.ps1
Set-Location $CurrDir