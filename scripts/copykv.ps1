<#
.SYNOPSIS
Copies Azure Key Vault secrets and keys from one vault to another.

.DESCRIPTION
- Secrets are copied by reading their latest value and recreating them in the target vault.
- Keys are copied using backup/restore.
- Secret version IDs are NOT preserved.
- Key backup/restore preserves backed-up key versions, but restore fails if the key already exists in the target vault.
- Key restore requires compatible Azure constraints, including same subscription and same Azure geography.

.REQUIREMENTS
- Az.Accounts
- Az.KeyVault
- Data-plane permission on source and target vaults.
#>

param(
    [string]$SourceVaultName = "kv-ccoe-cc-sbx",

    [string]$TargetVaultName = "kvplatformccsbx",

    [string]$BackupFolder = "C:\Temp\KeyVault-KeyBackups",

    [switch]$CopySecrets = $true,

    [switch]$CopyKeys = $true,

    [switch]$SkipExistingSecrets,

    [switch]$SkipExistingKeys
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
}

function Test-AzModule {
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        throw "Az.Accounts module is not installed. Install it with: Install-Module Az -Scope CurrentUser"
    }

    if (-not (Get-Module -ListAvailable -Name Az.KeyVault)) {
        throw "Az.KeyVault module is not installed. Install it with: Install-Module Az.KeyVault -Scope CurrentUser"
    }
}

function Test-KeyVaultExists {
    param([string]$VaultName)

    $vault = Get-AzKeyVault -VaultName $VaultName -ErrorAction SilentlyContinue

    if (-not $vault) {
        throw "Key Vault not found or no access: $VaultName"
    }

    return $vault
}

function Copy-KeyVaultSecrets {
    param(
        [string]$SourceVaultName,
        [string]$TargetVaultName,
        [switch]$SkipExistingSecrets
    )

    Write-Step "Listing secrets from source vault: $SourceVaultName"

    $secrets = Get-AzKeyVaultSecret -VaultName $SourceVaultName

    if (-not $secrets) {
        Write-Step "No secrets found in source vault."
        return
    }

    foreach ($secret in $secrets) {
        $name = $secret.Name

        try {
            if ($SkipExistingSecrets) {
                $existingSecret = Get-AzKeyVaultSecret `
                    -VaultName $TargetVaultName `
                    -Name $name `
                    -ErrorAction SilentlyContinue

                if ($existingSecret) {
                    Write-Step "Skipping existing secret: $name"
                    continue
                }
            }

            Write-Step "Copying secret: $name"

            $sourceSecret = Get-AzKeyVaultSecret `
                -VaultName $SourceVaultName `
                -Name $name

            $setSecretParams = @{
                VaultName    = $TargetVaultName
                Name         = $name
                SecretValue  = $sourceSecret.SecretValue
            }

            if ($sourceSecret.ContentType) {
                $setSecretParams.ContentType = $sourceSecret.ContentType
            }

            if ($sourceSecret.Tags -and $sourceSecret.Tags.Count -gt 0) {
                $setSecretParams.Tag = $sourceSecret.Tags
            }

            if ($null -ne $sourceSecret.Expires) {
                $setSecretParams.Expires = $sourceSecret.Expires
            }

            if ($null -ne $sourceSecret.NotBefore) {
                $setSecretParams.NotBefore = $sourceSecret.NotBefore
            }

            if ($sourceSecret.Enabled -eq $false) {
                $setSecretParams.Disable = $true
            }

            Set-AzKeyVaultSecret @setSecretParams | Out-Null

            Write-Step "Copied secret: $name"
        }
        catch {
            Write-Warning "Failed to copy secret '$name'. Error: $($_.Exception.Message)"
        }
    }
}

function Copy-KeyVaultKeys {
    param(
        [string]$SourceVaultName,
        [string]$TargetVaultName,
        [string]$BackupFolder,
        [switch]$SkipExistingKeys
    )

    Write-Step "Listing keys from source vault: $SourceVaultName"

    $keys = Get-AzKeyVaultKey -VaultName $SourceVaultName

    if (-not $keys) {
        Write-Step "No keys found in source vault."
        return
    }

    New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null

    foreach ($key in $keys) {
        $name = $key.Name

        try {
            if ($SkipExistingKeys) {
                $existingKey = Get-AzKeyVaultKey `
                    -VaultName $TargetVaultName `
                    -Name $name `
                    -ErrorAction SilentlyContinue

                if ($existingKey) {
                    Write-Step "Skipping existing key: $name"
                    continue
                }
            }

            Write-Step "Backing up key from source vault: $name"

            $safeFileName = $name -replace '[\\/:*?"<>|]', '_'
            $backupFile = Join-Path $BackupFolder "$safeFileName.blob"

            Backup-AzKeyVaultKey `
                -VaultName $SourceVaultName `
                -Name $name `
                -OutputFile $backupFile `
                -Force | Out-Null

            Write-Step "Restoring key to target vault: $name"

            Restore-AzKeyVaultKey `
                -VaultName $TargetVaultName `
                -InputFile $backupFile | Out-Null

            Write-Step "Copied key: $name"
        }
        catch {
            Write-Warning "Failed to copy key '$name'. Error: $($_.Exception.Message)"

            if ($_.Exception.Message -match "Microsoft\.KeyVault/vaults/keys/backup/action") {
                Write-Warning "Key backup requires key data-plane permission on the source vault, for example Key Vault Administrator or another role that includes keys/backup/action. Restore also requires keys/restore/action on the target vault."
            }
        }
    }
}

Test-AzModule

Write-Step "Checking Azure login context."

$context = Get-AzContext

if (-not $context) {
    Write-Step "No Azure context found. Starting login."
    Connect-AzAccount | Out-Null
}

Write-Step "Validating source vault: $SourceVaultName"
$sourceVault = Test-KeyVaultExists -VaultName $SourceVaultName

Write-Step "Validating target vault: $TargetVaultName"
$targetVault = Test-KeyVaultExists -VaultName $TargetVaultName

Write-Step "Source vault location: $($sourceVault.Location)"
Write-Step "Target vault location: $($targetVault.Location)"

if ($CopySecrets) {
    Copy-KeyVaultSecrets `
        -SourceVaultName $SourceVaultName `
        -TargetVaultName $TargetVaultName `
        -SkipExistingSecrets:$SkipExistingSecrets
}

if ($CopyKeys) {
    Copy-KeyVaultKeys `
        -SourceVaultName $SourceVaultName `
        -TargetVaultName $TargetVaultName `
        -BackupFolder $BackupFolder `
        -SkipExistingKeys:$SkipExistingKeys
}

Write-Step "Completed Key Vault copy operation."
