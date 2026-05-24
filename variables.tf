

# -------------------------------------------------------------------
# Shared Root Variables
# -------------------------------------------------------------------

variable "common_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
}

variable "rg_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Sandbox"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
}

variable "location" {
  description = "Azure region for the landing zone."
  type        = string
  default     = "eastus"
}

variable "workload" {
  description = "Short workload or platform identifier used in generated names."
  type        = string
  default     = "lzdemo"
}

variable "environment" {
  description = "Environment suffix used in generated names."
  type        = string
  default     = "dev"
}

variable "features" {
  description = "Optional high-level feature switches. Known keys include enable_management_group, enable_subscription_bootstrap, enable_private_dns, enable_adf, enable_azure_ai_search, enable_azure_ai_service, enable_openai, enable_acr, enable_app_services, enable_app_registration_for_appservice, enable_automation_accounts, enable_automation_ari_workloads, enable_linux_vm, enable_aks, and enable_sqldb. Unspecified keys fall back to the existing individual variables."
  type        = map(bool)
  default     = {}
}

variable "subscription_id" {
  description = "Default Azure subscription ID used by the root azurerm provider."
  type        = string
  default     = "1ec5edd4-5654-4246-8027-b29ef63b3393"
}

variable "prod_subscription_id" {
  description = "Azure subscription ID used by the aliased azurerm.prod provider."
  type        = string
  default     = "1ec5edd4-5654-4246-8027-b29ef63b3393"
}

variable "identity_subscription_id" {
  description = "Azure subscription ID used by the aliased azurerm.identity provider."
  type        = string
  default     = "74c3c03d-217f-4138-b9a6-79145d37781a"
}

variable "management_subscription_id" {
  description = "Azure subscription ID used by the aliased azurerm.management provider."
  type        = string
  default     = "624ce74e-cf6e-4eed-afba-352bcf08bca0"
}

variable "connectivity_subscription_id" {
  description = "Azure subscription ID used by the aliased azurerm.connectivity provider."
  type        = string
  default     = "d3927a5b-0ea7-40e1-bbb5-d3ba34515fb0"
}

variable "security_subscription_id" {
  description = "Azure subscription ID used by the aliased azurerm.security provider."
  type        = string
  default     = "903e61ee-68d8-4fee-aefd-5e207a6b0892"
}

# -------------------------------------------------------------------
# Governance Module Variables
# -------------------------------------------------------------------

variable "enable_management_group" {
  description = "Whether to create a management group in the example."
  type        = bool
  default     = false
}

variable "platform_mg_name" {
  description = "Optional override for the management group ID."
  type        = string
  default     = "mg-platform-dev"
}
variable "landingzone_mg_name" {
  description = "Optional override for the management group ID."
  type        = string
  default     = "mg-landingzone-dev"
}
variable "sandbox_mg_name" {
  description = "Optional override for the sandbox management group ID."
  type        = string
  default     = "mg-sandboxes"
}
variable "platform_mg_display" {
  description = "Optional override for the management group display name."
  type        = string
  default     = "Platform Dev"
}
variable "landingzone_mg_display" {
  description = "Optional override for the management group display name."
  type        = string
  default     = "Landingzone Dev"
}
variable "sandbox_mg_display" {
  description = "Optional override for the sandbox management group display name."
  type        = string
  default     = "Sandboxes"
}


variable "management_group_parent_management_group_id" {
  description = "Optional parent management group resource ID."
  type        = string
  default     = ""
}

variable "mg_platform_children" {
  description = "Child management groups created under the platform management group."
  type = map(object({
    display_name = string
  }))
  default = {
    connectivity = {
      display_name = "Connectivity"
    }
    identity = {
      display_name = "Identity"
    }
    security = {
      display_name = "Security"
    }
    management = {
      display_name = "Management"
    }
  }
}

variable "mg_landingzone_children" {
  description = "Child management groups created under the landing zone management group."
  type = map(object({
    display_name = string
  }))
  default = {}
}

# -------------------------------------------------------------------
# Subscription Vending Module Variables
# -------------------------------------------------------------------

variable "enable_subscription_bootstrap" {
  description = "Whether to use subscription_vending in the example."
  type        = bool
  default     = false
}

variable "subscription_alias_enabled" {
  description = "Whether the landing zone should create a new subscription alias."
  type        = bool
  default     = false
}

variable "subscription_alias_name" {
  description = "Subscription alias name when subscription_alias_enabled is true."
  type        = string
  default     = ""
}

variable "subscription_name" {
  description = "Display name for the subscription bootstrap example."
  type        = string
  default     = "platform-landingzone-dev"
}

variable "billing_scope_id" {
  description = "Billing scope ID when creating a new subscription alias."
  type        = string
  default     = ""
}

variable "existing_subscription_id" {
  description = "Existing subscription resource ID used when bootstrapping an existing subscription."
  type        = string
  default     = ""
}

variable "subscription_management_group_id" {
  description = "Existing management group resource ID to use when enable_management_group is false."
  type        = string
  default     = ""
}

variable "subscription_resource_provider_registrations" {
  description = "Resource providers to register when subscription bootstrap is enabled."
  type        = list(string)
  default = [
    # "Microsoft.Network",
    # "Microsoft.KeyVault",
    # "Microsoft.Storage",
    # "Microsoft.Insights",
    # "Microsoft.Web",
    # "Microsoft.DataFactory",
    # "Microsoft.Databricks",
    # "Microsoft.Compute"
  ]
}

variable "hierarchy_subscriptions" {
  description = "Optional subscription hierarchy entries. By default the map key is the target management group key; set management_group_key to place multiple subscriptions in the same management group."
  type = map(object({
    subscription_name          = string
    existing_subscription_id   = string
    management_group_key       = optional(string, "")
    subscription_alias_enabled = optional(bool, false)
    subscription_alias_name    = optional(string, "")
    billing_scope_id           = optional(string, "")
  }))
  default = {
    landingzone = {
      subscription_name        = "landingzone-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000013"
      management_group_key     = "landingzone"
    }
  }
}

# -------------------------------------------------------------------
# Foundation Module Variables
# -------------------------------------------------------------------

variable "resource_group_name" {
  description = "Optional override for the landing zone resource group name."
  type        = string
  default     = ""
}

variable "hub_vnet_name" {
  description = "Optional override for the hub virtual network name."
  type        = string
  default     = ""
}

variable "spoke_vnet_name" {
  description = "Optional override for the spoke virtual network name."
  type        = string
  default     = ""
}

variable "nsg_name" {
  description = "Optional override for the landing zone NSG name."
  type        = string
  default     = ""
}

variable "managed_identity_name" {
  description = "Optional override for the landing zone user-assigned managed identity name."
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Optional override for the landing zone storage account name."
  type        = string
  default     = ""
}

variable "storage_account_blob_versioning_enabled" {
  description = "Whether blob versioning is enabled on the landing zone storage account."
  type        = bool
  default     = true
}

variable "storage_account_blob_soft_delete_enabled" {
  description = "Whether blob soft delete is enabled on the landing zone storage account."
  type        = bool
  default     = true
}

variable "storage_account_blob_soft_delete_retention_days" {
  description = "Retention in days for blob soft delete on the landing zone storage account."
  type        = number
  default     = 14
}

variable "storage_account_container_soft_delete_enabled" {
  description = "Whether container soft delete is enabled on the landing zone storage account."
  type        = bool
  default     = true
}

variable "storage_account_container_soft_delete_retention_days" {
  description = "Retention in days for container soft delete on the landing zone storage account."
  type        = number
  default     = 14
}

variable "storage_account_change_feed_enabled" {
  description = "Whether blob change feed is enabled on the landing zone storage account."
  type        = bool
  default     = true
}

variable "storage_account_change_feed_retention_in_days" {
  description = "Optional retention in days for blob change feed. Set to null for the platform default."
  type        = number
  default     = null
  nullable    = true
}

variable "storage_account_blob_restore_policy_enabled" {
  description = "Whether point-in-time blob restore is enabled on the landing zone storage account."
  type        = bool
  default     = true
}

variable "storage_account_blob_restore_policy_days" {
  description = "Retention in days for point-in-time blob restore on the landing zone storage account."
  type        = number
  default     = 13
}

variable "storage_account_allow_state_container_immutability" {
  description = "Whether to allow applying an immutability policy to the terraform state container."
  type        = bool
  default     = false
}

variable "storage_account_container_immutability_policies" {
  description = "Optional container-level immutability policies keyed by container name."
  type = map(object({
    immutability_period_since_creation_in_days = number
    allow_protected_append_writes              = optional(bool, false)
    allow_protected_append_writes_all          = optional(bool, false)
  }))
  default = {}
}

variable "key_vault_name" {
  description = "Optional override for the landing zone Key Vault name."
  type        = string
  default     = ""
}

