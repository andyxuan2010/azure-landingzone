[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SourceOrg,

    [string]$SourceRepo,

    [string]$TargetOrg = "CCOE-Azure-Terraform",

    [string]$TargetRepo,

    [string]$EnvFile = ".env",

    [string[]]$Environments = @("dev", "sandbox")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Usage {
    Write-Host @"
Usage:
  .\scripts\Sync-GitHubRepoEnv.ps1 [options]

Options:
  -SourceOrg <org>      Source GitHub organization. Defaults to the org from git origin.
  -SourceRepo <repo>    Source GitHub repository. Defaults to the repo from git origin.
  -TargetOrg <org>      Target GitHub organization. Default: CCOE-Azure-Terraform
  -TargetRepo <repo>    Target GitHub repository. Defaults to SourceRepo.
  -EnvFile <path>       Environment file containing values for repo secrets. Default: .env
  -Environments <names> GitHub environments to sync. Default: dev,sandbox
  -WhatIf               Show what would be changed without making updates.
  /?                    Show this usage.

Environment secret values:
  Environment secrets require environment-specific keys in .env to avoid mixing values.
  Preferred block format:
    [dev]
    ARM_CLIENT_ID=...

    [sandbox]
    ARM_CLIENT_ID=...

  For environment 'dev', secret 'ARM_CLIENT_ID' can use DEV_ARM_CLIENT_ID or ARM_CLIENT_ID_DEV.
  For secret 'AZURE_CLIENT_ID', ARM fallback names are also checked, such as DEV_ARM_CLIENT_ID.

Examples:
  .\scripts\Sync-GitHubRepoEnv.ps1 /?
  .\scripts\Sync-GitHubRepoEnv.ps1 -TargetRepo landingzone-sandbox -EnvFile .env
  .\scripts\Sync-GitHubRepoEnv.ps1 -TargetRepo landingzone-sandbox -Environments dev,sandbox -WhatIf
  .\scripts\Sync-GitHubRepoEnv.ps1 -SourceOrg CCOE-Azure -SourceRepo landingzone -TargetRepo landingzone-sandbox -WhatIf
"@
}

if (@($SourceOrg, $SourceRepo, $TargetOrg, $TargetRepo, $EnvFile, $Environments) -contains "/?") {
    Write-Usage
    return
}

$NameFallbacks = @{
    AZURE_CLIENT_ID       = @("ARM_CLIENT_ID")
    AZURE_CLIENT_SECRET   = @("ARM_CLIENT_SECRET")
    AZURE_SUBSCRIPTION_ID = @("ARM_SUBSCRIPTION_ID")
    AZURE_TENANT_ID       = @("ARM_TENANT_ID")
}

function Normalize-OrgName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $normalized = $Name.Trim()

    if ($normalized -match '^[Tt]arget\s+[Oo]rg\s*:\s*(.+)$') {
        $normalized = $Matches[1].Trim()
    }

    return $normalized
}

function Get-RepoRoot {
    try {
        $repoRoot = (git rev-parse --show-toplevel).Trim()
        if (-not [string]::IsNullOrWhiteSpace($repoRoot)) {
            return $repoRoot
        }
    }
    catch {
    }

    return (Get-Location).Path
}

function Resolve-InputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    $repoCandidate = Join-Path (Get-RepoRoot) $Path
    if (Test-Path -LiteralPath $repoCandidate) {
        return $repoCandidate
    }

    $cwdCandidate = Join-Path (Get-Location).Path $Path
    if (Test-Path -LiteralPath $cwdCandidate) {
        return $cwdCandidate
    }

    return $repoCandidate
}

function Get-OriginOrg {
    $originUrl = (git remote get-url origin).Trim()

    if ($originUrl -match '^https://github\.com/([^/]+)/') {
        return $Matches[1]
    }

    if ($originUrl -match '^git@github\.com:([^/]+)/') {
        return $Matches[1]
    }

    throw "Could not infer the source GitHub organization from origin URL: $originUrl"
}

function Get-OriginRepoName {
    $originUrl = (git remote get-url origin).Trim()

    if ($originUrl -match '^https://github\.com/[^/]+/([^/]+?)(?:\.git)?$') {
        return $Matches[1]
    }

    if ($originUrl -match '^git@github\.com:[^/]+/([^/]+?)(?:\.git)?$') {
        return $Matches[1]
    }

    throw "Could not infer the source GitHub repository name from origin URL: $originUrl"
}

