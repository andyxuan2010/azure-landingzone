# Landing Zone Resource Inventory

This file lists the Azure landing zone resources wired in the root Terraform module.

Scope:

- Root wiring in `main.tf`
- Current checked-in environment inputs in `environments/sandbox/terraform.tfvars` and `environments/dev/terraform.tfvars`
- Resources currently active, plus resources that are already wired and can be provisioned by changing feature flags or per-item `enabled` values

Important behavior: `local.feature_flags` reads the `features` map first. If a key exists in `features`, that value wins over later variables like `enable_aks = true` or `enable_linux_vm = true`.

## Current Feature State

The sandbox and dev tfvars currently set these high-level features the same way:

| Feature | Current value | Effect |
| --- | --- | --- |
| `enable_private_dns` | `true` | Private DNS module is active. |
| `enable_adf` | `true` | Azure Data Factory module is active. |
| `enable_azure_ai_search` | `true` | Azure AI Search module is active. |
| `enable_azure_ai_service` | `true` | Azure AI Services module is active. |
| `enable_openai` | `true` | Azure OpenAI module is active. |
| `enable_app_services` | `true` | App Service wiring is active, but only entries with `app_services[*].enabled = true` are created. |
| `enable_app_registration_for_appservice` | `true` | App registrations are created only for enabled App Service entries. |
| `enable_automation_accounts` | `true` | Automation Account wiring is active. |
| `enable_automation_ari_workloads` | `true` | ARI runbook workload wiring is active. |
| `enable_management_group` | `false` | Management groups are wired but not active. |
| `enable_subscription_bootstrap` | `false` | Subscription vending is wired but not active. |
| `enable_acr` | `false` | Azure Container Registry is wired but not active. |
| `enable_linux_vm` | `false` | Linux VM module is wired but not active, even where a later `enable_linux_vm = true` appears. |
| `enable_aks` | `false` | AKS module is wired but not active, even where a later `enable_aks = true` appears. |
| `enable_sqldb` | `false` | SQL DB module is wired but not active, even where a later `enable_sqldb = true` appears. |

## Currently Provisioned By The Checked-In Feature Map

These resources are active without changing the top-level `features` map.

### Foundation

| Terraform address | Azure resource or configuration |
| --- | --- |
| `module.resource_group` | Landing zone resource group. |
| `module.log_analytics` | Log Analytics workspace. |
| `module.storage_account` | Shared storage account. |
| `module.keyvault` | Shared Key Vault. |
| `azapi_update_resource.storage_account_blob_service` | Blob data protection settings: versioning, soft delete, change feed, and restore policy. |
| `azapi_resource.shared_storage_container` | Shared blob containers: `localization`, `scripts`, and `terraform`. |
| `azapi_resource.shared_storage_container_immutability_policy` | Optional container immutability policies when `storage_account_container_immutability_policies` is populated. |
| `azurerm_key_vault_secret.linux_vm_admin_override` | Optional Linux VM admin override secrets when the related values are non-empty. |

### Network

| Terraform address | Azure resource or configuration |
| --- | --- |
| `module.hub_virtual_network` | Hub VNet with `AzureFirewallSubnet`. |
| `module.spoke_virtual_network` | Spoke VNet. |
| `azurerm_virtual_network_peering.hub_to_spoke` | Hub-to-spoke VNet peering. |
| `azurerm_virtual_network_peering.spoke_to_hub` | Spoke-to-hub VNet peering. |
| `module.network_security_group` | Spoke workload NSG. |
| `azurerm_subnet_network_security_group_association.spoke_network_security_group` | NSG associations for `snet-app`, `snet-aks`, `snet-jumpbox`, `snet-databricks-public`, and `snet-databricks-private`. |
| `module.private_dns` | Private DNS zones from `private_dns_zone_names`, linked to the spoke VNet. |

The spoke VNet is wired with these subnets:

- `snet-app`
- `snet-private-endpoints`
- `snet-databricks-public`
- `snet-databricks-private`
- `snet-aks`
- `snet-jumpbox`
- `snet-sqlmi`
- `vnet-integration`

Sandbox currently has `privatelink.azurewebsites.net` enabled in `private_dns_zone_names`. Dev currently has the listed private DNS zones commented out, so the module is active but creates no zones unless the list is populated.