check "storage_account_data_protection_input_consistency" {
  assert {
    condition = !var.storage_account_blob_restore_policy_enabled || (
      var.storage_account_blob_versioning_enabled &&
      var.storage_account_blob_soft_delete_enabled &&
      var.storage_account_change_feed_enabled
    )
    error_message = "storage_account_blob_restore_policy_enabled requires blob versioning, blob soft delete, and change feed to be enabled."
  }

  assert {
    condition = !var.storage_account_blob_restore_policy_enabled || (
      var.storage_account_blob_restore_policy_days < var.storage_account_blob_soft_delete_retention_days
    )
    error_message = "storage_account_blob_restore_policy_days must be less than storage_account_blob_soft_delete_retention_days."
  }

  assert {
    condition     = var.storage_account_allow_state_container_immutability || !contains(keys(var.storage_account_container_immutability_policies), "terraform")
    error_message = "Applying immutability to the terraform state container can block future state writes. Remove the terraform key from storage_account_container_immutability_policies or set storage_account_allow_state_container_immutability = true if that is intentional."
  }
}

variable "log_analytics_name" {
  description = "Optional override for the Log Analytics workspace name."
  type        = string
  default     = ""
}

variable "firewall_name" {
  description = "Optional override for the Azure Firewall name."
  type        = string
  default     = ""
}

variable "route_table_name" {
  description = "Optional override for the route table name."
  type        = string
  default     = ""
}

variable "adf_name" {
  description = "Optional override for the Azure Data Factory name."
  type        = string
  default     = ""
}

variable "enable_adf" {
  description = "Enable the Azure Data Factory module in the landing zone."
  type        = bool
  default     = false
}

variable "adf_default_integration_runtime_name" {
  description = "Optional override for the default Azure Integration Runtime name inside Data Factory."
  type        = string
  default     = null
}

variable "adf_diagnostics_name" {
  description = "Optional override for the Azure Monitor diagnostic settings name used by the ADF module."
  type        = string
  default     = null
}

variable "adf_shir_name" {
  description = "Optional override for the SHIR name when self-hosted integration runtime is enabled."
  type        = string
  default     = null
}

variable "adf_public_network_enabled" {
  description = "Whether the Azure Data Factory control plane is exposed to the public network."
  type        = bool
  default     = false
}

variable "adf_managed_virtual_network_enabled" {
  description = "Whether to enable the managed virtual network for Azure Data Factory."
  type        = bool
  default     = true
}

variable "adf_cleanup_enabled" {
  description = "Whether ADF data flow clusters are cleaned up after runs."
  type        = bool
  default     = true
}

variable "adf_compute_type" {
  description = "Compute type for the default Azure Integration Runtime data flow cluster."
  type        = string
  default     = "General"
}

variable "adf_core_count" {
  description = "Core count for the default Azure Integration Runtime data flow cluster."
  type        = number
  default     = 8
}

variable "adf_time_to_live_min" {
  description = "Time-to-live for the default Azure Integration Runtime data flow cluster."
  type        = number
  default     = 15
}

variable "adf_virtual_network_enabled" {
  description = "Whether the default Azure Integration Runtime uses managed virtual network execution."
  type        = bool
  default     = true
}

variable "adf_self_hosted_integration_runtime_enabled" {
  description = "Whether to enable the self-hosted integration runtime path for the ADF module."
  type        = bool
  default     = false
}

variable "adf_enable_diagnostics" {
  description = "Whether to send Azure Data Factory diagnostics to the shared Log Analytics workspace."
  type        = bool
  default     = false
}

# -------------------------------------------------------------------
# Azure AI Search Module Variables
# -------------------------------------------------------------------

variable "enable_azure_ai_search" {
  description = "Enable the Azure AI Search module in the landing zone."
  type        = bool
  default     = false
}

variable "azure_ai_search_name" {
  description = "Optional override for the Azure AI Search service name."
  type        = string
  default     = ""
}

variable "azure_ai_search_sku" {
  description = "SKU for the Azure AI Search service."
  type        = string
  default     = "standard"
}

variable "azure_ai_search_replica_count" {
  description = "Replica count for the Azure AI Search service."
  type        = number
  default     = 1
}

variable "azure_ai_search_partition_count" {
  description = "Partition count for the Azure AI Search service."
  type        = number
  default     = 1
}

variable "azure_ai_search_hosting_mode" {
  description = "Hosting mode for the Azure AI Search service."
  type        = string
  default     = "default"
}

variable "azure_ai_search_semantic_search_sku" {
  description = "Optional semantic ranker SKU for the Azure AI Search service."
  type        = string
  default     = ""
}

variable "azure_ai_search_public_network_access_enabled" {
  description = "Whether public network access is enabled on the Azure AI Search service."
  type        = bool
  default     = true
}

variable "azure_ai_search_allowed_ips" {
  description = "Optional list of public IP ranges allowed to access the Azure AI Search service."
  type        = list(string)
  default     = []
}

variable "azure_ai_search_network_rule_bypass_option" {
  description = "Optional network rule bypass option for the Azure AI Search service."
  type        = string
  default     = "None"
}

variable "azure_ai_search_local_authentication_enabled" {
  description = "Whether API-key based local authentication is enabled on the Azure AI Search service."
  type        = bool
  default     = true
}

variable "azure_ai_search_authentication_failure_mode" {
  description = "Optional authentication failure mode for the Azure AI Search service."
  type        = string
  default     = ""
}

variable "azure_ai_search_customer_managed_key_enforcement_enabled" {
  description = "Whether customer-managed key enforcement is enabled on the Azure AI Search service."
  type        = bool
  default     = false
}

variable "azure_ai_search_identity" {
  description = "Optional managed identity configuration for the Azure AI Search service."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null
}

variable "enable_azure_ai_search_private_endpoint" {
  description = "Whether to create a private endpoint for the Azure AI Search service."
  type        = bool
  default     = false
}

variable "azure_ai_search_private_dns_zone_id" {
  description = "Optional override private DNS zone ID for the Azure AI Search private endpoint. Leave empty to use the landing zone private DNS module when privatelink.search.windows.net is present."
  type        = string
  default     = ""
}

variable "azure_ai_search_enable_diagnostics" {
  description = "Whether to send Azure AI Search diagnostics to the shared Log Analytics workspace."
  type        = bool
  default     = false
}

variable "azure_ai_search_diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for Azure AI Search."
  type        = list(string)
  default     = []
}

variable "azure_ai_search_diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for Azure AI Search."
  type        = list(string)
  default     = ["AllMetrics"]
}

# -------------------------------------------------------------------
# Azure AI Services Module Variables
# -------------------------------------------------------------------

variable "enable_azure_ai_service" {
  description = "Enable the Azure AI Services module in the landing zone."
  type        = bool
  default     = false
}

variable "azure_ai_service_name" {
  description = "Optional override for the Azure AI Services account name."
  type        = string
  default     = ""
}

variable "azure_ai_service_custom_subdomain_name" {
  description = "Optional custom subdomain name for the Azure AI Services account."
  type        = string
  default     = ""
}

variable "azure_ai_service_sku_name" {
  description = "SKU name for the Azure AI Services account."
  type        = string
  default     = "S0"
}

variable "azure_ai_service_public_network_access_enabled" {
  description = "Whether public network access is enabled on the Azure AI Services account."
  type        = bool
  default     = true
}

variable "azure_ai_service_outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted on the Azure AI Services account."
  type        = bool
  default     = false
}

variable "azure_ai_service_local_auth_enabled" {
  description = "Whether local auth keys are enabled on the Azure AI Services account."
  type        = bool
  default     = true
}

variable "azure_ai_service_dynamic_throttling_enabled" {
  description = "Whether dynamic throttling is enabled for the Azure AI Services account."
  type        = bool
  default     = false
}

variable "azure_ai_service_fqdns" {
  description = "Optional list of outbound FQDNs for the Azure AI Services account."
  type        = list(string)
  default     = []
}

variable "azure_ai_service_project_management_enabled" {
  description = "Whether project management is enabled for the Azure AI Services account."
  type        = bool
  default     = false
}

variable "azure_ai_service_identity" {
  description = "Optional managed identity configuration for the Azure AI Services account."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null
}

variable "azure_ai_service_customer_managed_key" {
  description = "Optional customer-managed key configuration for the Azure AI Services account."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "azure_ai_service_storage" {
  description = "Optional storage account attachments for the Azure AI Services account."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = []
}

variable "azure_ai_service_network_acls" {
  description = "Optional network ACL configuration for the Azure AI Services account."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })))
  })
  default = null
}

variable "enable_azure_ai_service_private_endpoint" {
  description = "Whether to create a private endpoint for the Azure AI Services account."
  type        = bool
  default     = false
}

variable "azure_ai_service_private_dns_zone_id" {
  description = "Optional override private DNS zone ID for the Azure AI Services private endpoint. Leave empty to use the landing zone private DNS module when privatelink.cognitiveservices.azure.com is present."
  type        = string
  default     = ""
}