function Assert-GhReady {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw "GitHub CLI 'gh' is not installed or not on PATH."
    }

    gh auth status | Out-Null
}

function Read-DotEnv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Resolve-InputPath -Path $Path

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Environment file not found: $resolvedPath"
    }

    $values = @{}
    $sections = @{}
    $currentSection = $null

    foreach ($line in Get-Content -LiteralPath $resolvedPath) {
        $trimmed = $line.Trim()

        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
            continue
        }

        if ($trimmed -match '^\[([A-Za-z0-9_.-]+)\]$') {
            $currentSection = $Matches[1].Trim().ToLowerInvariant()

            if (-not $sections.ContainsKey($currentSection)) {
                $sections[$currentSection] = @{}
            }

            continue
        }

        if ($trimmed -notmatch '^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
            continue
        }

        $name = $Matches[1]
        $value = $Matches[2].Trim()

        if (
            ($value.StartsWith('"') -and $value.EndsWith('"')) -or
            ($value.StartsWith("'") -and $value.EndsWith("'"))
        ) {
            $value = $value.Substring(1, $value.Length - 2)
        }

        if ($currentSection) {
            $sections[$currentSection][$name] = $value
        }
        else {
            $values[$name] = $value
        }
    }

    return [pscustomobject]@{
        Values   = $values
        Sections = $sections
    }
}

function Get-GhJson {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub CLI command failed: gh $($Arguments -join ' ')"
    }

    if ([string]::IsNullOrWhiteSpace($output)) {
        return $null
    }

    return $output | ConvertFrom-Json
}

function Get-GhLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub CLI command failed: gh $($Arguments -join ' ')"
    }

    return @($output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-RepoSecretNames {
    param(
        [string]$Owner,
        [string]$Repo
    )

    return @(
        Get-GhLines @(
            "api", "--paginate",
            "repos/$Owner/$Repo/actions/secrets",
            "--jq", ".secrets[]?.name"
        )
    )
}

function Get-RepoVariableNames {
    param(
        [string]$Owner,
        [string]$Repo
    )

    return @(
        Get-GhLines @(
            "api", "--paginate",
            "repos/$Owner/$Repo/actions/variables",
            "--jq", ".variables[]?.name"
        )
    )
}

function Get-RepoEnvironmentNames {
    param(
        [string]$Owner,
        [string]$Repo
    )

    return @(
        Get-GhLines @(
            "api", "--paginate",
            "repos/$Owner/$Repo/environments",
            "--jq", ".environments[]?.name"
        )
    )
}

function Get-RepoEnvironmentSecretNames {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Environment
    )

    return @(
        Get-GhLines @(
            "api", "--paginate",
            "repos/$Owner/$Repo/environments/$Environment/secrets",
            "--jq", ".secrets[]?.name"
        )
    )
}

function Get-RepoEnvironmentVariableNames {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Environment
    )

    return @(
        Get-GhLines @(
            "api", "--paginate",
            "repos/$Owner/$Repo/environments/$Environment/variables",
            "--jq", ".variables[]?.name"
        )
    )
}

function Get-RepoVariableDetail {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Name
    )

    return Get-GhJson @("api", "repos/$Owner/$Repo/actions/variables/$Name")
}

function Get-RepoEnvironmentVariableDetail {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Environment,
        [string]$Name
    )

    return Get-GhJson @("api", "repos/$Owner/$Repo/environments/$Environment/variables/$Name")
}

