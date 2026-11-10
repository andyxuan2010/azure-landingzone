[CmdletBinding()]
param([switch]$SkipTerraform, [switch]$InitializeTerraform)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    $files = @(git ls-files --cached --others --exclude-standard)
    if ($LASTEXITCODE -ne 0) { throw 'Could not enumerate repository files.' }
    $parseErrors = @(
        foreach ($file in ($files | Sort-Object -Unique | Where-Object { $_ -like '*.ps1' })) {
            $tokens = $null
            $errors = $null
            [void][Management.Automation.Language.Parser]::ParseFile((Join-Path $repoRoot $file), [ref]$tokens, [ref]$errors)
            $errors
        }
    )
    if ($parseErrors.Count) { throw ($parseErrors | Out-String) }
    Write-Host 'PowerShell syntax validation passed.'
    & (Join-Path $PSScriptRoot 'Test-SecurityControls.ps1')
    node --check site/site.js
    if ($LASTEXITCODE -ne 0) { throw 'Documentation JavaScript syntax validation failed.' }
    node scripts/validate-doc-links.mjs
    if ($LASTEXITCODE -ne 0) { throw 'Documentation link validation failed.' }
    node scripts/validate-static-sites.mjs
    if ($LASTEXITCODE -ne 0) { throw 'Static site validation failed.' }
    if (-not $SkipTerraform) {
        terraform fmt -check -recursive -diff
        if ($LASTEXITCODE -ne 0) { throw 'Terraform formatting failed.' }
        if ($InitializeTerraform) {
            terraform init -backend=false -input=false -lockfile=readonly
            if ($LASTEXITCODE -ne 0) { throw 'Terraform initialization failed.' }
        }
        terraform validate -no-color
        if ($LASTEXITCODE -ne 0) { throw 'Terraform validation failed.' }
    }
}
finally { Pop-Location }