variable "azure_ai_service_enable_diagnostics" {
  description = "Whether to send Azure AI Services diagnostics to the shared Log Analytics workspace."
  type        = bool
  default     = false
}

variable "azure_ai_service_diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for Azure AI Services."
  type        = list(string)
  default     = []
}

variable "azure_ai_service_diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for Azure AI Services."
  type        = list(string)
  default     = ["AllMetrics"]
}

# -------------------------------------------------------------------
# Azure OpenAI Module Variables
# -------------------------------------------------------------------

variable "enable_openai" {
  description = "Enable the Azure OpenAI module in the landing zone."
  type        = bool
  default     = false
}

variable "openai_name" {
  description = "Optional override for the Azure OpenAI account name."
  type        = string
  default     = ""
}

variable "openai_custom_subdomain_name" {
  description = "Optional custom subdomain name for the Azure OpenAI account."
  type        = string
  default     = ""
}

variable "openai_sku_name" {
  description = "SKU name for the Azure OpenAI account."
  type        = string
  default     = "S0"
}

variable "openai_public_network_access_enabled" {
  description = "Whether public network access is enabled on the Azure OpenAI account."
  type        = bool
  default     = true
}

variable "openai_outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted on the Azure OpenAI account."
  type        = bool
  default     = false
}

variable "openai_local_auth_enabled" {
  description = "Whether local auth keys are enabled on the Azure OpenAI account."
  type        = bool
  default     = true
}

variable "openai_dynamic_throttling_enabled" {
  description = "Whether dynamic throttling is enabled for the Azure OpenAI account."
  type        = bool
  default     = false
}

variable "openai_network_acls" {
  description = "Optional network ACL configuration for the Azure OpenAI account."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })))
  })
  default = null
}

variable "enable_openai_private_endpoint" {
  description = "Whether to create a private endpoint for the Azure OpenAI account."
  type        = bool
  default     = false
}

variable "openai_private_dns_zone_id" {
  description = "Optional override private DNS zone ID for the Azure OpenAI private endpoint. Leave empty to use the landing zone private DNS module when privatelink.openai.azure.com is present."
  type        = string
  default     = ""
}

variable "openai_deployments" {
  description = "Azure OpenAI model deployments keyed by deployment name."
  type = map(object({
    model_format               = string
    model_name                 = string
    model_version              = optional(string)
    sku_name                   = string
    sku_capacity               = optional(number)
    sku_family                 = optional(string)
    sku_size                   = optional(string)
    sku_tier                   = optional(string)
    dynamic_throttling_enabled = optional(bool)
    rai_policy_name            = optional(string)
    version_upgrade_option     = optional(string)
  }))
  default = {}
}

variable "openai_enable_diagnostics" {
  description = "Whether to send Azure OpenAI diagnostics to the shared Log Analytics workspace."
  type        = bool
  default     = false
}

variable "openai_diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for Azure OpenAI."
  type        = list(string)
  default     = []
}

variable "openai_diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for Azure OpenAI."
  type        = list(string)
  default     = ["AllMetrics"]
}

# -------------------------------------------------------------------
# Azure Container Registry Module Variables
# -------------------------------------------------------------------

variable "enable_acr" {
  description = "Enable the Azure Container Registry module in the landing zone."
  type        = bool
  default     = false
}

variable "acr_name" {
  description = "Optional base name override for the Azure Container Registry. The ACR module adds the acr prefix, region, environment, and numeric suffix."
  type        = string
  default     = ""
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry."
  type        = string
  default     = "Premium"
}

variable "acr_admin_enabled" {
  description = "Whether the ACR admin user is enabled."
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Whether public network access is enabled for ACR."
  type        = bool
  default     = false
}

variable "acr_anonymous_pull_enabled" {
  description = "Whether anonymous pull access is enabled for ACR."
  type        = bool
  default     = false
}

variable "acr_data_endpoint_enabled" {
  description = "Whether dedicated ACR data endpoints are enabled."
  type        = bool
  default     = false
}

variable "acr_identity_type" {
  description = "Managed identity type for ACR."
  type        = string
  default     = "None"
}

variable "acr_identity_ids" {
  description = "User-assigned managed identity IDs for ACR when acr_identity_type includes UserAssigned."
  type        = list(string)
  default     = []
}

variable "acr_managed_identity_role_assignments" {
  description = "Role assignments to apply to the ACR system-assigned managed identity."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  default = {}
}

variable "acr_customer_managed_key_id" {
  description = "Optional Key Vault key ID used to encrypt ACR."
  type        = string
  default     = null
}

variable "acr_customer_managed_key_identity_client_id" {
  description = "Optional user-assigned identity client ID used with the ACR customer-managed key."
  type        = string
  default     = null
}

variable "acr_export_policy_enabled" {
  description = "Whether the ACR export policy is enabled."
  type        = bool
  default     = true
}

variable "acr_quarantine_policy_enabled" {
  description = "Whether the ACR quarantine policy is enabled."
  type        = bool
  default     = false
}

variable "acr_retention_policy_in_days" {
  description = "Days to retain untagged manifests before purge. Supported only on Premium SKU."
  type        = number
  default     = null
}

variable "acr_trust_policy_enabled" {
  description = "Whether the ACR trust policy is enabled."
  type        = bool
  default     = false
}

variable "acr_zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the primary ACR registry."
  type        = bool
  default     = false
}

variable "acr_georeplications" {
  description = "Optional ACR georeplication locations."
  type = list(object({
    location                  = string
    regional_endpoint_enabled = optional(bool, true)
    zone_redundancy_enabled   = optional(bool, false)
    tags                      = optional(map(string), {})
  }))
  default = []
}

variable "acr_enable_network_rule_set" {
  description = "Whether to configure ACR network rules."
  type        = bool
  default     = false
}

variable "acr_network_rule_bypass_option" {
  description = "Bypass option for the ACR network rule set."
  type        = string
  default     = "AzureServices"
}

variable "acr_network_rule_default_action" {
  description = "Default action for the ACR network rule set."
  type        = string
  default     = "Deny"
}

variable "acr_network_rule_ip_rules" {
  description = "Optional public IP CIDR ranges allowed by ACR network rules."
  type        = list(string)
  default     = []
}

variable "acr_enable_private_endpoint" {
  description = "Whether to create a private endpoint for ACR."
  type        = bool
  default     = false
}

variable "acr_private_dns_zone_id" {
  description = "Optional private DNS zone ID for the ACR private endpoint. Leave empty to use privatelink.azurecr.io from the landing zone private DNS module when present."
  type        = string
  default     = ""
}

variable "acr_private_dns_zone_name" {
  description = "Optional existing private DNS zone name used for ACR private endpoint lookup when acr_private_dns_zone_id is not set."
  type        = string
  default     = ""
}

variable "acr_private_dns_zone_resource_group_name" {
  description = "Optional resource group containing acr_private_dns_zone_name."
  type        = string
  default     = ""
}

variable "acr_enable_diagnostics" {
  description = "Whether to send ACR diagnostics to the shared Log Analytics workspace."
  type        = bool
  default     = false
}

variable "acr_diagnostic_log_categories" {
  description = "Diagnostic log categories to enable for ACR."
  type        = list(string)
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
}

variable "acr_diagnostic_metric_categories" {
  description = "Diagnostic metric categories to enable for ACR."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "adf_analytics_destination_type" {
  description = "Log Analytics destination type for ADF diagnostic settings."
  type        = string
  default     = "Dedicated"
}

variable "adf_permissions" {
  description = "Optional Azure Data Factory resource-level permissions in the module's expected object_id/role shape."
  type        = list(map(string))
  default     = []
}

variable "adf_global_parameters" {
  description = "Optional Data Factory global parameters."
  type = list(object({
    name  = string
    type  = optional(string, "String")
    value = string
  }))
  default = []
}

variable "adf_managed_private_endpoints" {
  description = "Optional managed private endpoints created from Azure Data Factory."
  type = set(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  default = []
}

variable "adf_vsts_configuration" {
  description = "Azure DevOps repository configuration for Data Factory source control integration."
  type = object({
    account_name         = string
    project_name         = string
    repository_name      = string
    branch_name          = string
    root_folder          = string
    tenant_id            = string
    collaboration_branch = optional(string)
  })
  default = {
    account_name         = "CCOE-Azure"
    project_name         = "CCoE-Infra-IaC"
    repository_name      = ""
    branch_name          = "adf_publish"
    root_folder          = "/"
    tenant_id            = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
    collaboration_branch = "main"
  }
}

variable "adf_enable_private_endpoint" {
  description = "Whether to create the Azure Data Factory control-plane private endpoint."
  type        = bool
  default     = false
}

variable "adf_private_dns_zone_id" {
  description = "Optional existing private DNS zone ID for privatelink.datafactory.azure.net."
  type        = string
  default     = ""
}

variable "adf_private_dns_zone_name" {
  description = "Private DNS zone name used for Azure Data Factory control-plane private endpoint resolution."
  type        = string
  default     = "privatelink.datafactory.azure.net"
}

variable "adf_private_dns_zone_resource_group_name" {
  description = "Resource group containing the existing Azure Data Factory private DNS zone when an explicit zone ID is not provided."
  type        = string
  default     = ""
}

# -------------------------------------------------------------------
# Network Module Variables
# -------------------------------------------------------------------

variable "hub_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.167.32.0/20"]
}

