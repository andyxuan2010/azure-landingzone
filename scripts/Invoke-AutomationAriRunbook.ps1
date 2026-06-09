param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$AutomationAccountName,

    [string]$RunbookName = "ARI_Runbook",

    [switch]$Wait
)

$ErrorActionPreference = "Stop"

$jobId = az automation runbook start `
    --resource-group $ResourceGroupName `
    --automation-account-name $AutomationAccountName `
    --name $RunbookName `
    --query jobId `
    --output tsv

if (-not $jobId) {
    throw "Failed to start runbook '$RunbookName' in Automation Account '$AutomationAccountName'."
}

Write-Host "Started runbook '$RunbookName' with job ID $jobId"

if (-not $Wait) {
    return
}

do {
    Start-Sleep -Seconds 10
    $status = az automation job show `
        --resource-group $ResourceGroupName `
        --automation-account-name $AutomationAccountName `
        --job-id $jobId `
        --query status `
        --output tsv

    Write-Host "Current job status: $status"
} while ($status -in @("New", "Activating", "Running", "Queued", "Resuming"))

az automation job output list `
    --resource-group $ResourceGroupName `
    --automation-account-name $AutomationAccountName `
    --job-id $jobId `
    --output table

if ($status -ne "Completed") {
    throw "Runbook job $jobId finished with status '$status'."
}