function Get-EnvValueForName {
    param(
        [hashtable]$EnvValues,
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return [pscustomobject]@{
            Found      = $false
            SourceName = $null
            Value      = $null
        }
    }

    if ($EnvValues.ContainsKey($Name)) {
        return [pscustomobject]@{
            Found      = $true
            SourceName = $Name
            Value      = $EnvValues[$Name]
        }
    }

    $fallbackNames = @($NameFallbacks[$Name] | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    foreach ($fallbackName in $fallbackNames) {
        if (-not [string]::IsNullOrWhiteSpace($fallbackName) -and $EnvValues.ContainsKey($fallbackName)) {
            return [pscustomobject]@{
                Found      = $true
                SourceName = $fallbackName
                Value      = $EnvValues[$fallbackName]
            }
        }
    }

    return [pscustomobject]@{
        Found      = $false
        SourceName = $null
        Value      = $null
    }
}

function Get-EnvironmentKeyPrefix {
    param([string]$Environment)

    return ($Environment.Trim().ToUpperInvariant() -replace '[^A-Z0-9]', '_')
}

function Get-EnvNameCandidates {
    param([string]$Name)

    return @(
        $Name
        $NameFallbacks[$Name]
    ) |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique
}

function Get-EnvironmentEnvValueForName {
    param(
        [hashtable]$EnvValues,
        [hashtable]$EnvSections,
        [string]$Environment,
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Environment) -or [string]::IsNullOrWhiteSpace($Name)) {
        return [pscustomobject]@{
            Found      = $false
            SourceName = $null
            Value      = $null
        }
    }

    $environmentKey = Get-EnvironmentKeyPrefix -Environment $Environment
    $sectionKey = $Environment.Trim().ToLowerInvariant()

    if ($EnvSections.ContainsKey($sectionKey)) {
        foreach ($candidateName in (Get-EnvNameCandidates -Name $Name)) {
            if ($EnvSections[$sectionKey].ContainsKey($candidateName)) {
                return [pscustomobject]@{
                    Found      = $true
                    SourceName = "[$sectionKey] $candidateName"
                    Value      = $EnvSections[$sectionKey][$candidateName]
                }
            }
        }
    }

    $candidateNames = @(
        foreach ($candidateName in (Get-EnvNameCandidates -Name $Name)) {
            "$($environmentKey)_$candidateName"
            "$($candidateName)_$environmentKey"
        }
    ) | Sort-Object -Unique

    foreach ($candidateName in $candidateNames) {
        if ($EnvValues.ContainsKey($candidateName)) {
            return [pscustomobject]@{
                Found      = $true
                SourceName = $candidateName
                Value      = $EnvValues[$candidateName]
            }
        }
    }

    return [pscustomobject]@{
        Found      = $false
        SourceName = $null
        Value      = $null
    }
}

function Get-MatchedNames {
    param(
        [string[]]$Names,
        [hashtable]$EnvValues
    )

    return @(
        $Names |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Where-Object { (Get-EnvValueForName -EnvValues $EnvValues -Name $_).Found } |
        Sort-Object -Unique
    )
}

function Get-MatchedEnvironmentNames {
    param(
        [string[]]$Names,
        [hashtable]$EnvValues,
        [hashtable]$EnvSections,
        [string]$Environment
    )

    return @(
        $Names |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Where-Object { (Get-EnvironmentEnvValueForName -EnvValues $EnvValues -EnvSections $EnvSections -Environment $Environment -Name $_).Found } |
        Sort-Object -Unique
    )
}

function Get-UnmatchedNames {
    param(
        [string[]]$Names,
        [hashtable]$EnvValues
    )

    return @(
        $Names |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Where-Object { -not (Get-EnvValueForName -EnvValues $EnvValues -Name $_).Found } |
        Sort-Object -Unique
    )
}

function Get-UnmatchedEnvironmentNames {
    param(
        [string[]]$Names,
        [hashtable]$EnvValues,
        [hashtable]$EnvSections,
        [string]$Environment
    )

    return @(
        $Names |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Where-Object { -not (Get-EnvironmentEnvValueForName -EnvValues $EnvValues -EnvSections $EnvSections -Environment $Environment -Name $_).Found } |
        Sort-Object -Unique
    )
}

function Write-NameList {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [AllowNull()]
        [object]$Items
    )

    $normalizedItems = @(
        foreach ($item in @($Items)) {
            if ($null -ne $item) {
                [string]$item
            }
        }
    )

    Write-Host ""
    Write-Host $Title

    if ($normalizedItems.Count -eq 0) {
        Write-Host "  (none)"
        return
    }

    foreach ($item in ($normalizedItems | Sort-Object -Unique)) {
        Write-Host "  $item"
    }
}

function Assert-RepoExists {
    param(
        [string]$Owner,
        [string]$Repo
    )

    & gh repo view "$Owner/$Repo" --json nameWithOwner | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Repository '$Owner/$Repo' was not found or is not accessible."
    }
}

function Ensure-RepoEnvironment {
    param(
        [string]$Owner,
        [string]$Repo,
        [string]$Environment,
        [string[]]$ExistingEnvironments
    )

    if ($Environment -in @($ExistingEnvironments)) {
        return $true
    }

    if ($PSCmdlet.ShouldProcess("$Owner/$Repo/$Environment", "Create GitHub repository environment")) {
        & gh api --method PUT "repos/$Owner/$Repo/environments/$Environment" | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create environment '$Environment' in '$Owner/$Repo'."
        }

        return $true
    }

    return $false
}