variable "spoke_address_space" {
  description = "Address space for the spoke virtual network."
  type        = list(string)
  default     = ["10.167.64.0/20"]
}

variable "firewall_subnet_prefixes" {
  description = "Address prefixes for AzureFirewallSubnet in the hub VNet."
  type        = list(string)
  default     = ["10.167.33.64/26"]
}

variable "app_subnet_prefixes" {
  description = "Address prefixes for the application subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.70.0/24"]
}

variable "private_endpoint_subnet_prefixes" {
  description = "Address prefixes for the private endpoint subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.71.0/24"]
}

variable "databricks_public_subnet_prefixes" {
  description = "Address prefixes for the Databricks public subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.72.0/24"]
}

variable "databricks_private_subnet_prefixes" {
  description = "Address prefixes for the Databricks private subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.73.0/24"]
}

variable "aks_subnet_prefixes" {
  description = "Address prefixes for the AKS subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.74.0/24"]
}

variable "jumpbox_subnet_prefixes" {
  description = "Address prefixes for the jumpbox subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.75.0/24"]
}

variable "sqlmi_subnet_prefixes" {
  description = "Address prefixes for the SQL Managed Instance subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.76.0/24"]
}
variable "vnet_integration_prefixes" {
  description = "Address prefixes for the vnet integration subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.167.77.0/24"]
}
variable "private_dns_zone_names" {
  description = "Private DNS zones created and linked to both hub and spoke VNets."
  type        = list(string)
  default = [
    # "privatelink.blob.core.windows.net",
    # "privatelink.vaultcore.azure.net",
    "privatelink.azurewebsites.net",
    # "privatelink.azurecr.io",
    # "privatelink.search.windows.net",
    # "privatelink.openai.azure.com",
    # "privatelink.servicebus.windows.net",
    # "privatelink.cognitiveservices.azure.com",
    # "privatelink.datafactory.azure.net",
    # "privatelink.database.windows.net"
  ]
}

# -------------------------------------------------------------------
# Optional Network Services Variables
# -------------------------------------------------------------------

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Standard"
}

# -------------------------------------------------------------------
# Log Analytics Module Variables
# -------------------------------------------------------------------

variable "log_analytics_retention_in_days" {
  description = "Retention period in days for the Log Analytics workspace."
  type        = number
  default     = 30
}

variable "log_analytics_internet_ingestion_enabled" {
  description = "Whether public ingestion is enabled for the Log Analytics workspace."
  type        = bool
  default     = true
}

variable "log_analytics_internet_query_enabled" {
  description = "Whether public query is enabled for the Log Analytics workspace."
  type        = bool
  default     = true
}

variable "log_analytics_local_authentication_disabled" {
  description = "Whether local authentication is disabled for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "log_analytics_reservation_capacity_in_gb_per_day" {
  description = "Optional commitment tier in GB/day for the Log Analytics workspace."
  type        = number
  default     = null
}

# -------------------------------------------------------------------
# App Service Module Variables
# -------------------------------------------------------------------

variable "appservice_stack" {
  description = "Application runtime stack used by the App Service module."
  type        = string
  default     = "dotnet"

  validation {
    condition     = contains(["dotnet", "python", "node"], lower(var.appservice_stack))
    error_message = "appservice_stack must be one of: dotnet, python, node."
  }
}

variable "app_services" {
  description = "App Service instances to provision. Toggle each stack with enabled."

  type = map(object({
    enabled           = bool
    stack             = string
    kind              = string
    plan_os_type      = string
    sku_name          = string
    deployment_method = optional(string, "run_from_package")
    use_32_bit_worker = optional(bool)
    startup_command   = optional(string)
    dotnet_version    = optional(string)
    node_version      = optional(string)
    python_version    = optional(string)
    app_settings      = optional(map(string), {})
    # Deprecated: prefer deployment_method. Retained only for backward compatibility
    # when older callers omit deployment_method.
    deployment_center_enabled                  = optional(bool, false)
    deployment_center_azure_repos_organization = optional(string)
    deployment_center_azure_repos_project      = optional(string)
    deployment_center_azure_repos_repository   = optional(string)
    deployment_center_azure_repos_branch       = optional(string, "main")
    deployment_center_use_manual_integration   = optional(bool, true)
  }))

  default = {
    dotnet = {
      enabled                                  = true
      stack                                    = "dotnet"
      kind                                     = "Windows"
      plan_os_type                             = "Windows"
      sku_name                                 = "S1"
      deployment_method                        = "run_from_package"
      use_32_bit_worker                        = null
      startup_command                          = null
      dotnet_version                           = "v8.0"
      deployment_center_azure_repos_branch     = "main"
      deployment_center_use_manual_integration = true
    }
    node = {
      enabled                                  = true
      stack                                    = "node"
      kind                                     = "Linux"
      plan_os_type                             = "Linux"
      sku_name                                 = "S1"
      deployment_method                        = "run_from_package"
      use_32_bit_worker                        = null
      startup_command                          = null
      node_version                             = "24-lts"
      deployment_center_azure_repos_branch     = "main"
      deployment_center_use_manual_integration = true
      app_settings = {
        WEBSITE_NODE_DEFAULT_VERSION = "~24"
      }
    }
    python = {
      enabled                                  = false
      stack                                    = "python"
      kind                                     = "Linux"
      plan_os_type                             = "Linux"
      sku_name                                 = "S1"
      deployment_method                        = "run_from_package"
      use_32_bit_worker                        = null
      startup_command                          = null
      python_version                           = "3.14"
      deployment_center_azure_repos_branch     = "main"
      deployment_center_use_manual_integration = true
    }
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : contains(["dotnet", "node", "python"], lower(app_service.stack))])
    error_message = "Each app_services entry stack must be one of: dotnet, node, python."
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : contains(["Windows", "Linux"], app_service.kind)])
    error_message = "Each app_services entry kind must be either Windows or Linux."
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : contains(["Windows", "Linux"], app_service.plan_os_type)])
    error_message = "Each app_services entry plan_os_type must be either Windows or Linux."
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : app_service.kind == app_service.plan_os_type])
    error_message = "Each app_services entry kind must match plan_os_type."
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : lower(app_service.stack) != "python" || app_service.kind == "Linux"])
    error_message = "Python App Service entries must use Linux."
  }

  validation {
    condition     = alltrue([for _, app_service in var.app_services : contains(["run_from_package", "deployment_center", "zip_deploy_with_build"], try(app_service.deployment_method, "run_from_package"))])
    error_message = "Each app_services entry deployment_method must be one of: run_from_package, deployment_center, zip_deploy_with_build."
  }

  validation {
    condition = alltrue([
      for _, app_service in var.app_services :
      try(app_service.deployment_method, "run_from_package") != "run_from_package" ||
      !try(app_service.deployment_center_enabled, false)
    ])
    error_message = "Do not set deployment_center_enabled = true when deployment_method = \"run_from_package\". Use deployment_method as the single selector for each app_services entry."
  }

  validation {
    condition = alltrue([
      for _, app_service in var.app_services :
      !app_service.enabled ||
      lower(app_service.stack) != "dotnet" ||
      try(trimspace(app_service.dotnet_version), "") != ""
    ])
    error_message = "Enabled dotnet App Service entries must set dotnet_version."
  }

  validation {
    condition = alltrue([
      for _, app_service in var.app_services :
      !app_service.enabled ||
      lower(app_service.stack) != "node" ||
      try(trimspace(app_service.node_version), "") != ""
    ])
    error_message = "Enabled node App Service entries must set node_version."
  }

  validation {
    condition = alltrue([
      for _, app_service in var.app_services :
      !app_service.enabled ||
      lower(app_service.stack) != "python" ||
      try(trimspace(app_service.python_version), "") != ""
    ])
    error_message = "Enabled python App Service entries must set python_version."
  }

  validation {
    condition = alltrue([
      for _, app_service in var.app_services :
      !(try(app_service.deployment_method, "run_from_package") == "deployment_center" || try(app_service.deployment_center_enabled, false)) || (
        try(trimspace(app_service.deployment_center_azure_repos_organization), "") != "" &&
        try(trimspace(app_service.deployment_center_azure_repos_project), "") != "" &&
        try(trimspace(app_service.deployment_center_azure_repos_repository), "") != ""
      )
    ])
    error_message = "When deployment_method = \"deployment_center\" (or legacy deployment_center_enabled = true), set deployment_center_azure_repos_organization, deployment_center_azure_repos_project, and deployment_center_azure_repos_repository for that app_services entry."
  }
}