### AI And Integration

| Terraform address | Azure resource or configuration |
| --- | --- |
| `module.azure_ai_search` | Azure AI Search service. Sandbox/dev use `azure_ai_search_sku = "free"`. |
| `module.azure_ai_service` | Azure AI Services account. |
| `module.openai` | Azure OpenAI account and any configured `openai_deployments`. |
| `module.adf_basic` | Azure Data Factory with managed virtual network and diagnostics wiring. |

Private endpoint support for these services is wired separately and remains off until the specific private endpoint flag is set.

### Automation And ARI

| Terraform address | Azure resource or configuration |
| --- | --- |
| `module.automation_account` | One Automation Account per enabled `automation_accounts` entry. Current enabled key: `default`. |
| `azurerm_role_assignment.automation_account_storage_blob_data_contributor` | Storage Blob Data Contributor for each system-assigned Automation Account identity. |
| `azurerm_role_assignment.automation_account_key_vault_secrets_officer` | Key Vault Secrets Officer for each system-assigned Automation Account identity. |
| `azurerm_storage_container.automation_ari` | ARI output container, currently `ari`. |
| `azurerm_automation_runtime_environment.automation_ari` | PowerShell 7.4 runtime environment for each enabled ARI workload. |
| `azapi_resource.automation_ari_runtime_package` | Runtime packages for ARI, including AzureResourceInventory, ImportExcel, ThreadJob, and Az modules. |
| `azurerm_automation_runbook.automation_ari` | ARI runbook from `runbooks/ari.ps1.tftpl`. |
| `azurerm_automation_schedule.automation_ari` | ARI runbook schedule when `schedule_enabled = true`. |
| `azurerm_automation_job_schedule.automation_ari` | Runbook-to-schedule association. |

Current enabled ARI workload key: `default`.

## Wired But Not Currently Provisioned

These are already connected in `main.tf` and can be provisioned by changing flags or enabled map entries.

| Resource area | Terraform address | How to turn on |
| --- | --- | --- |
| Management groups | `module.mg_platform`, `module.mg_landingzone`, `module.mg_sandboxes`, child management group modules | Set `features.enable_management_group = true`. |
| Subscription vending and management group association | `module.subscription_vending` | Set `features.enable_management_group = true` and `features.enable_subscription_bootstrap = true`, then configure `hierarchy_subscriptions`. |
| App Service plans | `module.app_service_plan` | Keep `features.enable_app_services = true` and set one or more `app_services.<key>.enabled = true`. |
| App Services | `module.app_service` | Same as App Service plans. Current map entries are `dotnet`, `node`, and `python`, all currently disabled. |
| App registrations for App Service | `module.app_registration_appservice` | Enable at least one App Service entry and keep `features.enable_app_registration_for_appservice = true`. |
| Linux VM jumpbox or runner | `module.linux_vm_basic` | Set `features.enable_linux_vm = true`. |
| Linux VM-to-App Service RBAC | `azurerm_role_assignment.linux_vm_app_service_website_contributor` | Set `features.enable_linux_vm = true`, keep `linux_vm_enable_system_assigned_identity = true`, and enable one or more App Service entries. |
| AKS | `module.aks` | Set `features.enable_aks = true`. |
| Azure SQL Database | `module.sqldb` | Set `features.enable_sqldb = true` and provide valid SQL admin and Entra admin inputs. |
| Azure Container Registry | `module.acr` | Set `features.enable_acr = true`. |

## One-Flag Or Small-Flag Optional Features

These are wired as flags inside active modules or module inputs.