function Sync-RepoSecret {
    param(
        [string]$SourceOrg,
        [string]$SourceRepo,
        [string]$TargetOrg,
        [string]$TargetRepo,
        [string]$Name,
        [hashtable]$EnvValues
    )

    $envMatch = Get-EnvValueForName -EnvValues $EnvValues -Name $Name
    if (-not $envMatch.Found) {
        throw "No matching value found in .env for repo secret '${SourceOrg}/${SourceRepo}:$Name'."
    }

    if ($PSCmdlet.ShouldProcess("$TargetOrg/$TargetRepo/$Name", "Set GitHub repository secret")) {
        & gh secret set $Name --repo "$TargetOrg/$TargetRepo" --body $envMatch.Value
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set repo secret '$Name' in '$TargetOrg/$TargetRepo'."
        }
    }
}

function Sync-RepoEnvironmentSecret {
    param(
        [string]$SourceOrg,
        [string]$SourceRepo,
        [string]$TargetOrg,
        [string]$TargetRepo,
        [string]$Environment,
        [string]$Name,
        [hashtable]$EnvValues,
        [hashtable]$EnvSections
    )

    $envMatch = Get-EnvironmentEnvValueForName -EnvValues $EnvValues -EnvSections $EnvSections -Environment $Environment -Name $Name
    if (-not $envMatch.Found) {
        throw "No environment-specific value found in .env for environment secret '${SourceOrg}/${SourceRepo}/${Environment}:$Name'. Expected section key '[$Environment] $Name' or keys like '$((Get-EnvironmentKeyPrefix -Environment $Environment))_$Name' or '${Name}_$((Get-EnvironmentKeyPrefix -Environment $Environment))'."
    }

    if ($PSCmdlet.ShouldProcess("$TargetOrg/$TargetRepo/$Environment/$Name", "Set GitHub environment secret")) {
        & gh secret set $Name --repo "$TargetOrg/$TargetRepo" --env $Environment --body $envMatch.Value
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set environment secret '$Name' in '$TargetOrg/$TargetRepo' environment '$Environment'."
        }
    }
}

function Sync-RepoVariable {
    param(
        [string]$SourceOrg,
        [string]$SourceRepo,
        [string]$TargetOrg,
        [string]$TargetRepo,
        [string]$Name
    )

    $detail = Get-RepoVariableDetail -Owner $SourceOrg -Repo $SourceRepo -Name $Name

    if ($PSCmdlet.ShouldProcess("$TargetOrg/$TargetRepo/$Name", "Set GitHub repository variable")) {
        & gh variable set $Name --repo "$TargetOrg/$TargetRepo" --body ([string]$detail.value)
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set repo variable '$Name' in '$TargetOrg/$TargetRepo'."
        }
    }
}

function Sync-RepoEnvironmentVariable {
    param(
        [string]$SourceOrg,
        [string]$SourceRepo,
        [string]$TargetOrg,
        [string]$TargetRepo,
        [string]$Environment,
        [string]$Name
    )

    $detail = Get-RepoEnvironmentVariableDetail -Owner $SourceOrg -Repo $SourceRepo -Environment $Environment -Name $Name

    if ($PSCmdlet.ShouldProcess("$TargetOrg/$TargetRepo/$Environment/$Name", "Set GitHub environment variable")) {
        & gh variable set $Name --repo "$TargetOrg/$TargetRepo" --env $Environment --body ([string]$detail.value)
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set environment variable '$Name' in '$TargetOrg/$TargetRepo' environment '$Environment'."
        }
    }
}

Assert-GhReady

if (-not $SourceOrg) {
    $SourceOrg = Get-OriginOrg
}

if (-not $SourceRepo) {
    $SourceRepo = Get-OriginRepoName
}

$SourceOrg = Normalize-OrgName -Name $SourceOrg
$TargetOrg = Normalize-OrgName -Name $TargetOrg
$SourceRepo = $SourceRepo.Trim()

if (-not $TargetRepo) {
    $TargetRepo = $SourceRepo
}

$TargetRepo = $TargetRepo.Trim()
$Environments = @(
    $Environments |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    ForEach-Object { $_.Trim() } |
    Sort-Object -Unique
)