variable "automation_accounts" {
  description = "Automation Account instances to provision. Toggle each account with enabled."

  type = map(object({
    enabled                         = bool
    name                            = optional(string)
    sku_name                        = optional(string, "Basic")
    local_auth_enabled              = optional(bool, false)
    public_access_enabled           = optional(bool, true)
    system_managed_identity_enabled = optional(bool, true)
    app_admin_group                 = optional(list(string), [])
    app_user_group                  = optional(list(string), [])
    managed_identity_role_assignments = optional(map(object({
      scope                = string
      role_definition_name = optional(string)
      role_definition_id   = optional(string)
    })), {})
    private_endpoint_enabled                     = optional(bool, false)
    private_endpoint_subresource_name            = optional(string, "Webhook")
    enable_webhook_private_endpoint              = optional(bool)
    enable_hrw_private_endpoint                  = optional(bool)
    private_endpoint_subnet_id                   = optional(string, "")
    private_endpoint_subnet_name                 = optional(string)
    private_endpoint_vnet_name                   = optional(string)
    private_endpoint_network_resource_group_name = optional(string)
    private_dns_zone_id                          = optional(string, "")
    enable_diagnostics                           = optional(bool, true)
    diagnostic_log_categories                    = optional(list(string), ["JobLogs", "JobStreams", "AuditEvent", "DscNodeStatus"])
    diagnostic_metric_categories                 = optional(list(string), ["AllMetrics"])
    tags                                         = optional(map(string), {})
  }))

  default = {
    default = {
      enabled                                      = false
      name                                         = null
      sku_name                                     = "Basic"
      local_auth_enabled                           = false
      public_access_enabled                        = true
      system_managed_identity_enabled              = true
      app_admin_group                              = []
      app_user_group                               = []
      managed_identity_role_assignments            = {}
      private_endpoint_enabled                     = false
      private_endpoint_subresource_name            = "Webhook"
      enable_webhook_private_endpoint              = null
      enable_hrw_private_endpoint                  = null
      private_endpoint_subnet_id                   = ""
      private_endpoint_subnet_name                 = null
      private_endpoint_vnet_name                   = null
      private_endpoint_network_resource_group_name = null
      private_dns_zone_id                          = ""
      enable_diagnostics                           = true
      diagnostic_log_categories                    = ["JobLogs", "JobStreams", "AuditEvent", "DscNodeStatus"]
      diagnostic_metric_categories                 = ["AllMetrics"]
      tags                                         = {}
    }
  }

  validation {
    condition = alltrue([
      for _, automation_account in var.automation_accounts :
      contains(["Basic", "Free"], try(automation_account.sku_name, "Basic"))
    ])
    error_message = "Each automation_accounts entry sku_name must be either Basic or Free."
  }

  validation {
    condition = alltrue([
      for _, automation_account in var.automation_accounts :
      contains(["Webhook", "DSCAndHybridWorker", "DscAndHybridWorker"], try(automation_account.private_endpoint_subresource_name, "Webhook"))
    ])
    error_message = "Each automation_accounts entry private_endpoint_subresource_name must be one of: Webhook, DSCAndHybridWorker, DscAndHybridWorker."
  }

  validation {
    condition = alltrue(flatten([
      for _, automation_account in var.automation_accounts : [
        for _, assignment in try(automation_account.managed_identity_role_assignments, {}) :
        (
          (try(assignment.role_definition_name, null) != null && try(assignment.role_definition_id, null) == null) ||
          (try(assignment.role_definition_name, null) == null && try(assignment.role_definition_id, null) != null)
        )
      ]
    ]))
    error_message = "Each automation_accounts managed_identity_role_assignments item must set exactly one of role_definition_name or role_definition_id."
  }
}

# -------------------------------------------------------------------
# Automation ARI Workload Inputs
# -------------------------------------------------------------------

variable "automation_ari_workloads" {
  description = "Azure Resource Inventory (ARI) workloads to attach to provisioned Automation Accounts."

  type = map(object({
    enabled                              = bool
    automation_account_key               = string
    storage_container_name               = optional(string, "ari")
    report_name                          = optional(string, "AZURE")
    report_dir                           = optional(string, "C:\\AzureResourceInventory")
    ari_lite_mode                        = optional(bool, false)
    ari_diagram_full_environment_enabled = optional(bool, true)
    ari_security_center_enabled          = optional(bool, true)
    runbook_name                         = optional(string, "ARI_Runbook")
    runtime_environment_name             = optional(string, "PowerShell-7.4-Env")
    runbook_template_path                = optional(string, "runbooks/ari.ps1.tftpl")
    runtime_packages                     = optional(map(string), {})
    schedule_enabled                     = optional(bool, true)
    schedule_name                        = optional(string, "Azure Inventory Collection - daily")
    schedule_description                 = optional(string, "Daily schedule for the ARI runbook.")
    schedule_frequency                   = optional(string, "Day")
    schedule_interval                    = optional(number, 1)
    schedule_timezone                    = optional(string, "America/Toronto")
    schedule_start_time                  = optional(string)
    runbook_log_verbose                  = optional(bool, true)
    runbook_log_progress                 = optional(bool, true)
    enable_job_failure_alert             = optional(bool, true)
    job_failure_alert_name               = optional(string)
    job_failure_severity                 = optional(number, 2)
    enable_long_running_alert            = optional(bool, true)
    long_running_alert_name              = optional(string)
    long_running_severity                = optional(number, 3)
    long_running_threshold_minutes       = optional(number, 90)
    alert_evaluation_frequency           = optional(string, "PT15M")
    alert_window_duration                = optional(string, "PT15M")
    monitor_action_group_ids             = optional(list(string), [])
    tags                                 = optional(map(string), {})
  }))

  default = {
    default = {
      enabled                              = false
      automation_account_key               = "default"
      storage_container_name               = "ari"
      report_name                          = "AZURE"
      report_dir                           = "C:\\AzureResourceInventory"
      ari_lite_mode                        = false
      ari_diagram_full_environment_enabled = true
      ari_security_center_enabled          = true
      runbook_name                         = "ARI_Runbook"
      runtime_environment_name             = "PowerShell-7.4-Env"
      runbook_template_path                = "runbooks/ari.ps1.tftpl"
      runtime_packages                     = {}
      schedule_enabled                     = true
      schedule_name                        = "Azure Inventory Collection - daily"
      schedule_description                 = "Daily schedule for the ARI runbook."
      schedule_frequency                   = "Day"
      schedule_interval                    = 1
      schedule_timezone                    = "America/Toronto"
      schedule_start_time                  = null
      runbook_log_verbose                  = true
      runbook_log_progress                 = true
      enable_job_failure_alert             = true
      job_failure_alert_name               = null
      job_failure_severity                 = 2
      enable_long_running_alert            = true
      long_running_alert_name              = null
      long_running_severity                = 3
      long_running_threshold_minutes       = 90
      alert_evaluation_frequency           = "PT15M"
      alert_window_duration                = "PT15M"
      monitor_action_group_ids             = []
      tags                                 = {}
    }
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      contains(["Day", "Hour", "Week", "Month"], try(workload.schedule_frequency, "Day"))
    ])
    error_message = "Each automation_ari_workloads entry schedule_frequency must be one of: Day, Hour, Week, Month."
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      try(workload.schedule_interval, 1) >= 1
    ])
    error_message = "Each automation_ari_workloads entry schedule_interval must be greater than or equal to 1."
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      try(workload.schedule_start_time, null) == null ? true : can(formatdate("", workload.schedule_start_time))
    ])
    error_message = "Each automation_ari_workloads entry schedule_start_time must be a valid RFC3339 timestamp when provided."
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      can(regex("^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$", try(workload.storage_container_name, "ari")))
    ])
    error_message = "Each automation_ari_workloads entry storage_container_name must be 3-63 characters, lowercase, and use only letters, numbers, and hyphens."
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      try(workload.long_running_threshold_minutes, 90) >= 1
    ])
    error_message = "Each automation_ari_workloads entry long_running_threshold_minutes must be greater than or equal to 1."
  }

  validation {
    condition = alltrue([
      for _, workload in var.automation_ari_workloads :
      contains([0, 1, 2, 3, 4], try(workload.job_failure_severity, 2)) &&
      contains([0, 1, 2, 3, 4], try(workload.long_running_severity, 3))
    ])
    error_message = "Each automation_ari_workloads alert severity must be an integer between 0 and 4."
  }
}

# -------------------------------------------------------------------
# App Service Inputs
# -------------------------------------------------------------------

