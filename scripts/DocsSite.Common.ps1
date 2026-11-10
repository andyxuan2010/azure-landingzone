function Resolve-DocsOutputDirectory {
    param([string]$RepoRoot, [string]$OutputDirectory)

    $root = [IO.Path]::GetFullPath($RepoRoot)
    $output = [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
    $parent = [IO.Path]::GetDirectoryName($output)
    $name = [IO.Path]::GetFileName($output)
    if ($parent -ne $root -or $name -notmatch '^_site(?:-[a-zA-Z0-9_-]+)?$') {
        throw 'OutputDirectory must be a direct repository child named _site or _site-<name>.'
    }
    if ((Test-Path -LiteralPath $output) -and
        ((Get-Item -LiteralPath $output -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'Documentation output cannot be a symbolic link or junction.'
    }
    return $output
}

function Test-DocsUrl {
    param([string]$Value, [switch]$Image)

    $decoded = [Net.WebUtility]::HtmlDecode($Value).Trim()
    if ($decoded -match '[\x00-\x20\x7f\\]' -or $decoded.StartsWith('//')) { return $false }
    if ($decoded -match '^([a-zA-Z][a-zA-Z0-9+.-]*):') {
        $schemes = if ($Image) { @('https', 'http') } else { @('https', 'http', 'mailto', 'tel') }
        return $Matches[1].ToLowerInvariant() -in $schemes
    }
    return $true
}