$envFileData = Read-DotEnv -Path $EnvFile
$envValues = $envFileData.Values
$envSections = $envFileData.Sections

Assert-RepoExists -Owner $SourceOrg -Repo $SourceRepo
Assert-RepoExists -Owner $TargetOrg -Repo $TargetRepo

$sourceRepoSecrets = Get-RepoSecretNames -Owner $SourceOrg -Repo $SourceRepo
$sourceRepoVariables = Get-RepoVariableNames -Owner $SourceOrg -Repo $SourceRepo
$targetRepoSecrets = Get-RepoSecretNames -Owner $TargetOrg -Repo $TargetRepo
$targetRepoVariables = Get-RepoVariableNames -Owner $TargetOrg -Repo $TargetRepo
$sourceEnvironmentNames = Get-RepoEnvironmentNames -Owner $SourceOrg -Repo $SourceRepo
$targetEnvironmentNames = Get-RepoEnvironmentNames -Owner $TargetOrg -Repo $TargetRepo

$matchedSecrets = @(Get-MatchedNames -Names $sourceRepoSecrets -EnvValues $envValues)
$unmatchedSecrets = @(Get-UnmatchedNames -Names $sourceRepoSecrets -EnvValues $envValues)
$matchedVariables = @($sourceRepoVariables | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)

