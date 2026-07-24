# Automation ARI

This landing zone supports Azure Resource Inventory (ARI) as a workload layer on top of the root `automation_accounts` input.

The current implementation is intentionally scoped to:

- Azure Automation Account
- PowerShell 7.4 runtime environment
- ARI runtime package imports
- ARI runbook
- Blob storage output container
- Native Automation schedule and job schedule

The current implementation does not include:

- Hybrid Runbook Worker
- SharePoint or Teams upload
- Microsoft Graph or SharePoint app-role assignment

## Inputs

Configure the base Automation Account in `automation_accounts`, then attach ARI with `automation_ari_workloads`.

Minimal example:

```hcl
automation_accounts = {
  default = {
    enabled                        = true
    sku_name                       = "Basic"
    public_access_enabled          = true
    system_managed_identity_enabled = true
  }
}

automation_ari_workloads = {
  default = {
    enabled                              = true
    automation_account_key               = "default"
    storage_container_name               = "ari"
    report_name                          = "CCOE_AZURE"
    ari_lite_mode                        = false
    ari_diagram_full_environment_enabled = true
    ari_security_center_enabled          = true
  }
}
```

Key fields in `automation_ari_workloads`:

- `automation_account_key`: key of an enabled entry in `automation_accounts`
- `storage_container_name`: blob container for ARI output
- `report_name`: logical report name passed to `Invoke-ARI`
- `report_dir`: working directory inside the runbook runtime
- `ari_lite_mode`: adds `-Lite` to `Invoke-ARI` for lower-cost runs
- `ari_diagram_full_environment_enabled`: controls whether `-DiagramFullEnvironment` is included
- `ari_security_center_enabled`: controls whether `-SecurityCenter` is included
- `runbook_name`: Automation runbook name
- `runtime_environment_name`: PowerShell 7.4 runtime environment name
- `runtime_packages`: optional override map of PowerShell Gallery package URLs
- `schedule_enabled`: whether Terraform should create a schedule and job schedule
- `schedule_start_time`: optional RFC3339 timestamp; if omitted, Terraform defaults to the next day at 08:00 Eastern
- `enable_job_failure_alert`: creates a Log Analytics alert for failed, stopped, or suspended ARI jobs
- `enable_long_running_alert`: creates a Log Analytics alert for ARI jobs that appear to exceed the configured duration threshold
- `long_running_threshold_minutes`: threshold used by the long-running alert query
- `monitor_action_group_ids`: optional Azure Monitor action group IDs for notifications

## Created Resources

When an ARI workload is enabled, the root module creates:

- `azurerm_storage_container`
- `azurerm_automation_runtime_environment`
- `azapi_resource` runtime environment packages
- `azurerm_automation_runbook`
- `azurerm_automation_schedule`
- `azurerm_automation_job_schedule`

The runbook content lives in:

- [runbooks/ari.ps1.tftpl](</n:/home/administrator/Documents/GitHub/CCOE-Azure/IaC/landingzone/runbooks/ari.ps1.tftpl>)

The helper script for manual invocation lives in:

- [scripts/Invoke-AutomationAriRunbook.ps1](</n:/home/administrator/Documents/GitHub/CCOE-Azure/IaC/landingzone/scripts/Invoke-AutomationAriRunbook.ps1>)

## Monitoring and Troubleshooting

The ARI runbook emits elapsed-time checkpoints for:

- module import
- `Invoke-ARI` execution
- report directory creation
- latest generated artifacts
- total runbook duration

By default, the landing zone also creates two Azure Monitor scheduled query alerts per enabled ARI workload:

- job failure alert
- long-running job alert

These alerts query `AzureDiagnostics` in the landing zone Log Analytics workspace, matching the Automation diagnostic categories already enabled by the Automation Account module.

If you want notifications, populate `monitor_action_group_ids` with Azure Monitor action group resource IDs.

## Performance Controls

The ARI workload exposes three runbook-level tuning switches:

- `ari_lite_mode`
- `ari_diagram_full_environment_enabled`
- `ari_security_center_enabled`

Use them when you need to reduce runtime cost or troubleshoot slow executions:

- set `ari_lite_mode = true` to add `-Lite`
- set `ari_diagram_full_environment_enabled = false` to skip `-DiagramFullEnvironment`
- set `ari_security_center_enabled = false` to skip `-SecurityCenter`

These can be used independently. A common low-cost troubleshooting profile is:

```hcl
automation_ari_workloads = {
  default = {
    enabled                              = true
    automation_account_key               = "default"
    ari_lite_mode                        = true
    ari_diagram_full_environment_enabled = false
    ari_security_center_enabled          = false
  }
}
```

Combined with the runbook timing logs, these switches make it easier to determine whether slowdowns are driven by module load, core ARI execution, or the more expensive ARI feature flags.

## Runtime Packages

If `runtime_packages = {}` is left empty, the landing zone uses this built-in package set:

- `AzureResourceInventory`
- `ImportExcel`
- `Az.Accounts`
- `Az.Compute`
- `Az.Storage`
- `Az.ResourceGraph`
- `Az.CostManagement`

Override `runtime_packages` only when you need to pin or replace package versions.

## Storage and RBAC

The root module grants each enabled Automation Account managed identity:

- `Storage Blob Data Contributor` on the landing zone storage account
- `Key Vault Secrets Officer` on the landing zone Key Vault

The ARI blob container is created automatically if the workload is enabled and the container is not already managed elsewhere.

If the container already exists outside Terraform, import it before apply.

## Running the Runbook

Scheduled execution:

- Enable `schedule_enabled = true`
- Optionally set `schedule_start_time`

Manual execution:

```powershell
.\scripts\Invoke-AutomationAriRunbook.ps1 `
  -ResourceGroupName rg-platform-dev `
  -AutomationAccountName aa-platform-eastus-dev-default `
  -RunbookName ARI_Runbook `
  -Wait
```

## Outputs

Useful root outputs:

- `automation_accounts`
- `automation_ari_workloads`
- `automation_role_assignment_ids`
- `automation_ari_alert_rule_ids`

## Notes

- If you attach multiple ARI workloads to the same Automation Account, give them unique `runbook_name`, `runtime_environment_name`, and `schedule_name` values.
- Private endpoint support is configured at the Automation Account layer, not the ARI workload layer.
- This implementation is designed to align with the rest of the landing zone root module pattern instead of reproducing the older single-purpose ARI repo one-for-one.
