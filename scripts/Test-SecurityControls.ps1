[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DocsSite.Common.ps1')
$repoRoot = Split-Path -Parent $PSScriptRoot
foreach ($url in @('javascript:alert(1)', '&#x6a;avascript:alert(1)', 'vbscript:run', 'data:text/html,test', '//example.com', "https://exam`nple.com")) {
    if (Test-DocsUrl $url) { throw "Unsafe documentation URL was accepted: $url" }
}
foreach ($url in @('https://example.com/doc', '../README.md#usage', '#section', 'mailto:team@example.com')) {
    if (-not (Test-DocsUrl $url)) { throw "Safe documentation URL was rejected: $url" }
}
if (Test-DocsUrl 'mailto:team@example.com' -Image) { throw 'Images must not accept mail URLs.' }
foreach ($directory in @('.', '..', 'docs', '../_site', '_site/nested')) {
    $rejected = $false
    try { [void](Resolve-DocsOutputDirectory -RepoRoot $repoRoot -OutputDirectory $directory) }
    catch { $rejected = $true }
    if (-not $rejected) { throw "Unsafe documentation output directory was accepted: $directory" }
}
[void](Resolve-DocsOutputDirectory -RepoRoot $repoRoot -OutputDirectory '_site-security-check')
& (Join-Path $PSScriptRoot 'copykv.ps1') -SourceVaultName source-example -TargetVaultName target-example -WhatIf
$rejected = $false
try { & (Join-Path $PSScriptRoot 'copykv.ps1') -SourceVaultName same-example -TargetVaultName same-example -WhatIf }
catch { $rejected = $true }
if (-not $rejected) { throw 'Key Vault helper accepted identical source and target vaults.' }
Write-Host 'Security regression checks passed: URL schemes, output boundaries, and Key Vault review mode.'