$environmentScope = @{}
foreach ($environment in $Environments) {
    if ($environment -notin @($sourceEnvironmentNames)) {
        Write-Warning "Source environment '$environment' was not found in '$SourceOrg/$SourceRepo'. Skipping."
        continue
    }

    $targetEnvironmentAvailable = Ensure-RepoEnvironment -Owner $TargetOrg -Repo $TargetRepo -Environment $environment -ExistingEnvironments $targetEnvironmentNames
    if ($targetEnvironmentAvailable -and $environment -notin @($targetEnvironmentNames)) {
        $targetEnvironmentNames = @($targetEnvironmentNames + $environment | Sort-Object -Unique)
    }

    $sourceEnvironmentSecrets = Get-RepoEnvironmentSecretNames -Owner $SourceOrg -Repo $SourceRepo -Environment $environment
    $sourceEnvironmentVariables = Get-RepoEnvironmentVariableNames -Owner $SourceOrg -Repo $SourceRepo -Environment $environment
    $targetEnvironmentSecrets = @()
    $targetEnvironmentVariables = @()

    if ($targetEnvironmentAvailable) {
        $targetEnvironmentSecrets = Get-RepoEnvironmentSecretNames -Owner $TargetOrg -Repo $TargetRepo -Environment $environment
        $targetEnvironmentVariables = Get-RepoEnvironmentVariableNames -Owner $TargetOrg -Repo $TargetRepo -Environment $environment
    }

    $environmentScope[$environment] = [pscustomobject]@{
        SourceSecrets    = @($sourceEnvironmentSecrets)
        SourceVariables  = @($sourceEnvironmentVariables)
        TargetSecrets    = @($targetEnvironmentSecrets)
        TargetVariables  = @($targetEnvironmentVariables)
        MatchedSecrets   = @(Get-MatchedEnvironmentNames -Names $sourceEnvironmentSecrets -EnvValues $envValues -EnvSections $envSections -Environment $environment)
        UnmatchedSecrets = @(Get-UnmatchedEnvironmentNames -Names $sourceEnvironmentSecrets -EnvValues $envValues -EnvSections $envSections -Environment $environment)
        MatchedVariables = @($sourceEnvironmentVariables | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    }
}

$matchedEnvironmentSecretCount = @($environmentScope.Values | ForEach-Object { $_.MatchedSecrets }).Count
$matchedEnvironmentVariableCount = @($environmentScope.Values | ForEach-Object { $_.MatchedVariables }).Count

Write-Host "Source repo: $SourceOrg/$SourceRepo"
Write-Host "Target repo: $TargetOrg/$TargetRepo"
Write-Host "Env file: $EnvFile"
Write-Host "Environments requested: $($Environments -join ', ')"
Write-Host "Matching repo secrets: $($matchedSecrets.Count)"
Write-Host "Matching repo variables: $($matchedVariables.Count)"
Write-Host "Matching environment secrets: $matchedEnvironmentSecretCount"
Write-Host "Matching environment variables: $matchedEnvironmentVariableCount"
Write-NameList -Title "Env keys discovered:" -Items @($envValues.Keys)
Write-NameList -Title "Env sections discovered:" -Items @($envSections.Keys)

Write-Host ""
Write-Host "=== Repo Level ==="
Write-NameList -Title "Secrets in source repo:" -Items $sourceRepoSecrets
Write-NameList -Title "Secrets already in target repo:" -Items $targetRepoSecrets
Write-NameList -Title "Secrets to sync from ${EnvFile}:" -Items $matchedSecrets
Write-NameList -Title "Variables in source repo:" -Items $sourceRepoVariables
Write-NameList -Title "Variables already in target repo:" -Items $targetRepoVariables
Write-NameList -Title "Variables to copy from source repo:" -Items $matchedVariables

foreach ($environment in $Environments) {
    if (-not $environmentScope.ContainsKey($environment)) {
        continue
    }

    $environmentData = $environmentScope[$environment]
    Write-Host ""
    Write-Host "=== Environment: $environment ==="
    Write-NameList -Title "Secrets in source environment:" -Items $environmentData.SourceSecrets
    Write-NameList -Title "Secrets already in target environment:" -Items $environmentData.TargetSecrets
    Write-NameList -Title "Secrets to sync from environment-specific keys in ${EnvFile}:" -Items $environmentData.MatchedSecrets
    Write-NameList -Title "Variables in source environment:" -Items $environmentData.SourceVariables
    Write-NameList -Title "Variables already in target environment:" -Items $environmentData.TargetVariables
    Write-NameList -Title "Variables to copy from source environment:" -Items $environmentData.MatchedVariables
}

foreach ($name in $matchedSecrets) {
    Sync-RepoSecret -SourceOrg $SourceOrg -SourceRepo $SourceRepo -TargetOrg $TargetOrg -TargetRepo $TargetRepo -Name $name -EnvValues $envValues
}

foreach ($name in $matchedVariables) {
    Sync-RepoVariable -SourceOrg $SourceOrg -SourceRepo $SourceRepo -TargetOrg $TargetOrg -TargetRepo $TargetRepo -Name $name
}

foreach ($environment in $Environments) {
    if (-not $environmentScope.ContainsKey($environment)) {
        continue
    }

    $environmentData = $environmentScope[$environment]
    foreach ($name in $environmentData.MatchedSecrets) {
        Sync-RepoEnvironmentSecret -SourceOrg $SourceOrg -SourceRepo $SourceRepo -TargetOrg $TargetOrg -TargetRepo $TargetRepo -Environment $environment -Name $name -EnvValues $envValues -EnvSections $envSections
    }

    foreach ($name in $environmentData.MatchedVariables) {
        Sync-RepoEnvironmentVariable -SourceOrg $SourceOrg -SourceRepo $SourceRepo -TargetOrg $TargetOrg -TargetRepo $TargetRepo -Environment $environment -Name $name
    }
}

if ($unmatchedSecrets.Count -gt 0) {
    Write-Host ""
    Write-Host "Repo secrets skipped because no same-named value exists in ${EnvFile}:"
    $unmatchedSecrets | ForEach-Object { Write-Host "  $_" }
}

foreach ($environment in $Environments) {
    if (-not $environmentScope.ContainsKey($environment)) {
        continue
    }

    $environmentData = $environmentScope[$environment]
    if (@($environmentData.UnmatchedSecrets).Count -gt 0) {
        Write-Host ""
        Write-Host "Environment secrets skipped because no environment-specific value exists in ${EnvFile} [$environment]:"
        $environmentData.UnmatchedSecrets | ForEach-Object { Write-Host "  $_" }
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Repo secrets synced from ${EnvFile}: $($matchedSecrets.Count)"
Write-Host "Repo variables copied from source: $($matchedVariables.Count)"
Write-Host "Environment secrets synced from ${EnvFile}: $matchedEnvironmentSecretCount"
Write-Host "Environment variables copied from source: $matchedEnvironmentVariableCount"

if ($unmatchedSecrets.Count -gt 0) {
    Write-Host "Repo secrets skipped: $($unmatchedSecrets.Count)"
}

$environmentSkippedSecrets = @($environmentScope.Values | ForEach-Object { @($_.UnmatchedSecrets).Count } | Measure-Object -Sum)
if (($environmentSkippedSecrets.Sum | ForEach-Object { $_ }) -gt 0) {
    Write-Host "Environment secrets skipped: $($environmentSkippedSecrets.Sum)"
}