| Optional capability | How to turn on |
| --- | --- |
| App Service private endpoint | Set `app_service_enable_private_endpoint = true` and include `privatelink.azurewebsites.net` in `private_dns_zone_names`. |
| App Service VNet integration | Set `app_service_vnet_integration_enabled = true`. |
| App Service autoscale | Set `app_service_plan_enable_autoscale = true`. |
| Automation Account private endpoint | Set `automation_accounts.<key>.private_endpoint_enabled = true`; add `privatelink.azure-automation.net` to `private_dns_zone_names` when using root-managed DNS. |
| Automation Account diagnostics | Set `automation_accounts.<key>.enable_diagnostics = true`. |
| Azure AI Search private endpoint | Set `enable_azure_ai_search_private_endpoint = true`; add `privatelink.search.windows.net` to `private_dns_zone_names` when using root-managed DNS. |
| Azure AI Search diagnostics | Set `azure_ai_search_enable_diagnostics = true`. |
| Azure AI Services private endpoint | Set `enable_azure_ai_service_private_endpoint = true`; add `privatelink.cognitiveservices.azure.com` to `private_dns_zone_names` when using root-managed DNS. |
| Azure AI Services diagnostics | Set `azure_ai_service_enable_diagnostics = true`. |
| Azure OpenAI private endpoint | Set `enable_openai_private_endpoint = true`; add `privatelink.openai.azure.com` to `private_dns_zone_names` when using root-managed DNS. |
| Azure OpenAI model deployments | Add entries to `openai_deployments`. |
| Azure OpenAI diagnostics | Set `openai_enable_diagnostics = true`. |
| ADF private endpoint | Set `adf_enable_private_endpoint = true`; add `privatelink.datafactory.azure.net` or provide `adf_private_dns_zone_id`. |
| ADF self-hosted integration runtime path | Set `adf_self_hosted_integration_runtime_enabled = true` and provide the related VM/network inputs expected by the ADF module. |
| ACR private endpoint | Set `features.enable_acr = true`, `acr_enable_private_endpoint = true`, and include `privatelink.azurecr.io` in `private_dns_zone_names` when using root-managed DNS. |
| ACR diagnostics | Set `features.enable_acr = true` and `acr_enable_diagnostics = true`. |
| Linux VM localization extension | Set `features.enable_linux_vm = true` and `linux_vm_enable_linux_vm_extension = true`. |
| Linux VM domain join | Set `features.enable_linux_vm = true` and `linux_vm_enable_domain_join = true`. |
| Linux VM public networking | Set `features.enable_linux_vm = true` and `linux_vm_public_network_enabled = true`. |
| AKS diagnostics | Set `features.enable_aks = true` and `aks_enable_diagnostics = true`. |
| SQL public endpoint and firewall rule | Set `features.enable_sqldb = true`, `sql_public_network_access_enabled = true`, and populate `sql_firewall_rules`. |
| Storage container immutability | Populate `storage_account_container_immutability_policies`; set `storage_account_allow_state_container_immutability = true` only if applying immutability to the `terraform` container is intentional. |

## Commented-Out Root Blocks

These are present in `main.tf` but are commented out, so they require code uncommenting before a flag can create them.

| Resource area | Terraform block | Status |
| --- | --- | --- |
| Azure Firewall | `module "firewall"` | Commented out. The hub VNet has `AzureFirewallSubnet`, but no Firewall resource is created. |
| ARI job failure alert | `azurerm_monitor_scheduled_query_rules_alert_v2.automation_ari_job_failure` | Commented out. ARI workload inputs already include alert settings. |
| ARI long-running alert | `azurerm_monitor_scheduled_query_rules_alert_v2.automation_ari_long_running` | Commented out. ARI workload inputs already include alert settings. |

## Private DNS Zones Ready To Enable

The variable and tfvars comments show these zones as intended options:

- `privatelink.blob.core.windows.net`
- `privatelink.vaultcore.azure.net`
- `privatelink.azurewebsites.net`
- `privatelink.azurecr.io`
- `privatelink.search.windows.net`
- `privatelink.openai.azure.com`
- `privatelink.azure-automation.net`
- `privatelink.servicebus.windows.net`
- `privatelink.cognitiveservices.azure.com`
- `privatelink.datafactory.azure.net`
- `privatelink.database.windows.net`

Add the required zone name to `private_dns_zone_names` when the corresponding private endpoint is enabled and the root private DNS module should manage that zone.

## Not Wired In The Current Root Module

The repo documents or variable names mention these patterns, but there is no active root module block for them in the current `main.tf`:

- Databricks workspace
- Event Hub
- Function App
- Service Bus
- SQL Managed Instance
- Windows VM jumpbox
- Route table or forced tunneling route association
- Azure Policy assignment

Some supporting subnet names and locals exist for future use, but these resources are not provisioned by the current root module as-is.