variable "app_service_kind" {
  description = "The App Service operating system kind."
  type        = string
  default     = "Windows"

  validation {
    condition     = contains(["Windows", "Linux"], var.app_service_kind)
    error_message = "app_service_kind must be either Windows or Linux."
  }
}

variable "app_service_plan_os_type" {
  description = "Operating system type for the App Service Plan."
  type        = string
  default     = "Windows"

  validation {
    condition     = contains(["Windows", "Linux"], var.app_service_plan_os_type)
    error_message = "app_service_plan_os_type must be either Windows or Linux."
  }
}

variable "app_service_plan_sku_name" {
  description = "SKU name for the App Service Plan."
  type        = string
  default     = "S1"
}

variable "app_service_plan_enable_diagnostics" {
  description = "Whether to send App Service Plan diagnostics to Log Analytics."
  type        = bool
  default     = true
}

variable "app_service_plan_enable_autoscale" {
  description = "Whether to enable autoscale for the App Service Plan."
  type        = bool
  default     = false
}

variable "app_service_plan_autoscale_min_capacity" {
  description = "Minimum App Service Plan autoscale instance count."
  type        = number
  default     = 1
}

variable "app_service_plan_autoscale_default_capacity" {
  description = "Default App Service Plan autoscale instance count."
  type        = number
  default     = 1
}

variable "app_service_plan_autoscale_max_capacity" {
  description = "Maximum App Service Plan autoscale instance count."
  type        = number
  default     = 3
}

variable "app_service_plan_autoscale_cpu_threshold_scale_up" {
  description = "CPU threshold percentage that triggers App Service Plan scale out."
  type        = number
  default     = 75
}

variable "app_service_plan_autoscale_cpu_threshold_scale_down" {
  description = "CPU threshold percentage that triggers App Service Plan scale in."
  type        = number
  default     = 25
}

variable "app_service_plan_autoscale_scale_up_increment" {
  description = "Number of App Service Plan instances to add when scaling out."
  type        = number
  default     = 1
}

variable "app_service_plan_autoscale_scale_down_increment" {
  description = "Number of App Service Plan instances to remove when scaling in."
  type        = number
  default     = 1
}

variable "enable_app_registration_for_appservice" {
  description = "Whether to create an Entra app registration for the App Service."
  type        = bool
  default     = true
}

variable "app_service_auth_mode" {
  description = "Authentication mode for the App Service: none, easy_auth, msal, or both."
  type        = string
  default     = "both"

  validation {
    condition     = contains(["none", "easy_auth", "msal", "both"], var.app_service_auth_mode)
    error_message = "app_service_auth_mode must be one of: none, easy_auth, msal, both."
  }
}

variable "app_service_allow_anonymous" {
  description = "Whether Easy Auth should allow anonymous requests."
  type        = bool
  default     = true
}

variable "app_service_unauthenticated_action" {
  description = "Optional Easy Auth unauthenticated action override."
  type        = string
  default     = "AllowAnonymous"

  validation {
    condition = contains([
      "RedirectToLoginPage",
      "AllowAnonymous",
      "Return401",
      "Return403",
      ""
    ], coalesce(var.app_service_unauthenticated_action, ""))
    error_message = "app_service_unauthenticated_action must be null or one of: RedirectToLoginPage, AllowAnonymous, Return401, Return403."
  }
}

variable "app_registration_display_name" {
  description = "Optional display name override for the App Service app registration."
  type        = string
  default     = null
}

variable "app_registration_web_redirect_uris" {
  description = "Optional explicit redirect URIs for the App Service app registration."
  type        = list(string)
  default     = []
}

variable "app_registration_create_client_secret" {
  description = "Whether to create and store an app registration client secret for the App Service."
  type        = bool
  default     = true
}

variable "app_service_dotnet_version" {
  description = "The .NET runtime version configured on the Windows App Service."
  type        = string
  default     = "v8.0"
}

variable "app_service_node_version" {
  description = "The Node.js runtime version configured on the App Service when appservice_stack is node."
  type        = string
  default     = "24-lts"
}

variable "app_service_python_version" {
  description = "The Python runtime version configured on the App Service when appservice_stack is python."
  type        = string
  default     = "3.14"
}

variable "app_service_app_secret_key" {
  description = "Application secret key setting for the sample app. Replace before production use."
  type        = string
  default     = "replace-with-a-random-secret"
  sensitive   = true
}

variable "app_service_app_settings" {
  description = "Additional App Service app settings merged with the module defaults."
  type        = map(string)
  default     = {}
}

variable "app_service_enable_private_endpoint" {
  description = ""
  type        = bool
  default     = false
}

variable "app_service_public_network_access_enabled" {
  description = "Whether public network access is enabled for the App Service."
  type        = bool
  default     = true
}

variable "app_service_ip_restrictions" {
  description = "Site access restrictions for the App Service public endpoint."

  type = list(object({
    action      = optional(string, "Allow")
    ip_address  = optional(string)
    name        = string
    priority    = number
    service_tag = optional(string)

    headers = optional(object({
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
    }))
  }))

  default = []
}

variable "app_service_ip_restriction_default_action" {
  description = "Default action for App Service site access traffic that does not match an IP restriction rule."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.app_service_ip_restriction_default_action)
    error_message = "app_service_ip_restriction_default_action must be either Allow or Deny."
  }
}

variable "app_service_scm_ip_restrictions" {
  description = "Kudu/SCM endpoint access restrictions for the App Service."

  type = list(object({
    action                    = optional(string, "Allow")
    description               = optional(string)
    ip_address                = optional(string)
    name                      = string
    priority                  = number
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)

    headers = optional(object({
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
    }))
  }))

  default  = []
  nullable = false

  validation {
    condition = alltrue([
      for rule in var.app_service_scm_ip_restrictions :
      contains(["Allow", "Deny"], rule.action)
    ])
    error_message = "Each app_service_scm_ip_restrictions action must be Allow or Deny."
  }
}

variable "app_service_scm_ip_restriction_default_action" {
  description = "Default action for Kudu/SCM endpoint traffic that does not match an IP restriction rule."
  type        = string
  default     = "Deny"
  nullable    = false

  validation {
    condition     = contains(["Allow", "Deny"], var.app_service_scm_ip_restriction_default_action)
    error_message = "app_service_scm_ip_restriction_default_action must be either Allow or Deny."
  }
}

variable "app_service_scm_use_main_ip_restriction" {
  description = "Whether the Kudu/SCM endpoint should reuse the main App Service IP restrictions."
  type        = bool
  default     = false
  nullable    = false
}

variable "app_service_scmIpSecurityRestrictionsUseMain" {
  description = "Optional App Service property override for scmIpSecurityRestrictionsUseMain. When null, app_service_scm_use_main_ip_restriction is used."
  type        = bool
  default     = null
  nullable    = true
}

variable "app_service_vnet_integration_enabled" {
  description = "Whether to integrate the App Service with the spoke application subnet."
  type        = bool
  default     = false
}

variable "app_service_vnet_route_all_enabled" {
  description = "Whether App Service VNet integration routes all outbound traffic through the VNet."
  type        = bool
  default     = false
}

variable "app_service_scm_basic_auth_publishing_credentials_enabled" {
  description = "Whether SCM basic authentication publishing credentials are enabled."
  type        = bool
  default     = true
}

variable "app_service_webdeploy_publish_basic_authentication_enabled" {
  description = "Whether WebDeploy basic publishing authentication is enabled."
  type        = bool
  default     = true
}

# -------------------------------------------------------------------
# Shared RBAC Variables
# -------------------------------------------------------------------

variable "app_admin_group" {
  description = "Optional Entra groups or object IDs with Contributor-style access on landing zone resources."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "Optional Entra groups or object IDs with Reader-style access on landing zone resources."
  type        = list(string)
  default     = []
}

variable "jumpbox_public_network_enabled" {
  description = "Whether the example jumpbox VMs receive public IPs."
  type        = bool
  default     = true
}

# -------------------------------------------------------------------
# Jumpbox Image Variables
# -------------------------------------------------------------------

