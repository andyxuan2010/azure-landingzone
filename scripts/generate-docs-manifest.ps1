$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$trackedFiles = @(git -C $repoRoot ls-files)
if ($LASTEXITCODE -ne 0) { throw 'Could not enumerate tracked documentation.' }
$documents = $trackedFiles |
    Where-Object { $_ -notmatch '^static-web-apps/' } |
    Where-Object { $_ -match '\.md$' } |
    Sort-Object |
    ForEach-Object { $_ -replace '\\', '/' }

$manifest = @{
    generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    documents   = @($documents)
}

$json = $manifest | ConvertTo-Json -Depth 3
[System.IO.File]::WriteAllText(
    (Join-Path $repoRoot "docs-manifest.json"),
    $json + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Wrote docs-manifest.json with $($documents.Count) documentation files."
