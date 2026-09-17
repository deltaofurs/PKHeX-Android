$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$PinFile = Join-Path $Root "PKHEX_COMMIT.txt"
$PkhexDir = Join-Path $Root "PKHeX"

if (-not (Test-Path $PinFile)) {
    throw "Missing $PinFile"
}

$Pinned = (Get-Content $PinFile -Raw).Trim()
$Commit = if ($env:PKHEX_COMMIT) { $env:PKHEX_COMMIT.Trim() } else { $Pinned }
if ($Commit -notmatch '^[0-9a-fA-F]{40}$') {
    throw "Invalid PKHeX commit SHA: $Commit"
}

if (Test-Path (Join-Path $PkhexDir ".git")) {
    git -C $PkhexDir fetch --depth 1 origin $Commit
} else {
    git init $PkhexDir
    git -C $PkhexDir remote add origin https://github.com/kwsch/PKHeX.git
    git -C $PkhexDir fetch --depth 1 origin $Commit
}

git -C $PkhexDir checkout --detach --force FETCH_HEAD
$Actual = (git -C $PkhexDir rev-parse HEAD).Trim()
if ($Actual -ne $Commit) {
    throw "PKHeX pin mismatch: expected $Commit, got $Actual"
}

Write-Host "PKHeX.Core ready at $Actual"
