[CmdletBinding()]
param([string]$OutputDirectory = '_site')
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'DocsSite.Common.ps1')
$outputRoot = Resolve-DocsOutputDirectory -RepoRoot $repoRoot -OutputDirectory $OutputDirectory
foreach ($file in @('index.html','styles.css','site.js','search-index.json','.nojekyll')) { if (-not (Test-Path (Join-Path $outputRoot $file) -PathType Leaf)) { throw "Generated site is missing $file" } }
$manifest = Get-Content (Join-Path $repoRoot 'docs-manifest.json') -Raw | ConvertFrom-Json; $documents=@($manifest.documents | Where-Object { $_ -match '(?i)\.md$' }); foreach ($document in $documents) { $page=Join-Path $outputRoot (([IO.Path]::ChangeExtension($document,'.html')).Replace('/','\')); if (-not (Test-Path $page -PathType Leaf)) { throw "Generated page is missing for $document" } }
$index = Get-Content (Join-Path $outputRoot 'index.html') -Raw; if ($index -notmatch '<title>Home · Azure Landing Zone</title>') { throw 'Generated index has an unexpected title' }; if ($index -match '\{\{[A-Z_]+\}\}') { throw 'Generated index contains an unresolved template token' }
Write-Host "Azure documentation site validation passed for $($documents.Count) Markdown documents."

$failures = @(
    foreach ($file in Get-ChildItem -LiteralPath $outputRoot -Filter '*.html' -Recurse) {
        $html = Get-Content -LiteralPath $file.FullName -Raw
        if ($html -match '\{\{(?:DESCRIPTION|PAGE_TITLE|SITE_TITLE|GITHUB_URL|ROOT_PREFIX|ASSET_VERSION|CONTENT)\}\}') { "Unresolved template token in $($file.FullName)" }
        foreach ($match in [regex]::Matches($html, '(?:href|src)="([^"]+)"')) {
            $url = [Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
            if (-not (Test-DocsUrl $url)) { "Unsafe URL in $($file.FullName): $url"; continue }
            if ($url -match '^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|#|//)') { continue }
            $path = ($url -split '[?#]', 2)[0]
            if (-not $path) { continue }
            $target = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $path))
            if (-not (Test-Path -LiteralPath $target -PathType Leaf)) { "Missing generated link in $($file.FullName): $url" }
            elseif ([IO.Path]::GetRelativePath($outputRoot, $target) -match '^\.\.[/\\]') { "Generated link escapes output: $url" }
        }
    }
)
if ($failures.Count) { throw ($failures -join "`n") }
Write-Host 'Generated documentation URLs and local targets passed.'
