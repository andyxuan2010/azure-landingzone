[CmdletBinding()]
param([switch]$SkipTerraform, [switch]$InitializeTerraform)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'scripts/Test-Repository.ps1') @PSBoundParameters
