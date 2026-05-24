<!-- BEGIN_TF_DOCS -->
# Terraform Reference

This file is generated from the root Terraform module by `terraform-docs`. Update the Terraform files, then regenerate this document instead of editing it by hand.

## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.0 |
| azurerm | >= 4.0 |
| random | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| azapi | 2.9.0 |
| azurerm | 4.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| acr | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/acr | main |
| adf_basic | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/adf | main |
| aks | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/aks | main |
| app_registration_appservice | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appregistration | main |
| app_service | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appservice | main |
| app_service_plan | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appserviceplan | main |
| automation_account | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/automationaccount | main |
| azure_ai_search | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/azure_ai_search | main |
| azure_ai_service | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/azure_ai_service | main |
| hub_virtual_network | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/vnet | main |
| keyvault | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/keyvault | main |
| linux_vm_basic | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/linuxvm | main |
| log_analytics | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/loganalytics | main |
| mg_landingzone | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups | main |
| mg_landingzone_children | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups | main |
| mg_platform | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups | main |
| mg_platform_children | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups | main |
| mg_sandboxes | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups | main |
| network_security_group | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/nsg | main |
| openai | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/openai | main |
| private_dns | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/private_dns | main |
| resource_group | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/rg | main |
| spoke_virtual_network | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/vnet | main |
| sqldb | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/sqldb | main |
| storage_account | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/storageaccount | main |
| subscription_vending | git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/subscription_vending | main |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.automation_ari_runtime_package](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.shared_storage_container](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.shared_storage_container_immutability_policy](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_update_resource.storage_account_blob_service](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_automation_job_schedule.automation_ari](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.automation_ari](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_runtime_environment.automation_ari](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runtime_environment) | resource |
| [azurerm_automation_schedule.automation_ari](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_key_vault_secret.linux_vm_admin_override](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.automation_account_key_vault_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.automation_account_storage_blob_data_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.linux_vm_app_service_website_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_container.automation_ari](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet_network_security_group_association.spoke_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network_peering.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_cognitive_account.azure_ai_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/cognitive_account) | data source |
| [azurerm_cognitive_account.openai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/cognitive_account) | data source |
| [azurerm_data_factory.adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/data_factory) | data source |
| [azurerm_key_vault.landingzone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault.sql_iac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_cluster) | data source |
| [azurerm_linux_web_app.app_service_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/linux_web_app) | data source |
| [azurerm_mssql_database.sqldb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_database) | data source |
| [azurerm_mssql_server.sqldb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/mssql_server) | data source |
| [azurerm_resource_group.landingzone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_search_service.azure_ai_search](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/search_service) | data source |
| [azurerm_storage_account.landingzone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_windows_web_app.app_service_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/windows_web_app) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acr_admin_enabled | Whether the ACR admin user is enabled. | `bool` | `false` | no |
| acr_anonymous_pull_enabled | Whether anonymous pull access is enabled for ACR. | `bool` | `false` | no |
| acr_customer_managed_key_id | Optional Key Vault key ID used to encrypt ACR. | `string` | `null` | no |
| acr_customer_managed_key_identity_client_id | Optional user-assigned identity client ID used with the ACR customer-managed key. | `string` | `null` | no |
| acr_data_endpoint_enabled | Whether dedicated ACR data endpoints are enabled. | `bool` | `false` | no |
| acr_diagnostic_log_categories | Diagnostic log categories to enable for ACR. | `list(string)` | <pre>[<br>  "ContainerRegistryRepositoryEvents",<br>  "ContainerRegistryLoginEvents"<br>]</pre> | no |
| acr_diagnostic_metric_categories | Diagnostic metric categories to enable for ACR. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| acr_enable_diagnostics | Whether to send ACR diagnostics to the shared Log Analytics workspace. | `bool` | `false` | no |
| acr_enable_network_rule_set | Whether to configure ACR network rules. | `bool` | `false` | no |
| acr_enable_private_endpoint | Whether to create a private endpoint for ACR. | `bool` | `false` | no |
| acr_export_policy_enabled | Whether the ACR export policy is enabled. | `bool` | `true` | no |
| acr_georeplications | Optional ACR georeplication locations. | <pre>list(object({<br>    location                  = string<br>    regional_endpoint_enabled = optional(bool, true)<br>    zone_redundancy_enabled   = optional(bool, false)<br>    tags                      = optional(map(string), {})<br>  }))</pre> | `[]` | no |
| acr_identity_ids | User-assigned managed identity IDs for ACR when acr_identity_type includes UserAssigned. | `list(string)` | `[]` | no |
| acr_identity_type | Managed identity type for ACR. | `string` | `"None"` | no |
| acr_managed_identity_role_assignments | Role assignments to apply to the ACR system-assigned managed identity. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>  }))</pre> | `{}` | no |
| acr_name | Optional base name override for the Azure Container Registry. The ACR module adds the acr prefix, region, environment, and numeric suffix. | `string` | `""` | no |
| acr_network_rule_bypass_option | Bypass option for the ACR network rule set. | `string` | `"AzureServices"` | no |
| acr_network_rule_default_action | Default action for the ACR network rule set. | `string` | `"Deny"` | no |
| acr_network_rule_ip_rules | Optional public IP CIDR ranges allowed by ACR network rules. | `list(string)` | `[]` | no |
| acr_private_dns_zone_id | Optional private DNS zone ID for the ACR private endpoint. Leave empty to use privatelink.azurecr.io from the landing zone private DNS module when present. | `string` | `""` | no |
| acr_private_dns_zone_name | Optional existing private DNS zone name used for ACR private endpoint lookup when acr_private_dns_zone_id is not set. | `string` | `""` | no |
| acr_private_dns_zone_resource_group_name | Optional resource group containing acr_private_dns_zone_name. | `string` | `""` | no |
| acr_public_network_access_enabled | Whether public network access is enabled for ACR. | `bool` | `false` | no |
| acr_quarantine_policy_enabled | Whether the ACR quarantine policy is enabled. | `bool` | `false` | no |
| acr_retention_policy_in_days | Days to retain untagged manifests before purge. Supported only on Premium SKU. | `number` | `null` | no |
| acr_sku | SKU for the Azure Container Registry. | `string` | `"Premium"` | no |
| acr_trust_policy_enabled | Whether the ACR trust policy is enabled. | `bool` | `false` | no |
| acr_zone_redundancy_enabled | Whether zone redundancy is enabled for the primary ACR registry. | `bool` | `false` | no |
| adf_analytics_destination_type | Log Analytics destination type for ADF diagnostic settings. | `string` | `"Dedicated"` | no |
| adf_cleanup_enabled | Whether ADF data flow clusters are cleaned up after runs. | `bool` | `true` | no |
| adf_compute_type | Compute type for the default Azure Integration Runtime data flow cluster. | `string` | `"General"` | no |
| adf_core_count | Core count for the default Azure Integration Runtime data flow cluster. | `number` | `8` | no |
| adf_default_integration_runtime_name | Optional override for the default Azure Integration Runtime name inside Data Factory. | `string` | `null` | no |
| adf_diagnostics_name | Optional override for the Azure Monitor diagnostic settings name used by the ADF module. | `string` | `null` | no |
| adf_enable_diagnostics | Whether to send Azure Data Factory diagnostics to the shared Log Analytics workspace. | `bool` | `true` | no |
| adf_enable_private_endpoint | Whether to create the Azure Data Factory control-plane private endpoint. | `bool` | `false` | no |
| adf_global_parameters | Optional Data Factory global parameters. | <pre>list(object({<br>    name  = string<br>    type  = optional(string, "String")<br>    value = string<br>  }))</pre> | `[]` | no |
| adf_managed_private_endpoints | Optional managed private endpoints created from Azure Data Factory. | <pre>set(object({<br>    name               = string<br>    target_resource_id = string<br>    subresource_name   = string<br>  }))</pre> | `[]` | no |
| adf_managed_virtual_network_enabled | Whether to enable the managed virtual network for Azure Data Factory. | `bool` | `true` | no |
| adf_name | Optional override for the Azure Data Factory name. | `string` | `""` | no |
| adf_permissions | Optional Azure Data Factory resource-level permissions in the module's expected object_id/role shape. | `list(map(string))` | `[]` | no |
| adf_private_dns_zone_id | Optional existing private DNS zone ID for privatelink.datafactory.azure.net. | `string` | `""` | no |
| adf_private_dns_zone_name | Private DNS zone name used for Azure Data Factory control-plane private endpoint resolution. | `string` | `"privatelink.datafactory.azure.net"` | no |
| adf_private_dns_zone_resource_group_name | Resource group containing the existing Azure Data Factory private DNS zone when an explicit zone ID is not provided. | `string` | `""` | no |
| adf_public_network_enabled | Whether the Azure Data Factory control plane is exposed to the public network. | `bool` | `false` | no |
| adf_self_hosted_integration_runtime_enabled | Whether to enable the self-hosted integration runtime path for the ADF module. | `bool` | `false` | no |
| adf_shir_name | Optional override for the SHIR name when self-hosted integration runtime is enabled. | `string` | `null` | no |
| adf_time_to_live_min | Time-to-live for the default Azure Integration Runtime data flow cluster. | `number` | `15` | no |
| adf_virtual_network_enabled | Whether the default Azure Integration Runtime uses managed virtual network execution. | `bool` | `true` | no |
| adf_vsts_configuration | Azure DevOps repository configuration for Data Factory source control integration. | <pre>object({<br>    account_name         = string<br>    project_name         = string<br>    repository_name      = string<br>    branch_name          = string<br>    root_folder          = string<br>    tenant_id            = string<br>    collaboration_branch = optional(string)<br>  })</pre> | <pre>{<br>  "account_name": "CCOE-Azure",<br>  "branch_name": "adf_publish",<br>  "collaboration_branch": "main",<br>  "project_name": "CCoE-Infra-IaC",<br>  "repository_name": "",<br>  "root_folder": "/",<br>  "tenant_id": "b0f3630d-e5de-4172-b492-0cf5cd387a41"<br>}</pre> | no |
| aks_app_admin_group | List of Microsoft Entra group display names or object IDs that should receive AKS admin access. | `list(string)` | `[]` | no |
| aks_app_user_group | List of Microsoft Entra group display names or object IDs that should receive Reader access on the AKS cluster resource. | `list(string)` | `[]` | no |
| aks_automatic_upgrade_channel | AKS automatic upgrade channel. | `string` | `"patch"` | no |
| aks_azure_rbac_enabled | Whether Azure RBAC for Kubernetes Authorization is enabled. | `bool` | `true` | no |
| aks_default_node_pool | AKS default node pool configuration. | <pre>object({<br>    name                         = optional(string, "system")<br>    vm_size                      = optional(string, "Standard_D4s_v5")<br>    node_count                   = optional(number, 1)<br>    enable_auto_scaling          = optional(bool, false)<br>    min_count                    = optional(number)<br>    max_count                    = optional(number)<br>    zones                        = optional(list(string), [])<br>    os_disk_size_gb              = optional(number, 128)<br>    max_pods                     = optional(number)<br>    vnet_subnet_id               = optional(string)<br>    only_critical_addons_enabled = optional(bool, false)<br>    orchestrator_version         = optional(string)<br>    os_sku                       = optional(string, "Ubuntu")<br>    type                         = optional(string, "VirtualMachineScaleSets")<br>    upgrade_settings = optional(object({<br>      max_surge                     = optional(string)<br>      drain_timeout_in_minutes      = optional(number)<br>      node_soak_duration_in_minutes = optional(number)<br>    }))<br>  })</pre> | `{}` | no |
| aks_diagnostic_log_categories | AKS diagnostic log categories to enable. | `list(string)` | `[]` | no |
| aks_diagnostic_metric_categories | AKS diagnostic metric categories to enable. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| aks_dns_prefix | Optional override for the AKS DNS prefix. | `string` | `""` | no |
| aks_enable_diagnostics | Whether to enable diagnostics for AKS. | `bool` | `false` | no |
| aks_kubernetes_version | Optional Kubernetes version for AKS. | `string` | `null` | no |
| aks_local_account_disabled | Whether local AKS admin accounts are disabled. | `bool` | `true` | no |
| aks_log_analytics_workspace_id | Optional override for the Log Analytics workspace resource ID used by AKS diagnostics. | `string` | `""` | no |
| aks_name | Optional override for the AKS cluster name. | `string` | `""` | no |
| aks_network_profile | AKS network profile configuration. | <pre>object({<br>    network_plugin      = optional(string, "azure")<br>    network_plugin_mode = optional(string)<br>    network_policy      = optional(string)<br>    service_cidr        = optional(string)<br>    dns_service_ip      = optional(string)<br>    load_balancer_sku   = optional(string, "standard")<br>    outbound_type       = optional(string, "loadBalancer")<br>  })</pre> | `{}` | no |
| aks_oidc_issuer_enabled | Whether the AKS OIDC issuer is enabled. | `bool` | `true` | no |
| aks_private_cluster_enabled | Whether the AKS API server is private. | `bool` | `true` | no |
| aks_private_dns_zone_id | Optional private DNS zone resource ID for AKS. | `string` | `""` | no |
| aks_private_dns_zone_name | Optional private DNS zone name for AKS lookup. | `string` | `""` | no |
| aks_private_dns_zone_resource_group_name | Optional resource group containing aks_private_dns_zone_name. | `string` | `""` | no |
| aks_role_based_access_control_enabled | Whether Kubernetes RBAC is enabled. | `bool` | `true` | no |
| aks_sku_tier | AKS SKU tier. | `string` | `"Free"` | no |
| aks_subnet_prefixes | Address prefixes for the AKS subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.74.0/24"<br>]</pre> | no |
| aks_tags | A mapping of tags to assign to the AKS cluster. | `map(string)` | `{}` | no |
| aks_terraform_execution_aks_role | Optional AKS Kubernetes RBAC role to assign to the current Terraform execution identity. | `string` | `"Azure Kubernetes Service RBAC Cluster Admin"` | no |
| aks_workload_identity_enabled | Whether AKS Workload Identity is enabled. | `bool` | `true` | no |
| allowed_policy_locations | Allowed Azure regions used by the sample allowed locations policy. | `list(string)` | <pre>[<br>  "eastus",<br>  "canadaeast"<br>]</pre> | no |
| app_admin_group | Optional Entra groups or object IDs with Contributor-style access on landing zone resources. | `list(string)` | `[]` | no |
| app_registration_create_client_secret | Whether to create and store an app registration client secret for the App Service. | `bool` | `true` | no |
| app_registration_display_name | Optional display name override for the App Service app registration. | `string` | `null` | no |
| app_registration_web_redirect_uris | Optional explicit redirect URIs for the App Service app registration. | `list(string)` | `[]` | no |
| app_service_allow_anonymous | Whether Easy Auth should allow anonymous requests. | `bool` | `true` | no |
| app_service_app_secret_key | Application secret key setting for the sample app. Replace before production use. | `string` | `"replace-with-a-random-secret"` | no |
| app_service_app_settings | Additional App Service app settings merged with the module defaults. | `map(string)` | `{}` | no |
| app_service_auth_mode | Authentication mode for the App Service: none, easy_auth, msal, or both. | `string` | `"both"` | no |
| app_service_dotnet_version | The .NET runtime version configured on the Windows App Service. | `string` | `"v8.0"` | no |
| app_service_enable_private_endpoint | n/a | `bool` | `false` | no |
| app_service_ip_restriction_default_action | Default action for App Service site access traffic that does not match an IP restriction rule. | `string` | `"Deny"` | no |
| app_service_ip_restrictions | Site access restrictions for the App Service public endpoint. | <pre>list(object({<br>    action      = optional(string, "Allow")<br>    ip_address  = optional(string)<br>    name        = string<br>    priority    = number<br>    service_tag = optional(string)<br><br>    headers = optional(object({<br>      x_forwarded_for   = optional(list(string))<br>      x_forwarded_host  = optional(list(string))<br>      x_azure_fdid      = optional(list(string))<br>      x_fd_health_probe = optional(list(string))<br>    }))<br>  }))</pre> | `[]` | no |
| app_service_kind | The App Service operating system kind. | `string` | `"Windows"` | no |
| app_service_node_version | The Node.js runtime version configured on the App Service when appservice_stack is node. | `string` | `"24-lts"` | no |
| app_service_plan_autoscale_cpu_threshold_scale_down | CPU threshold percentage that triggers App Service Plan scale in. | `number` | `25` | no |
| app_service_plan_autoscale_cpu_threshold_scale_up | CPU threshold percentage that triggers App Service Plan scale out. | `number` | `75` | no |
| app_service_plan_autoscale_default_capacity | Default App Service Plan autoscale instance count. | `number` | `1` | no |
| app_service_plan_autoscale_max_capacity | Maximum App Service Plan autoscale instance count. | `number` | `3` | no |
| app_service_plan_autoscale_min_capacity | Minimum App Service Plan autoscale instance count. | `number` | `1` | no |
| app_service_plan_autoscale_scale_down_increment | Number of App Service Plan instances to remove when scaling in. | `number` | `1` | no |
| app_service_plan_autoscale_scale_up_increment | Number of App Service Plan instances to add when scaling out. | `number` | `1` | no |
| app_service_plan_enable_autoscale | Whether to enable autoscale for the App Service Plan. | `bool` | `false` | no |
| app_service_plan_enable_diagnostics | Whether to send App Service Plan diagnostics to Log Analytics. | `bool` | `true` | no |
| app_service_plan_os_type | Operating system type for the App Service Plan. | `string` | `"Windows"` | no |
| app_service_plan_sku_name | SKU name for the App Service Plan. | `string` | `"S1"` | no |
| app_service_public_network_access_enabled | Whether public network access is enabled for the App Service. | `bool` | `true` | no |
| app_service_python_version | The Python runtime version configured on the App Service when appservice_stack is python. | `string` | `"3.14"` | no |
| app_service_scmIpSecurityRestrictionsUseMain | Optional App Service property override for scmIpSecurityRestrictionsUseMain. When null, app_service_scm_use_main_ip_restriction is used. | `bool` | `null` | no |
| app_service_scm_basic_auth_publishing_credentials_enabled | Whether SCM basic authentication publishing credentials are enabled. | `bool` | `true` | no |
| app_service_scm_ip_restriction_default_action | Default action for Kudu/SCM endpoint traffic that does not match an IP restriction rule. | `string` | `"Deny"` | no |
| app_service_scm_ip_restrictions | Kudu/SCM endpoint access restrictions for the App Service. | <pre>list(object({<br>    action                    = optional(string, "Allow")<br>    description               = optional(string)<br>    ip_address                = optional(string)<br>    name                      = string<br>    priority                  = number<br>    service_tag               = optional(string)<br>    virtual_network_subnet_id = optional(string)<br><br>    headers = optional(object({<br>      x_forwarded_for   = optional(list(string))<br>      x_forwarded_host  = optional(list(string))<br>      x_azure_fdid      = optional(list(string))<br>      x_fd_health_probe = optional(list(string))<br>    }))<br>  }))</pre> | `[]` | no |
| app_service_scm_use_main_ip_restriction | Whether the Kudu/SCM endpoint should reuse the main App Service IP restrictions. | `bool` | `false` | no |
| app_service_unauthenticated_action | Optional Easy Auth unauthenticated action override. | `string` | `"AllowAnonymous"` | no |
| app_service_vnet_integration_enabled | Whether to integrate the App Service with the spoke application subnet. | `bool` | `false` | no |
| app_service_vnet_route_all_enabled | Whether App Service VNet integration routes all outbound traffic through the VNet. | `bool` | `false` | no |
| app_service_webdeploy_publish_basic_authentication_enabled | Whether WebDeploy basic publishing authentication is enabled. | `bool` | `true` | no |
| app_services | App Service instances to provision. Toggle each stack with enabled. | <pre>map(object({<br>    enabled           = bool<br>    stack             = string<br>    kind              = string<br>    plan_os_type      = string<br>    sku_name          = string<br>    deployment_method = optional(string, "run_from_package")<br>    use_32_bit_worker = optional(bool)<br>    startup_command   = optional(string)<br>    dotnet_version    = optional(string)<br>    node_version      = optional(string)<br>    python_version    = optional(string)<br>    app_settings      = optional(map(string), {})<br>    # Deprecated: prefer deployment_method. Retained only for backward compatibility<br>    # when older callers omit deployment_method.<br>    deployment_center_enabled                  = optional(bool, false)<br>    deployment_center_azure_repos_organization = optional(string)<br>    deployment_center_azure_repos_project      = optional(string)<br>    deployment_center_azure_repos_repository   = optional(string)<br>    deployment_center_azure_repos_branch       = optional(string, "main")<br>    deployment_center_use_manual_integration   = optional(bool, true)<br>  }))</pre> | <pre>{<br>  "dotnet": {<br>    "deployment_center_azure_repos_branch": "main",<br>    "deployment_center_use_manual_integration": true,<br>    "deployment_method": "run_from_package",<br>    "dotnet_version": "v8.0",<br>    "enabled": true,<br>    "kind": "Windows",<br>    "plan_os_type": "Windows",<br>    "sku_name": "S1",<br>    "stack": "dotnet",<br>    "startup_command": null,<br>    "use_32_bit_worker": null<br>  },<br>  "node": {<br>    "app_settings": {<br>      "WEBSITE_NODE_DEFAULT_VERSION": "~24"<br>    },<br>    "deployment_center_azure_repos_branch": "main",<br>    "deployment_center_use_manual_integration": true,<br>    "deployment_method": "run_from_package",<br>    "enabled": true,<br>    "kind": "Linux",<br>    "node_version": "24-lts",<br>    "plan_os_type": "Linux",<br>    "sku_name": "S1",<br>    "stack": "node",<br>    "startup_command": null,<br>    "use_32_bit_worker": null<br>  },<br>  "python": {<br>    "deployment_center_azure_repos_branch": "main",<br>    "deployment_center_use_manual_integration": true,<br>    "deployment_method": "run_from_package",<br>    "enabled": false,<br>    "kind": "Linux",<br>    "plan_os_type": "Linux",<br>    "python_version": "3.14",<br>    "sku_name": "S1",<br>    "stack": "python",<br>    "startup_command": null,<br>    "use_32_bit_worker": null<br>  }<br>}</pre> | no |
| app_subnet_prefixes | Address prefixes for the application subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.70.0/24"<br>]</pre> | no |
| app_user_group | Optional Entra groups or object IDs with Reader-style access on landing zone resources. | `list(string)` | `[]` | no |
| appservice_stack | Application runtime stack used by the App Service module. | `string` | `"dotnet"` | no |
| automation_accounts | Automation Account instances to provision. Toggle each account with enabled. | <pre>map(object({<br>    enabled                         = bool<br>    name                            = optional(string)<br>    sku_name                        = optional(string, "Basic")<br>    local_auth_enabled              = optional(bool, false)<br>    public_access_enabled           = optional(bool, true)<br>    system_managed_identity_enabled = optional(bool, true)<br>    app_admin_group                 = optional(list(string), [])<br>    app_user_group                  = optional(list(string), [])<br>    managed_identity_role_assignments = optional(map(object({<br>      scope                = string<br>      role_definition_name = optional(string)<br>      role_definition_id   = optional(string)<br>    })), {})<br>    private_endpoint_enabled                     = optional(bool, false)<br>    private_endpoint_subresource_name            = optional(string, "Webhook")<br>    enable_webhook_private_endpoint              = optional(bool)<br>    enable_hrw_private_endpoint                  = optional(bool)<br>    private_endpoint_subnet_id                   = optional(string, "")<br>    private_endpoint_subnet_name                 = optional(string)<br>    private_endpoint_vnet_name                   = optional(string)<br>    private_endpoint_network_resource_group_name = optional(string)<br>    private_dns_zone_id                          = optional(string, "")<br>    enable_diagnostics                           = optional(bool, true)<br>    diagnostic_log_categories                    = optional(list(string), ["JobLogs", "JobStreams", "AuditEvent", "DscNodeStatus"])<br>    diagnostic_metric_categories                 = optional(list(string), ["AllMetrics"])<br>    tags                                         = optional(map(string), {})<br>  }))</pre> | <pre>{<br>  "default": {<br>    "app_admin_group": [],<br>    "app_user_group": [],<br>    "diagnostic_log_categories": [<br>      "JobLogs",<br>      "JobStreams",<br>      "AuditEvent",<br>      "DscNodeStatus"<br>    ],<br>    "diagnostic_metric_categories": [<br>      "AllMetrics"<br>    ],<br>    "enable_diagnostics": true,<br>    "enable_hrw_private_endpoint": null,<br>    "enable_webhook_private_endpoint": null,<br>    "enabled": false,<br>    "local_auth_enabled": false,<br>    "managed_identity_role_assignments": {},<br>    "name": null,<br>    "private_dns_zone_id": "",<br>    "private_endpoint_enabled": false,<br>    "private_endpoint_network_resource_group_name": null,<br>    "private_endpoint_subnet_id": "",<br>    "private_endpoint_subnet_name": null,<br>    "private_endpoint_subresource_name": "Webhook",<br>    "private_endpoint_vnet_name": null,<br>    "public_access_enabled": true,<br>    "sku_name": "Basic",<br>    "system_managed_identity_enabled": true,<br>    "tags": {}<br>  }<br>}</pre> | no |
| automation_ari_workloads | Azure Resource Inventory (ARI) workloads to attach to provisioned Automation Accounts. | <pre>map(object({<br>    enabled                              = bool<br>    automation_account_key               = string<br>    storage_container_name               = optional(string, "ari")<br>    report_name                          = optional(string, "AZURE")<br>    report_dir                           = optional(string, "C:\\AzureResourceInventory")<br>    ari_lite_mode                        = optional(bool, false)<br>    ari_diagram_full_environment_enabled = optional(bool, true)<br>    ari_security_center_enabled          = optional(bool, true)<br>    runbook_name                         = optional(string, "ARI_Runbook")<br>    runtime_environment_name             = optional(string, "PowerShell-7.4-Env")<br>    runbook_template_path                = optional(string, "runbooks/ari.ps1.tftpl")<br>    runtime_packages                     = optional(map(string), {})<br>    schedule_enabled                     = optional(bool, true)<br>    schedule_name                        = optional(string, "Azure Inventory Collection - daily")<br>    schedule_description                 = optional(string, "Daily schedule for the ARI runbook.")<br>    schedule_frequency                   = optional(string, "Day")<br>    schedule_interval                    = optional(number, 1)<br>    schedule_timezone                    = optional(string, "America/Toronto")<br>    schedule_start_time                  = optional(string)<br>    runbook_log_verbose                  = optional(bool, true)<br>    runbook_log_progress                 = optional(bool, true)<br>    enable_job_failure_alert             = optional(bool, true)<br>    job_failure_alert_name               = optional(string)<br>    job_failure_severity                 = optional(number, 2)<br>    enable_long_running_alert            = optional(bool, true)<br>    long_running_alert_name              = optional(string)<br>    long_running_severity                = optional(number, 3)<br>    long_running_threshold_minutes       = optional(number, 90)<br>    alert_evaluation_frequency           = optional(string, "PT15M")<br>    alert_window_duration                = optional(string, "PT15M")<br>    monitor_action_group_ids             = optional(list(string), [])<br>    tags                                 = optional(map(string), {})<br>  }))</pre> | <pre>{<br>  "default": {<br>    "alert_evaluation_frequency": "PT15M",<br>    "alert_window_duration": "PT15M",<br>    "ari_diagram_full_environment_enabled": true,<br>    "ari_lite_mode": false,<br>    "ari_security_center_enabled": true,<br>    "automation_account_key": "default",<br>    "enable_job_failure_alert": true,<br>    "enable_long_running_alert": true,<br>    "enabled": false,<br>    "job_failure_alert_name": null,<br>    "job_failure_severity": 2,<br>    "long_running_alert_name": null,<br>    "long_running_severity": 3,<br>    "long_running_threshold_minutes": 90,<br>    "monitor_action_group_ids": [],<br>    "report_dir": "C:\\AzureResourceInventory",<br>    "report_name": "AZURE",<br>    "runbook_log_progress": true,<br>    "runbook_log_verbose": true,<br>    "runbook_name": "ARI_Runbook",<br>    "runbook_template_path": "runbooks/ari.ps1.tftpl",<br>    "runtime_environment_name": "PowerShell-7.4-Env",<br>    "runtime_packages": {},<br>    "schedule_description": "Daily schedule for the ARI runbook.",<br>    "schedule_enabled": true,<br>    "schedule_frequency": "Day",<br>    "schedule_interval": 1,<br>    "schedule_name": "Azure Inventory Collection - daily",<br>    "schedule_start_time": null,<br>    "schedule_timezone": "America/Toronto",<br>    "storage_container_name": "ari",<br>    "tags": {}<br>  }<br>}</pre> | no |
| azure_ai_search_allowed_ips | Optional list of public IP ranges allowed to access the Azure AI Search service. | `list(string)` | `[]` | no |
| azure_ai_search_authentication_failure_mode | Optional authentication failure mode for the Azure AI Search service. | `string` | `""` | no |
| azure_ai_search_customer_managed_key_enforcement_enabled | Whether customer-managed key enforcement is enabled on the Azure AI Search service. | `bool` | `false` | no |
| azure_ai_search_diagnostic_log_categories | Diagnostic log categories to enable for Azure AI Search. | `list(string)` | `[]` | no |
| azure_ai_search_diagnostic_metric_categories | Diagnostic metric categories to enable for Azure AI Search. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| azure_ai_search_enable_diagnostics | Whether to send Azure AI Search diagnostics to the shared Log Analytics workspace. | `bool` | `false` | no |
| azure_ai_search_hosting_mode | Hosting mode for the Azure AI Search service. | `string` | `"default"` | no |
| azure_ai_search_identity | Optional managed identity configuration for the Azure AI Search service. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| azure_ai_search_local_authentication_enabled | Whether API-key based local authentication is enabled on the Azure AI Search service. | `bool` | `true` | no |
| azure_ai_search_name | Optional override for the Azure AI Search service name. | `string` | `""` | no |
| azure_ai_search_network_rule_bypass_option | Optional network rule bypass option for the Azure AI Search service. | `string` | `"None"` | no |
| azure_ai_search_partition_count | Partition count for the Azure AI Search service. | `number` | `1` | no |
| azure_ai_search_private_dns_zone_id | Optional override private DNS zone ID for the Azure AI Search private endpoint. Leave empty to use the landing zone private DNS module when privatelink.search.windows.net is present. | `string` | `""` | no |
| azure_ai_search_public_network_access_enabled | Whether public network access is enabled on the Azure AI Search service. | `bool` | `true` | no |
| azure_ai_search_replica_count | Replica count for the Azure AI Search service. | `number` | `1` | no |
| azure_ai_search_semantic_search_sku | Optional semantic ranker SKU for the Azure AI Search service. | `string` | `""` | no |
| azure_ai_search_sku | SKU for the Azure AI Search service. | `string` | `"standard"` | no |
| azure_ai_service_custom_subdomain_name | Optional custom subdomain name for the Azure AI Services account. | `string` | `""` | no |
| azure_ai_service_customer_managed_key | Optional customer-managed key configuration for the Azure AI Services account. | <pre>object({<br>    key_vault_key_id   = string<br>    identity_client_id = optional(string)<br>  })</pre> | `null` | no |
| azure_ai_service_diagnostic_log_categories | Diagnostic log categories to enable for Azure AI Services. | `list(string)` | `[]` | no |
| azure_ai_service_diagnostic_metric_categories | Diagnostic metric categories to enable for Azure AI Services. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| azure_ai_service_dynamic_throttling_enabled | Whether dynamic throttling is enabled for the Azure AI Services account. | `bool` | `false` | no |
| azure_ai_service_enable_diagnostics | Whether to send Azure AI Services diagnostics to the shared Log Analytics workspace. | `bool` | `false` | no |
| azure_ai_service_fqdns | Optional list of outbound FQDNs for the Azure AI Services account. | `list(string)` | `[]` | no |
| azure_ai_service_identity | Optional managed identity configuration for the Azure AI Services account. | <pre>object({<br>    type         = string<br>    identity_ids = optional(set(string))<br>  })</pre> | `null` | no |
| azure_ai_service_local_auth_enabled | Whether local auth keys are enabled on the Azure AI Services account. | `bool` | `true` | no |
| azure_ai_service_name | Optional override for the Azure AI Services account name. | `string` | `""` | no |
| azure_ai_service_network_acls | Optional network ACL configuration for the Azure AI Services account. | <pre>object({<br>    default_action = string<br>    bypass         = optional(string)<br>    ip_rules       = optional(set(string))<br>    virtual_network_rules = optional(set(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool)<br>    })))<br>  })</pre> | `null` | no |
| azure_ai_service_outbound_network_access_restricted | Whether outbound network access is restricted on the Azure AI Services account. | `bool` | `false` | no |
| azure_ai_service_private_dns_zone_id | Optional override private DNS zone ID for the Azure AI Services private endpoint. Leave empty to use the landing zone private DNS module when privatelink.cognitiveservices.azure.com is present. | `string` | `""` | no |
| azure_ai_service_project_management_enabled | Whether project management is enabled for the Azure AI Services account. | `bool` | `false` | no |
| azure_ai_service_public_network_access_enabled | Whether public network access is enabled on the Azure AI Services account. | `bool` | `true` | no |
| azure_ai_service_sku_name | SKU name for the Azure AI Services account. | `string` | `"S0"` | no |
| azure_ai_service_storage | Optional storage account attachments for the Azure AI Services account. | <pre>list(object({<br>    storage_account_id = string<br>    identity_client_id = optional(string)<br>  }))</pre> | `[]` | no |
| bastion_resource_group_name | Resource group containing bastion_resource_name. | `string` | `""` | no |
| bastion_resource_name | Optional Bastion host name that receives Network Contributor RBAC for linux_vm_app_admin_group and linux_vm_app_user_group. | `string` | `""` | no |
| billing_scope_id | Billing scope ID when creating a new subscription alias. | `string` | `""` | no |
| common_tags | n/a | `map(any)` | <pre>{<br>  "AppSupport Team": "CCOE",<br>  "Application Name": "CCOE INFRA IAC",<br>  "Application Owner": "CCOE",<br>  "Approval Group": "CCOE",<br>  "Business Owner": "CCOE",<br>  "Infra Availability Classification": "Bronze",<br>  "InfraSupport Team": "CCOE",<br>  "Maintenance Window": "CCOE",<br>  "Project Name": "CCOE INFRA IAC",<br>  "Project Number": "N/A",<br>  "RPO-RTO": "48H/24H",<br>  "Run Cost(Approved Run Budget)-USD": "100"<br>}</pre> | no |
| connectivity_subscription_id | Azure subscription ID used by the aliased azurerm.connectivity provider. | `string` | `"d3927a5b-0ea7-40e1-bbb5-d3ba34515fb0"` | no |
| databricks_private_subnet_prefixes | Address prefixes for the Databricks private subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.73.0/24"<br>]</pre> | no |
| databricks_public_subnet_prefixes | Address prefixes for the Databricks public subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.72.0/24"<br>]</pre> | no |
| enable_acr | Enable the Azure Container Registry module in the landing zone. | `bool` | `false` | no |
| enable_adf | Enable the Azure Data Factory module in the landing zone. | `bool` | `false` | no |
| enable_aks | Whether to deploy the AKS module. | `bool` | `false` | no |
| enable_app_registration_for_appservice | Whether to create an Entra app registration for the App Service. | `bool` | `true` | no |
| enable_azure_ai_search | Enable the Azure AI Search module in the landing zone. | `bool` | `false` | no |
| enable_azure_ai_search_private_endpoint | Whether to create a private endpoint for the Azure AI Search service. | `bool` | `false` | no |
| enable_azure_ai_service | Enable the Azure AI Services module in the landing zone. | `bool` | `false` | no |
| enable_azure_ai_service_private_endpoint | Whether to create a private endpoint for the Azure AI Services account. | `bool` | `false` | no |
| enable_linux_vm | Whether to provision the Linux VM jumpbox module and its related root role assignments. | `bool` | `true` | no |
| enable_management_group | Whether to create a management group in the example. | `bool` | `false` | no |
| enable_openai | Enable the Azure OpenAI module in the landing zone. | `bool` | `false` | no |
| enable_openai_private_endpoint | Whether to create a private endpoint for the Azure OpenAI account. | `bool` | `false` | no |
| enable_sqldb | Whether to deploy the Azure SQL Database module. | `bool` | `false` | no |
| enable_subscription_bootstrap | Whether to use subscription_vending in the example. | `bool` | `false` | no |
| environment | Environment suffix used in generated names. | `string` | `"dev"` | no |
| existing_subscription_id | Existing subscription resource ID used when bootstrapping an existing subscription. | `string` | `""` | no |
| features | Optional high-level feature switches. Known keys include enable_management_group, enable_subscription_bootstrap, enable_private_dns, enable_adf, enable_azure_ai_search, enable_azure_ai_service, enable_openai, enable_acr, enable_app_services, enable_app_registration_for_appservice, enable_automation_accounts, enable_automation_ari_workloads, enable_linux_vm, enable_aks, and enable_sqldb. Unspecified keys fall back to the existing individual variables. | `map(bool)` | `{}` | no |
| firewall_name | Optional override for the Azure Firewall name. | `string` | `""` | no |
| firewall_sku_tier | Azure Firewall SKU tier. | `string` | `"Standard"` | no |
| firewall_subnet_prefixes | Address prefixes for AzureFirewallSubnet in the hub VNet. | `list(string)` | <pre>[<br>  "10.167.33.64/26"<br>]</pre> | no |
| hierarchy_subscriptions | Optional subscription hierarchy entries. By default the map key is the target management group key; set management_group_key to place multiple subscriptions in the same management group. | <pre>map(object({<br>    subscription_name          = string<br>    existing_subscription_id   = string<br>    management_group_key       = optional(string, "")<br>    subscription_alias_enabled = optional(bool, false)<br>    subscription_alias_name    = optional(string, "")<br>    billing_scope_id           = optional(string, "")<br>  }))</pre> | <pre>{<br>  "landingzone": {<br>    "existing_subscription_id": "/subscriptions/00000000-0000-0000-0000-000000000013",<br>    "management_group_key": "landingzone",<br>    "subscription_name": "landingzone-dev"<br>  }<br>}</pre> | no |
| hub_address_space | Address space for the hub virtual network. | `list(string)` | <pre>[<br>  "10.167.32.0/20"<br>]</pre> | no |
| hub_vnet_name | Optional override for the hub virtual network name. | `string` | `""` | no |
| identity_subscription_id | Azure subscription ID used by the aliased azurerm.identity provider. | `string` | `"74c3c03d-217f-4138-b9a6-79145d37781a"` | no |
| jumpbox_public_network_enabled | Whether the example jumpbox VMs receive public IPs. | `bool` | `true` | no |
| jumpbox_subnet_prefixes | Address prefixes for the jumpbox subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.75.0/24"<br>]</pre> | no |
| jumpbox_windows_image_offer | Marketplace image offer passed to the winvm module for the example jumpbox. | `string` | `"WindowsServer"` | no |
| jumpbox_windows_image_publisher | Marketplace image publisher passed to the winvm module for the example jumpbox. | `string` | `"MicrosoftWindowsServer"` | no |
| jumpbox_windows_image_sku | Marketplace image SKU passed to the winvm module for the example jumpbox. | `string` | `"2022-Datacenter"` | no |
| jumpbox_windows_image_version | Marketplace image version passed to the winvm module for the example jumpbox. | `string` | `"latest"` | no |
| key_vault_name | Optional override for the landing zone Key Vault name. | `string` | `""` | no |
| landingzone_mg_display | Optional override for the management group display name. | `string` | `"Landingzone Dev"` | no |
| landingzone_mg_name | Optional override for the management group ID. | `string` | `"mg-landingzone-dev"` | no |
| linux_vm_admin_credentials_key_vault_id | Optional Key Vault resource ID to use specifically for Linux VM admin credential secrets. When set, this takes precedence over linux_vm_iac_kv_id for resolving azure-user, azure-password, and azureadmin-pubkey. | `string` | `""` | no |
| linux_vm_admin_password | Optional root-level admin password override for the Linux VM module. Leave empty to use the admin_password secret from linux_vm_iac_kv. | `string` | `""` | no |
| linux_vm_admin_password_secret_name | Optional Key Vault secret name containing the Linux VM admin password. | `string` | `""` | no |
| linux_vm_admin_ssh_key | Optional administrator SSH public key override passed to the Linux VM module. Leave empty to use the azureadmin-pubkey secret from linux_vm_iac_kv. | `string` | `""` | no |
| linux_vm_admin_ssh_key_secret_name | Optional Key Vault secret name containing the Linux VM admin SSH public key. | `string` | `""` | no |
| linux_vm_admin_username | Optional administrator username override passed to the Linux VM module. Leave empty to use the admin_username secret from linux_vm_iac_kv. | `string` | `""` | no |
| linux_vm_admin_username_secret_name | Optional Key Vault secret name containing the Linux VM admin username. | `string` | `""` | no |
| linux_vm_ado_runner_count | Number of Azure DevOps agents to register on each Linux runner VM. | `number` | `1` | no |
| linux_vm_app_admin_group | AD groups granted Contributor on the VM resource and sudo/admin access inside the Linux guest OS. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| linux_vm_app_env | Environment, such as prod, qa, dev, poc, test, or sbx. | `string` | `"prod"` | no |
| linux_vm_app_user_group | AD groups granted Reader on the VM resource and standard SSH access inside the Linux guest OS. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| linux_vm_common_tags | Common tags merged into all Linux VM module resources. | `map(any)` | `{}` | no |
| linux_vm_data_disk_size_gb | Optional additional data disk size in GB. Set to 0 to skip the extra disk. | `number` | `0` | no |
| linux_vm_datadog_api_key | Legacy Datadog API key retained for Linux VM module compatibility. | `string` | `"datadog_api_key"` | no |
| linux_vm_disable_password_authentication | Whether to disable password authentication for the Linux VM module. | `bool` | `false` | no |
| linux_vm_domain | AD domain used by the Linux VM bootstrap script when linux_vm_enable_domain_join = true. | `string` | `""` | no |
| linux_vm_domain_join_ou | Legacy domain join OU value retained for Linux VM module compatibility. Only relevant when linux_vm_enable_domain_join = true. | `string` | `"azure"` | no |
| linux_vm_domain_join_user | Domain join user in domain\username format, used only when linux_vm_enable_domain_join = true. | `string` | `""` | no |
| linux_vm_enable_domain_join | Whether the Linux VM module should attempt domain join during bootstrap. Default is false, which skips the domain-join secret lookup and keeps the VM off domain. | `bool` | `false` | no |
| linux_vm_enable_entra_ssh_login | Whether to enable Microsoft Entra ID SSH login on the Linux VMs. | `bool` | `false` | no |
| linux_vm_enable_linux_vm_extension | Whether to enable the optional storage-backed localization CustomScript VM extension for Linux VMs. | `bool` | `false` | no |
| linux_vm_enable_system_assigned_identity | Whether to enable a system-assigned managed identity on the Linux VMs. Required when linux_vm_enable_linux_vm_extension = true. | `bool` | `true` | no |
| linux_vm_iac_kv | Shared Key Vault name containing Linux VM secrets. | `string` | `""` | no |
| linux_vm_iac_kv_id | Shared Key Vault resource ID containing Linux VM secrets. | `string` | `""` | no |
| linux_vm_iac_rg | Resource group containing the shared IaC storage account and Key Vault. | `string` | `""` | no |
| linux_vm_iac_st | Shared storage account name containing bootstrap scripts. | `string` | `""` | no |
| linux_vm_iac_st_id | Shared storage account resource ID containing bootstrap scripts. | `string` | `""` | no |
| linux_vm_iac_st_primary_blob_endpoint | Primary blob endpoint for the shared storage account containing bootstrap scripts. | `string` | `""` | no |
| linux_vm_image_offer | Offer of the Linux VM image. | `string` | `"ubuntu-24_04-lts"` | no |
| linux_vm_image_publisher | Publisher of the Linux VM image. | `string` | `"Canonical"` | no |
| linux_vm_image_sku | SKU of the Linux VM image. | `string` | `"server"` | no |
| linux_vm_image_version | Version of the Linux VM image. | `string` | `"latest"` | no |
| linux_vm_localization_container_name | Blob container name in the shared IaC storage account that holds Linux VM localization scripts. | `string` | `"localization"` | no |
| linux_vm_localization_os_script_name | OS-level localization script blob name to download first when the optional Linux VM extension is enabled. | `string` | `"ubuntu.sh"` | no |
| linux_vm_location | The Azure region in which the Linux VM resources will be created. | `string` | `"canadacentral"` | no |
| linux_vm_public_network_enabled | Whether to create public IPs and NSGs for Linux VM SSH access. | `bool` | `false` | no |
| linux_vm_resource_group_name | Target resource group name for the Linux VM resources. | `string` | `""` | no |
| linux_vm_rg_tags | Module-specific tags merged with linux_vm_common_tags and applied to Linux VM module resources. | `map(any)` | `{}` | no |
| linux_vm_subnet_id | Optional subnet resource ID override for the Linux VM NICs. | `string` | `""` | no |
| linux_vm_subnet_name | Existing subnet name used for the Linux VM NICs. | `string` | `""` | no |
| linux_vm_upload_shared_localization_scripts | Whether to also upload shared OS localization scripts such as ubuntu.sh and redhat.sh to the localization container in addition to any per-VM scripts. | `bool` | `false` | no |
| linux_vm_vm_count | Number of Linux VMs to create. | `number` | `1` | no |
| linux_vm_vm_name | Base Linux VM name. Environment suffixes are appended by the module. | `string` | `""` | no |
| linux_vm_vm_size | Azure VM size for each Linux VM. | `string` | `"Standard_D4s_v3"` | no |
| linux_vm_vnet_id | Optional virtual network resource ID override for the Linux VM NICs. | `string` | `""` | no |
| linux_vm_vnet_name | Existing virtual network name used for the Linux VM NICs. | `string` | `""` | no |
| linux_vm_vnet_resource_group_name | Resource group containing the target virtual network. | `string` | `""` | no |
| linux_vm_workload | Workload identifier used in Linux VM naming and tagging. | `string` | `"iactest"` | no |
| location | Azure region for the landing zone. | `string` | `"eastus"` | no |
| log_analytics_internet_ingestion_enabled | Whether public ingestion is enabled for the Log Analytics workspace. | `bool` | `true` | no |
| log_analytics_internet_query_enabled | Whether public query is enabled for the Log Analytics workspace. | `bool` | `true` | no |
| log_analytics_local_authentication_disabled | Whether local authentication is disabled for the Log Analytics workspace. | `bool` | `false` | no |
| log_analytics_name | Optional override for the Log Analytics workspace name. | `string` | `""` | no |
| log_analytics_reservation_capacity_in_gb_per_day | Optional commitment tier in GB/day for the Log Analytics workspace. | `number` | `null` | no |
| log_analytics_retention_in_days | Retention period in days for the Log Analytics workspace. | `number` | `30` | no |
| managed_identity_name | Optional override for the landing zone user-assigned managed identity name. | `string` | `""` | no |
| management_group_parent_management_group_id | Optional parent management group resource ID. | `string` | `""` | no |
| management_subscription_id | Azure subscription ID used by the aliased azurerm.management provider. | `string` | `"624ce74e-cf6e-4eed-afba-352bcf08bca0"` | no |
| mg_landingzone_children | Child management groups created under the landing zone management group. | <pre>map(object({<br>    display_name = string<br>  }))</pre> | `{}` | no |
| mg_platform_children | Child management groups created under the platform management group. | <pre>map(object({<br>    display_name = string<br>  }))</pre> | <pre>{<br>  "connectivity": {<br>    "display_name": "Connectivity"<br>  },<br>  "identity": {<br>    "display_name": "Identity"<br>  },<br>  "management": {<br>    "display_name": "Management"<br>  },<br>  "security": {<br>    "display_name": "Security"<br>  }<br>}</pre> | no |
| nsg_name | Optional override for the landing zone NSG name. | `string` | `""` | no |
| openai_custom_subdomain_name | Optional custom subdomain name for the Azure OpenAI account. | `string` | `""` | no |
| openai_deployments | Azure OpenAI model deployments keyed by deployment name. | <pre>map(object({<br>    model_format               = string<br>    model_name                 = string<br>    model_version              = optional(string)<br>    sku_name                   = string<br>    sku_capacity               = optional(number)<br>    sku_family                 = optional(string)<br>    sku_size                   = optional(string)<br>    sku_tier                   = optional(string)<br>    dynamic_throttling_enabled = optional(bool)<br>    rai_policy_name            = optional(string)<br>    version_upgrade_option     = optional(string)<br>  }))</pre> | `{}` | no |
| openai_diagnostic_log_categories | Diagnostic log categories to enable for Azure OpenAI. | `list(string)` | `[]` | no |
| openai_diagnostic_metric_categories | Diagnostic metric categories to enable for Azure OpenAI. | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| openai_dynamic_throttling_enabled | Whether dynamic throttling is enabled for the Azure OpenAI account. | `bool` | `false` | no |
| openai_enable_diagnostics | Whether to send Azure OpenAI diagnostics to the shared Log Analytics workspace. | `bool` | `false` | no |
| openai_local_auth_enabled | Whether local auth keys are enabled on the Azure OpenAI account. | `bool` | `true` | no |
| openai_name | Optional override for the Azure OpenAI account name. | `string` | `""` | no |
| openai_network_acls | Optional network ACL configuration for the Azure OpenAI account. | <pre>object({<br>    default_action = string<br>    bypass         = optional(string)<br>    ip_rules       = optional(set(string))<br>    virtual_network_rules = optional(set(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool)<br>    })))<br>  })</pre> | `null` | no |
| openai_outbound_network_access_restricted | Whether outbound network access is restricted on the Azure OpenAI account. | `bool` | `false` | no |
| openai_private_dns_zone_id | Optional override private DNS zone ID for the Azure OpenAI private endpoint. Leave empty to use the landing zone private DNS module when privatelink.openai.azure.com is present. | `string` | `""` | no |
| openai_public_network_access_enabled | Whether public network access is enabled on the Azure OpenAI account. | `bool` | `true` | no |
| openai_sku_name | SKU name for the Azure OpenAI account. | `string` | `"S0"` | no |
| platform_mg_display | Optional override for the management group display name. | `string` | `"Platform Dev"` | no |
| platform_mg_name | Optional override for the management group ID. | `string` | `"mg-platform-dev"` | no |
| platform_role_assignments | Optional platform RBAC assignments for the landing zone. | <pre>map(object({<br>    scope                = string<br>    role_definition_name = optional(string)<br>    role_definition_id   = optional(string)<br>    principal_id         = optional(string)<br>    principal_name       = optional(string)<br>    principal_type       = optional(string)<br>    condition            = optional(string)<br>    condition_version    = optional(string)<br>  }))</pre> | `{}` | no |
| private_dns_zone_names | Private DNS zones created and linked to both hub and spoke VNets. | `list(string)` | <pre>[<br>  "privatelink.azurewebsites.net"<br>]</pre> | no |
| private_endpoint_subnet_prefixes | Address prefixes for the private endpoint subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.71.0/24"<br>]</pre> | no |
| prod_subscription_id | Azure subscription ID used by the aliased azurerm.prod provider. | `string` | `"1ec5edd4-5654-4246-8027-b29ef63b3393"` | no |
| resource_group_name | Optional override for the landing zone resource group name. | `string` | `""` | no |
| rg_tags | n/a | `map(any)` | <pre>{<br>  "AppSupport Team": "CCOE",<br>  "Application Name": "CCOE INFRA IAC",<br>  "Application Owner": "CCOE",<br>  "Approval Group": "CCOE",<br>  "Business Owner": "CCOE",<br>  "Environment": "Sandbox",<br>  "Infra Availability Classification": "Bronze",<br>  "InfraSupport Team": "CCOE",<br>  "Maintenance Window": "CCOE",<br>  "Project Name": "CCOE INFRA IAC",<br>  "Project Number": "N/A",<br>  "RPO-RTO": "48H/24H",<br>  "Run Cost(Approved Run Budget)-USD": "100"<br>}</pre> | no |
| route_table_name | Optional override for the route table name. | `string` | `""` | no |
| sandbox_mg_display | Optional override for the sandbox management group display name. | `string` | `"Sandboxes"` | no |
| sandbox_mg_name | Optional override for the sandbox management group ID. | `string` | `"mg-sandboxes"` | no |
| security_subscription_id | Azure subscription ID used by the aliased azurerm.security provider. | `string` | `"903e61ee-68d8-4fee-aefd-5e207a6b0892"` | no |
| spoke_address_space | Address space for the spoke virtual network. | `list(string)` | <pre>[<br>  "10.167.64.0/20"<br>]</pre> | no |
| spoke_vnet_name | Optional override for the spoke virtual network name. | `string` | `""` | no |
| sql_ad_admin_login | Microsoft Entra administrator name used by the Azure SQL Database example. | `string` | `"sql-admin-group"` | no |
| sql_ad_admin_object_id | Microsoft Entra administrator object ID used by the Azure SQL Database example. | `string` | `"00000000-0000-0000-0000-000000000000"` | no |
| sql_admin_credentials_key_vault_id | Optional Key Vault resource ID containing the SQL admin username and password secrets. When set, this takes precedence for SQL admin secret lookup when inline values are empty. | `string` | `""` | no |
| sql_admin_password | Administrator password used by the Azure SQL Database example. | `string` | `"ChangeMeSql12345!"` | no |
| sql_admin_password_secret_name | Optional Key Vault secret name for the SQL admin password fallback. | `string` | `""` | no |
| sql_admin_username | Administrator login used by the Azure SQL Database example. | `string` | `"sqladminuser"` | no |
| sql_admin_username_secret_name | Optional Key Vault secret name for the SQL admin username fallback. | `string` | `""` | no |
| sql_auto_pause_delay_in_minutes | Serverless auto-pause delay in minutes. Set null for non-serverless SQL SKUs. | `number` | `null` | no |
| sql_backup_storage_redundancy | Backup storage redundancy for the Azure SQL Database example. Valid values are Local, Zone, or Geo. | `string` | `"Local"` | no |
| sql_enable_private_endpoint | Whether to create a private endpoint for the Azure SQL Server. | `bool` | `true` | no |
| sql_firewall_rules | Optional SQL Server firewall rules keyed by rule name. | <pre>map(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | `{}` | no |
| sql_free_limit_exhaustion_behavior | Behavior when the Azure SQL free monthly limits are exhausted. Use AutoPause to pause for the rest of the month or BillOverUsage to allow billable overage. | `string` | `"AutoPause"` | no |
| sql_geo_backup_enabled | Whether geo backups are enabled for the SQL Database. | `bool` | `true` | no |
| sql_iac_kv | Optional shared Key Vault name containing SQL admin secrets. Used with sql_iac_rg when sql_admin_credentials_key_vault_id is empty. | `string` | `""` | no |
| sql_iac_rg | Optional resource group name for the shared Key Vault containing SQL admin secrets. Used when sql_admin_credentials_key_vault_id is empty. | `string` | `""` | no |
| sql_max_size_gb | The maximum size of the SQL Database in gigabytes. | `number` | `32` | no |
| sql_min_capacity | Minimum vCore capacity for Azure SQL serverless databases. Set null for non-serverless SQL SKUs. | `number` | `null` | no |
| sql_public_network_access_enabled | Whether to enable public network access on the Azure SQL Server. | `bool` | `false` | no |
| sql_sku_name | The SKU Name for the SQL Database. | `string` | `"S0"` | no |
| sql_use_free_limit | Whether the Azure SQL Database should use the Azure SQL free monthly limits. | `bool` | `false` | no |
| sqlmi_admin_password | Administrator password used by the SQL Managed Instance example. | `string` | `"ChangeMeSqlMi12345!"` | no |
| sqlmi_admin_username | Administrator login used by the SQL Managed Instance example. | `string` | `"sqlmiadminuser"` | no |
| sqlmi_subnet_prefixes | Address prefixes for the SQL Managed Instance subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.76.0/24"<br>]</pre> | no |
| storage_account_allow_state_container_immutability | Whether to allow applying an immutability policy to the terraform state container. | `bool` | `false` | no |
| storage_account_blob_restore_policy_days | Retention in days for point-in-time blob restore on the landing zone storage account. | `number` | `13` | no |
| storage_account_blob_restore_policy_enabled | Whether point-in-time blob restore is enabled on the landing zone storage account. | `bool` | `true` | no |
| storage_account_blob_soft_delete_enabled | Whether blob soft delete is enabled on the landing zone storage account. | `bool` | `true` | no |
| storage_account_blob_soft_delete_retention_days | Retention in days for blob soft delete on the landing zone storage account. | `number` | `14` | no |
| storage_account_blob_versioning_enabled | Whether blob versioning is enabled on the landing zone storage account. | `bool` | `true` | no |
| storage_account_change_feed_enabled | Whether blob change feed is enabled on the landing zone storage account. | `bool` | `true` | no |
| storage_account_change_feed_retention_in_days | Optional retention in days for blob change feed. Set to null for the platform default. | `number` | `null` | no |
| storage_account_container_immutability_policies | Optional container-level immutability policies keyed by container name. | <pre>map(object({<br>    immutability_period_since_creation_in_days = number<br>    allow_protected_append_writes              = optional(bool, false)<br>    allow_protected_append_writes_all          = optional(bool, false)<br>  }))</pre> | `{}` | no |
| storage_account_container_soft_delete_enabled | Whether container soft delete is enabled on the landing zone storage account. | `bool` | `true` | no |
| storage_account_container_soft_delete_retention_days | Retention in days for container soft delete on the landing zone storage account. | `number` | `14` | no |
| storage_account_name | Optional override for the landing zone storage account name. | `string` | `""` | no |
| subscription_alias_enabled | Whether the landing zone should create a new subscription alias. | `bool` | `false` | no |
| subscription_alias_name | Subscription alias name when subscription_alias_enabled is true. | `string` | `""` | no |
| subscription_id | Default Azure subscription ID used by the root azurerm provider. | `string` | `"1ec5edd4-5654-4246-8027-b29ef63b3393"` | no |
| subscription_management_group_id | Existing management group resource ID to use when enable_management_group is false. | `string` | `""` | no |
| subscription_name | Display name for the subscription bootstrap example. | `string` | `"platform-landingzone-dev"` | no |
| subscription_resource_provider_registrations | Resource providers to register when subscription bootstrap is enabled. | `list(string)` | `[]` | no |
| tags | Tags applied to all landing zone resources. | `map(string)` | `{}` | no |
| vnet_integration_prefixes | Address prefixes for the vnet integration subnet in the spoke VNet. | `list(string)` | <pre>[<br>  "10.167.77.0/24"<br>]</pre> | no |
| workload | Short workload or platform identifier used in generated names. | `string` | `"lzdemo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| acr_id | Azure Container Registry resource ID when the ACR module is enabled. |
| acr_login_server | Azure Container Registry login server when the ACR module is enabled. |
| acr_name | Azure Container Registry name when the ACR module is enabled. |
| acr_private_endpoint_id | Azure Container Registry private endpoint resource ID when private endpoint support is enabled. |
| adf_id | Azure Data Factory resource ID when the ADF module is enabled. |
| adf_name | Azure Data Factory name when the ADF module is enabled. |
| azure_ai_search_endpoint | Azure AI Search endpoint when the Azure AI Search module is enabled. |
| azure_ai_search_id | Azure AI Search service resource ID when the Azure AI Search module is enabled. |
| azure_ai_search_name | Azure AI Search service name when the Azure AI Search module is enabled. |
| azure_ai_search_private_endpoint_id | Azure AI Search private endpoint resource ID when private endpoint support is enabled. |
| azure_ai_service_endpoint | Azure AI Services endpoint when the Azure AI Services module is enabled. |
| azure_ai_service_id | Azure AI Services account resource ID when the Azure AI Services module is enabled. |
| azure_ai_service_name | Azure AI Services account name when the Azure AI Services module is enabled. |
| azure_ai_service_private_endpoint_id | Azure AI Services private endpoint resource ID when private endpoint support is enabled. |
| linux_vm_public_ip | Linux VM public IP addresses when the Linux VM module is enabled and public networking is turned on. |
| openai_deployment_ids | Azure OpenAI deployment resource IDs keyed by deployment name when the OpenAI module is enabled. |
| openai_endpoint | Azure OpenAI endpoint when the OpenAI module is enabled. |
| openai_id | Azure OpenAI account resource ID when the OpenAI module is enabled. |
| openai_name | Azure OpenAI account name when the OpenAI module is enabled. |
| openai_private_endpoint_id | Azure OpenAI private endpoint resource ID when private endpoint support is enabled. |
| sqldb_fqdn | FQDN of the Azure SQL Server when the SQL DB module is enabled. |
| sqldb_public_endpoint | Public SQL endpoint details when the SQL DB module is enabled and public access is configured. public_ip remains null because Azure SQL exposes a public FQDN rather than a dedicated static IP. |
<!-- END_TF_DOCS -->