variable "jumpbox_windows_image_publisher" {
  description = "Marketplace image publisher passed to the winvm module for the example jumpbox."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "jumpbox_windows_image_offer" {
  description = "Marketplace image offer passed to the winvm module for the example jumpbox."
  type        = string
  default     = "WindowsServer"
}

variable "jumpbox_windows_image_sku" {
  description = "Marketplace image SKU passed to the winvm module for the example jumpbox."
  type        = string
  default     = "2022-Datacenter"
}

variable "jumpbox_windows_image_version" {
  description = "Marketplace image version passed to the winvm module for the example jumpbox."
  type        = string
  default     = "latest"
}

# -------------------------------------------------------------------
# SQL Example Variables
# -------------------------------------------------------------------

variable "enable_sqldb" {
  description = "Whether to deploy the Azure SQL Database module."
  type        = bool
  default     = false
}

variable "sql_sku_name" {
  description = "The SKU Name for the SQL Database."
  type        = string
  default     = "S0"
}

variable "sql_use_free_limit" {
  description = "Whether the Azure SQL Database should use the Azure SQL free monthly limits."
  type        = bool
  default     = false
}

variable "sql_free_limit_exhaustion_behavior" {
  description = "Behavior when the Azure SQL free monthly limits are exhausted. Use AutoPause to pause for the rest of the month or BillOverUsage to allow billable overage."
  type        = string
  default     = "AutoPause"
  validation {
    condition     = contains(["AutoPause", "BillOverUsage"], var.sql_free_limit_exhaustion_behavior)
    error_message = "sql_free_limit_exhaustion_behavior must be AutoPause or BillOverUsage."
  }
}

variable "sql_auto_pause_delay_in_minutes" {
  description = "Serverless auto-pause delay in minutes. Set null for non-serverless SQL SKUs."
  type        = number
  default     = null
  nullable    = true
}

variable "sql_min_capacity" {
  description = "Minimum vCore capacity for Azure SQL serverless databases. Set null for non-serverless SQL SKUs."
  type        = number
  default     = null
  nullable    = true
}

variable "sql_geo_backup_enabled" {
  description = "Whether geo backups are enabled for the SQL Database."
  type        = bool
  default     = true
}

variable "sql_max_size_gb" {
  description = "The maximum size of the SQL Database in gigabytes."
  type        = number
  default     = 32
}

variable "sql_backup_storage_redundancy" {
  description = "Backup storage redundancy for the Azure SQL Database example. Valid values are Local, Zone, or Geo."
  type        = string
  default     = "Local"
  validation {
    condition     = contains(["Local", "Zone", "Geo"], var.sql_backup_storage_redundancy)
    error_message = "sql_backup_storage_redundancy must be one of Local, Zone, or Geo."
  }
}

variable "sql_public_network_access_enabled" {
  description = "Whether to enable public network access on the Azure SQL Server."
  type        = bool
  default     = false
}

variable "sql_enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Azure SQL Server."
  type        = bool
  default     = true
}

variable "sql_firewall_rules" {
  description = "Optional SQL Server firewall rules keyed by rule name."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "sql_admin_username" {
  description = "Administrator login used by the Azure SQL Database example."
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Administrator password used by the Azure SQL Database example."
  type        = string
  default     = "ChangeMeSql12345!"
  sensitive   = true
}

variable "sql_admin_credentials_key_vault_id" {
  description = "Optional Key Vault resource ID containing the SQL admin username and password secrets. When set, this takes precedence for SQL admin secret lookup when inline values are empty."
  type        = string
  default     = ""
}

variable "sql_iac_rg" {
  description = "Optional resource group name for the shared Key Vault containing SQL admin secrets. Used when sql_admin_credentials_key_vault_id is empty."
  type        = string
  default     = ""
}

variable "sql_iac_kv" {
  description = "Optional shared Key Vault name containing SQL admin secrets. Used with sql_iac_rg when sql_admin_credentials_key_vault_id is empty."
  type        = string
  default     = ""
}

variable "sql_admin_username_secret_name" {
  description = "Optional Key Vault secret name for the SQL admin username fallback."
  type        = string
  default     = ""
}

variable "sql_admin_password_secret_name" {
  description = "Optional Key Vault secret name for the SQL admin password fallback."
  type        = string
  default     = ""
}

variable "sql_ad_admin_login" {
  description = "Microsoft Entra administrator name used by the Azure SQL Database example."
  type        = string
  default     = "sql-admin-group"
}

variable "sql_ad_admin_object_id" {
  description = "Microsoft Entra administrator object ID used by the Azure SQL Database example."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
  validation {
    condition = (
      !var.enable_sqldb ||
      (
        can(regex("^[0-9a-fA-F-]{36}$", var.sql_ad_admin_object_id)) &&
        lower(var.sql_ad_admin_object_id) != "00000000-0000-0000-0000-000000000000"
      )
    )
    error_message = "When enable_sqldb is true, sql_ad_admin_object_id must be set to a real Microsoft Entra object ID and cannot use the all-zero placeholder."
  }
}

variable "sqlmi_admin_username" {
  description = "Administrator login used by the SQL Managed Instance example."
  type        = string
  default     = "sqlmiadminuser"
}

variable "sqlmi_admin_password" {
  description = "Administrator password used by the SQL Managed Instance example."
  type        = string
  default     = "ChangeMeSqlMi12345!"
  sensitive   = true
}

variable "allowed_policy_locations" {
  description = "Allowed Azure regions used by the sample allowed locations policy."
  type        = list(string)
  default     = ["eastus", "canadaeast"]
}

# -------------------------------------------------------------------
# Platform RBAC and Tag Variables
# -------------------------------------------------------------------

variable "platform_role_assignments" {
  description = "Optional platform RBAC assignments for the landing zone."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
    principal_id         = optional(string)
    principal_name       = optional(string)
    principal_type       = optional(string)
    condition            = optional(string)
    condition_version    = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all landing zone resources."
  type        = map(string)
  default     = {}
}

# -------------------------------------------------------------------
# Linux VM Module Variables
# -------------------------------------------------------------------

variable "enable_linux_vm" {
  type        = bool
  description = "Whether to provision the Linux VM jumpbox module and its related root role assignments."
  default     = true
}

variable "linux_vm_common_tags" {
  type        = map(any)
  description = "Common tags merged into all Linux VM module resources."
  default = {
  }
}

variable "linux_vm_rg_tags" {
  type        = map(any)
  description = "Module-specific tags merged with linux_vm_common_tags and applied to Linux VM module resources."
  default     = {}
}

variable "linux_vm_location" {
  type        = string
  description = "The Azure region in which the Linux VM resources will be created."
  default     = "canadacentral"
}

variable "linux_vm_app_env" {
  type        = string
  description = "Environment, such as prod, qa, dev, poc, test, or sbx."
  default     = "prod"
}

variable "linux_vm_workload" {
  type        = string
  description = "Workload identifier used in Linux VM naming and tagging."
  default     = "iactest"
}
variable "linux_vm_disable_password_authentication" {
  type        = bool
  description = "Whether to disable password authentication for the Linux VM module."
  default     = false
}

variable "linux_vm_admin_password" {
  type        = string
  description = "Optional root-level admin password override for the Linux VM module. Leave empty to use the admin_password secret from linux_vm_iac_kv."
  default     = ""
  sensitive   = true
}

variable "linux_vm_admin_username" {
  type        = string
  description = "Optional administrator username override passed to the Linux VM module. Leave empty to use the admin_username secret from linux_vm_iac_kv."
  default     = ""
}

variable "linux_vm_admin_ssh_key" {
  type        = string
  description = "Optional administrator SSH public key override passed to the Linux VM module. Leave empty to use the azureadmin-pubkey secret from linux_vm_iac_kv."
  default     = ""
  sensitive   = true
}

variable "linux_vm_admin_username_secret_name" {
  type        = string
  description = "Optional Key Vault secret name containing the Linux VM admin username."
  default     = ""
}

variable "linux_vm_admin_password_secret_name" {
  type        = string
  description = "Optional Key Vault secret name containing the Linux VM admin password."
  default     = ""
}

variable "linux_vm_admin_ssh_key_secret_name" {
  type        = string
  description = "Optional Key Vault secret name containing the Linux VM admin SSH public key."
  default     = ""
}

variable "linux_vm_enable_entra_ssh_login" {
  type        = bool
  description = "Whether to enable Microsoft Entra ID SSH login on the Linux VMs."
  default     = false
}

variable "linux_vm_enable_linux_vm_extension" {
  type        = bool
  description = "Whether to enable the optional storage-backed localization CustomScript VM extension for Linux VMs."
  default     = false
}

variable "linux_vm_enable_system_assigned_identity" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Linux VMs. Required when linux_vm_enable_linux_vm_extension = true."
  default     = true
}

variable "linux_vm_localization_container_name" {
  type        = string
  description = "Blob container name in the shared IaC storage account that holds Linux VM localization scripts."
  default     = "localization"
}

variable "linux_vm_localization_os_script_name" {
  type        = string
  description = "OS-level localization script blob name to download first when the optional Linux VM extension is enabled."
  default     = "ubuntu.sh"
}

variable "linux_vm_upload_shared_localization_scripts" {
  type        = bool
  description = "Whether to also upload shared OS localization scripts such as ubuntu.sh and redhat.sh to the localization container in addition to any per-VM scripts."
  default     = false
}

variable "linux_vm_enable_domain_join" {
  type        = bool
  description = "Whether the Linux VM module should attempt domain join during bootstrap. Default is false, which skips the domain-join secret lookup and keeps the VM off domain."
  default     = false
}

variable "linux_vm_datadog_api_key" {
  type        = string
  description = "Legacy Datadog API key retained for Linux VM module compatibility."
  sensitive   = true
}

