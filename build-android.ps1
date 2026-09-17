$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

& .\setup-pkhex.ps1

Write-Host "[1/3] Running platform-independent PKHeX smoke tests..."
dotnet run --project .\PKHeX.Android.SmokeTests\PKHeX.Android.SmokeTests.csproj -c Release
if ($LASTEXITCODE -ne 0) { throw "Smoke tests failed." }

Write-Host "[2/3] Restoring Android workload/project..."
dotnet workload restore .\PKHeX.Android\PKHeX.Android.csproj
if ($LASTEXITCODE -ne 0) { throw "Android workload restore failed." }
dotnet restore .\PKHeX.Android\PKHeX.Android.csproj
if ($LASTEXITCODE -ne 0) { throw "Android project restore failed." }

Write-Host "[3/3] Publishing Release APK..."
dotnet publish .\PKHeX.Android\PKHeX.Android.csproj -f net10.0-android -c Release --no-restore
if ($LASTEXITCODE -ne 0) { throw "Android publish failed." }

Write-Host "Build gate passed. Check PKHeX.Android\bin\Release\net10.0-android\publish for the APK."