variable "linux_vm_data_disk_size_gb" {
  type        = number
  description = "Optional additional data disk size in GB. Set to 0 to skip the extra disk."
  default     = 0
}

variable "linux_vm_vm_count" {
  type        = number
  description = "Number of Linux VMs to create."
  default     = 1
}

variable "linux_vm_ado_runner_count" {
  type        = number
  description = "Number of Azure DevOps agents to register on each Linux runner VM."
  default     = 1

  validation {
    condition     = var.linux_vm_ado_runner_count >= 1 && floor(var.linux_vm_ado_runner_count) == var.linux_vm_ado_runner_count
    error_message = "linux_vm_ado_runner_count must be a whole number greater than or equal to 1."
  }
}

variable "linux_vm_vm_size" {
  type        = string
  description = "Azure VM size for each Linux VM."
  default     = "Standard_D4s_v3"
}

variable "linux_vm_image_publisher" {
  type        = string
  description = "Publisher of the Linux VM image."
  default     = "Canonical"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Offer of the Linux VM image."
  default     = "ubuntu-24_04-lts"
}

variable "linux_vm_image_sku" {
  type        = string
  description = "SKU of the Linux VM image."
  default     = "server"
}

variable "linux_vm_image_version" {
  type        = string
  description = "Version of the Linux VM image."
  default     = "latest"
}

variable "linux_vm_iac_rg" {
  type        = string
  description = "Resource group containing the shared IaC storage account and Key Vault."
  default     = ""
}

variable "linux_vm_iac_kv" {
  type        = string
  description = "Shared Key Vault name containing Linux VM secrets."
  default     = ""
}

variable "linux_vm_iac_kv_id" {
  type        = string
  description = "Shared Key Vault resource ID containing Linux VM secrets."
  default     = ""
}

variable "linux_vm_admin_credentials_key_vault_id" {
  type        = string
  description = "Optional Key Vault resource ID to use specifically for Linux VM admin credential secrets. When set, this takes precedence over linux_vm_iac_kv_id for resolving azure-user, azure-password, and azureadmin-pubkey."
  default     = ""
}

variable "linux_vm_iac_st" {
  type        = string
  description = "Shared storage account name containing bootstrap scripts."
  default     = ""
}

variable "linux_vm_iac_st_id" {
  type        = string
  description = "Shared storage account resource ID containing bootstrap scripts."
  default     = ""
}

variable "linux_vm_iac_st_primary_blob_endpoint" {
  type        = string
  description = "Primary blob endpoint for the shared storage account containing bootstrap scripts."
  default     = ""
}

variable "linux_vm_resource_group_name" {
  type        = string
  description = "Target resource group name for the Linux VM resources."
  default     = ""
}

variable "linux_vm_subnet_name" {
  type        = string
  description = "Existing subnet name used for the Linux VM NICs."
  default     = ""
}

variable "linux_vm_subnet_id" {
  type        = string
  description = "Optional subnet resource ID override for the Linux VM NICs."
  default     = ""
}

variable "linux_vm_vnet_resource_group_name" {
  type        = string
  description = "Resource group containing the target virtual network."
  default     = ""
}

variable "linux_vm_vnet_name" {
  type        = string
  description = "Existing virtual network name used for the Linux VM NICs."
  default     = ""
}

variable "linux_vm_vnet_id" {
  type        = string
  description = "Optional virtual network resource ID override for the Linux VM NICs."
  default     = ""
}

variable "linux_vm_vm_name" {
  type        = string
  description = "Base Linux VM name. Environment suffixes are appended by the module."
  default     = ""
}

variable "linux_vm_domain" {
  type        = string
  description = "AD domain used by the Linux VM bootstrap script when linux_vm_enable_domain_join = true."
  default     = ""
}

variable "linux_vm_domain_join_user" {
  type        = string
  description = "Domain join user in domain\\username format, used only when linux_vm_enable_domain_join = true."
  default     = ""
}

variable "linux_vm_domain_join_ou" {
  type        = string
  description = "Legacy domain join OU value retained for Linux VM module compatibility. Only relevant when linux_vm_enable_domain_join = true."
  default     = "azure"
}

variable "linux_vm_app_user_group" {
  type        = list(string)
  description = "AD groups granted Reader on the VM resource and standard SSH access inside the Linux guest OS."
  default     = [""]
}

variable "linux_vm_app_admin_group" {
  type        = list(string)
  description = "AD groups granted Contributor on the VM resource and sudo/admin access inside the Linux guest OS."
  default     = [""]
}

variable "bastion_resource_name" {
  type        = string
  description = "Optional Bastion host name that receives Network Contributor RBAC for linux_vm_app_admin_group and linux_vm_app_user_group."
  default     = ""
}

variable "bastion_resource_group_name" {
  type        = string
  description = "Resource group containing bastion_resource_name."
  default     = ""
}

variable "linux_vm_public_network_enabled" {
  type        = bool
  description = "Whether to create public IPs and NSGs for Linux VM SSH access."
  default     = false
}

# -------------------------------------------------------------------
# AKS Module Variables
# -------------------------------------------------------------------

variable "enable_aks" {
  description = "Whether to deploy the AKS module."
  type        = bool
  default     = false
}

variable "aks_name" {
  type        = string
  description = "Optional override for the AKS cluster name."
  default     = ""
}

variable "aks_dns_prefix" {
  type        = string
  description = "Optional override for the AKS DNS prefix."
  default     = ""
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Optional Kubernetes version for AKS."
  default     = null
}

variable "aks_sku_tier" {
  type        = string
  description = "AKS SKU tier."
  default     = "Free"
}

variable "aks_automatic_upgrade_channel" {
  type        = string
  description = "AKS automatic upgrade channel."
  default     = "patch"
}

variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Whether the AKS API server is private."
  default     = true
}

variable "aks_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone resource ID for AKS."
  default     = ""
}

variable "aks_private_dns_zone_name" {
  type        = string
  description = "Optional private DNS zone name for AKS lookup."
  default     = ""
}

variable "aks_private_dns_zone_resource_group_name" {
  type        = string
  description = "Optional resource group containing aks_private_dns_zone_name."
  default     = ""
}

variable "aks_role_based_access_control_enabled" {
  type        = bool
  description = "Whether Kubernetes RBAC is enabled."
  default     = true
}

variable "aks_azure_rbac_enabled" {
  type        = bool
  description = "Whether Azure RBAC for Kubernetes Authorization is enabled."
  default     = true
}

variable "aks_local_account_disabled" {
  type        = bool
  description = "Whether local AKS admin accounts are disabled."
  default     = true
}

variable "aks_oidc_issuer_enabled" {
  type        = bool
  description = "Whether the AKS OIDC issuer is enabled."
  default     = true
}

variable "aks_workload_identity_enabled" {
  type        = bool
  description = "Whether AKS Workload Identity is enabled."
  default     = true
}

variable "aks_app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive AKS admin access."
  default     = []
}

variable "aks_app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access on the AKS cluster resource."
  default     = []
}

variable "aks_terraform_execution_aks_role" {
  type        = string
  description = "Optional AKS Kubernetes RBAC role to assign to the current Terraform execution identity."
  default     = "Azure Kubernetes Service RBAC Cluster Admin"
}

variable "aks_default_node_pool" {
  description = "AKS default node pool configuration."
  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_D4s_v5")
    node_count                   = optional(number, 1)
    enable_auto_scaling          = optional(bool, false)
    min_count                    = optional(number)
    max_count                    = optional(number)
    zones                        = optional(list(string), [])
    os_disk_size_gb              = optional(number, 128)
    max_pods                     = optional(number)
    vnet_subnet_id               = optional(string)
    only_critical_addons_enabled = optional(bool, false)
    orchestrator_version         = optional(string)
    os_sku                       = optional(string, "Ubuntu")
    type                         = optional(string, "VirtualMachineScaleSets")
    upgrade_settings = optional(object({
      max_surge                     = optional(string)
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
    }))
  })
  default = {}
}

variable "aks_network_profile" {
  description = "AKS network profile configuration."
  type = object({
    network_plugin      = optional(string, "azure")
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    service_cidr        = optional(string)
    dns_service_ip      = optional(string)
    load_balancer_sku   = optional(string, "standard")
    outbound_type       = optional(string, "loadBalancer")
  })
  default = {}
}

variable "aks_enable_diagnostics" {
  type        = bool
  description = "Whether to enable diagnostics for AKS."
  default     = false
}

variable "aks_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by AKS diagnostics."
  default     = ""
}

variable "aks_diagnostic_log_categories" {
  type        = list(string)
  description = "AKS diagnostic log categories to enable."
  default     = []
}

variable "aks_diagnostic_metric_categories" {
  type        = list(string)
  description = "AKS diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "aks_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AKS cluster."
  default     = {}
}
