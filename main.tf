# -------------------------------------------------------------------
# Local Naming and Shared Values
# -------------------------------------------------------------------

locals {
  region_code_map = {
    canadacentral  = "cc"
    canadaeast     = "ce"
    eastus         = "eus"
    eastus2        = "eus2"
    centralus      = "cus"
    southcentralus = "scus"
    northcentralus = "ncus"
    westus         = "wus"
    westus2        = "wus2"
    westus3        = "wus3"
  }
  location_code           = lookup(local.region_code_map, lower(var.location), lower(var.location))
  name_suffix             = "${var.workload}-${local.location_code}-${var.environment}"
  resource_group_name     = trimspace(var.resource_group_name) != "" ? var.resource_group_name : "rg-${local.name_suffix}"
  hub_vnet_name           = trimspace(var.hub_vnet_name) != "" ? var.hub_vnet_name : "vnet-hub-${local.name_suffix}"
  spoke_vnet_name         = trimspace(var.spoke_vnet_name) != "" ? var.spoke_vnet_name : "vnet-spoke-${local.name_suffix}"
  nsg_name                = trimspace(var.nsg_name) != "" ? var.nsg_name : "nsg-${local.name_suffix}-spoke"
  managed_identity_name   = trimspace(var.managed_identity_name) != "" ? var.managed_identity_name : "id-${local.name_suffix}"
  storage_account_name    = trimspace(var.storage_account_name) != "" ? var.storage_account_name : "st${replace(var.workload, "-", "")}${local.location_code}${var.environment}"
  key_vault_name          = trimspace(var.key_vault_name) != "" ? var.key_vault_name : "kv${replace(var.workload, "-", "")}${local.location_code}${var.environment}"
  key_vault_resource_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.KeyVault/vaults/${local.key_vault_name}"
  app_registration_name   = "appreg-${local.name_suffix}"
  function_app_name       = "func-${local.name_suffix}"
  eventhub_namespace_name = "evh${replace(var.workload, "-", "")}${var.environment}"
  servicebus_name         = "sb${replace(var.workload, "-", "")}${var.environment}"
  azure_ai_service_name   = "ai-${local.name_suffix}"
  azure_ai_search_name    = "srch-${local.name_suffix}"
  openai_name             = "oai-${local.name_suffix}"
  acr_name                = replace(var.workload, "-", "")
  databricks_name         = "dbw-${local.name_suffix}"
  aks_name                = "aks-${local.name_suffix}"
  linux_jumpbox_name      = "ljb-${var.workload}"
  windows_jumpbox_name    = "wjb-${var.workload}"
  sqlmi_name              = "mi-${local.name_suffix}"
  sql_server_name         = "sql-${replace(var.workload, "-", "")}-${var.environment}"
  sql_database_name       = "sqldb_${replace(var.workload, "-", "_")}_${var.environment}"
  sql_admin_credentials_key_vault_id_effective = trimspace(var.sql_admin_credentials_key_vault_id) != "" ? var.sql_admin_credentials_key_vault_id : (
    trimspace(var.sql_iac_rg) != "" && trimspace(var.sql_iac_kv) != "" ? data.azurerm_key_vault.sql_iac[0].id : module.keyvault.id
  )
  log_analytics_name        = trimspace(var.log_analytics_name) != "" ? var.log_analytics_name : "law-${local.name_suffix}"
  log_analytics_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${local.log_analytics_name}"
  spoke_vnet_resource_id    = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.spoke_vnet_name}"
  feature_flags = {
    enable_management_group                = lookup(var.features, "enable_management_group", var.enable_management_group)
    enable_subscription_bootstrap          = lookup(var.features, "enable_subscription_bootstrap", var.enable_subscription_bootstrap)
    enable_private_dns                     = lookup(var.features, "enable_private_dns", true)
    enable_adf                             = lookup(var.features, "enable_adf", var.enable_adf)
    enable_azure_ai_search                 = lookup(var.features, "enable_azure_ai_search", var.enable_azure_ai_search)
    enable_azure_ai_service                = lookup(var.features, "enable_azure_ai_service", var.enable_azure_ai_service)
    enable_openai                          = lookup(var.features, "enable_openai", var.enable_openai)
    enable_acr                             = lookup(var.features, "enable_acr", var.enable_acr)
    enable_app_services                    = lookup(var.features, "enable_app_services", true)
    enable_app_registration_for_appservice = lookup(var.features, "enable_app_registration_for_appservice", var.enable_app_registration_for_appservice)
    enable_automation_accounts             = lookup(var.features, "enable_automation_accounts", true)
    enable_automation_ari_workloads        = lookup(var.features, "enable_automation_ari_workloads", true)
    enable_linux_vm                        = lookup(var.features, "enable_linux_vm", var.enable_linux_vm)
    enable_aks                             = lookup(var.features, "enable_aks", var.enable_aks)
    enable_sqldb                           = lookup(var.features, "enable_sqldb", var.enable_sqldb)
  }
  private_dns_zone_names_effective = local.feature_flags.enable_private_dns ? var.private_dns_zone_names : []
  spoke_subnet_resource_ids = {
    app                = "${local.spoke_vnet_resource_id}/subnets/snet-app"
    private_endpoints  = "${local.spoke_vnet_resource_id}/subnets/snet-private-endpoints"
    aks                = "${local.spoke_vnet_resource_id}/subnets/snet-aks"
    jumpbox            = "${local.spoke_vnet_resource_id}/subnets/snet-jumpbox"
    databricks_public  = "${local.spoke_vnet_resource_id}/subnets/snet-databricks-public"
    databricks_private = "${local.spoke_vnet_resource_id}/subnets/snet-databricks-private"
    sqlmi              = "${local.spoke_vnet_resource_id}/subnets/snet-sqlmi"
    vnet_integration   = "${local.spoke_vnet_resource_id}/subnets/vnet-integration"
  }
  firewall_name                = trimspace(var.firewall_name) != "" ? var.firewall_name : "afw-${local.name_suffix}"
  route_table_name             = trimspace(var.route_table_name) != "" ? var.route_table_name : "rt-${local.name_suffix}-egress"
  adf_name                     = trimspace(var.adf_name) != "" ? var.adf_name : "adf-${var.workload}-${local.location_code}-${var.environment}"
  platform_mg_name             = trimspace(var.platform_mg_name) != "" ? var.platform_mg_name : "mg-platform-${replace(local.name_suffix, "-", "")}"
  landingzone_mg_name          = trimspace(var.landingzone_mg_name) != "" ? var.landingzone_mg_name : "mg-landingzone-${replace(local.name_suffix, "-", "")}"
  sandbox_mg_name              = trimspace(var.sandbox_mg_name) != "" ? var.sandbox_mg_name : "mg-sandboxes"
  platform_mg_display          = trimspace(var.platform_mg_display) != "" ? var.platform_mg_display : "Platform ${upper(var.environment)}"
  landingzone_mg_display       = trimspace(var.landingzone_mg_display) != "" ? var.landingzone_mg_display : "Landing Zone ${upper(var.environment)}"
  sandbox_mg_display           = trimspace(var.sandbox_mg_display) != "" ? var.sandbox_mg_display : "Sandboxes"
  effective_subscription_mg_id = trimspace(var.subscription_management_group_id) != "" ? var.subscription_management_group_id : try(module.mg_landingzone[0].id, "")

  linux_vm_suffix_map = {
    prod = "001"
    qa   = "301"
    dev  = "601"
    poc  = "701"
    test = "801"
    sbx  = "901"
  }
  linux_vm_suffix_base = tonumber(lookup(local.linux_vm_suffix_map, var.linux_vm_app_env, "000"))
  linux_vm_names = [
    for vm_index in range(var.linux_vm_vm_count) :
    "${local.linux_jumpbox_name}${format("%03d", local.linux_vm_suffix_base + vm_index)}"
  ]
  enabled_app_services = local.feature_flags.enable_app_services ? {
    for key, app_service in var.app_services :
    key => merge(app_service, {
      stack                       = lower(app_service.stack)
      deployment_method_effective = try(app_service.deployment_method, null) != null ? app_service.deployment_method : (try(app_service.deployment_center_enabled, false) ? "deployment_center" : "run_from_package")
      deployment_method_app_settings = (
        try(app_service.deployment_method, null) != null ? app_service.deployment_method : (try(app_service.deployment_center_enabled, false) ? "deployment_center" : "run_from_package")
        ) == "run_from_package" ? {
        WEBSITE_RUN_FROM_PACKAGE       = "1"
        SCM_DO_BUILD_DURING_DEPLOYMENT = "false"
        ENABLE_ORYX_BUILD              = "false"
        } : (
        (try(app_service.deployment_method, null) != null ? app_service.deployment_method : (try(app_service.deployment_center_enabled, false) ? "deployment_center" : "run_from_package")) == "deployment_center" ||
        (try(app_service.deployment_method, null) != null ? app_service.deployment_method : (try(app_service.deployment_center_enabled, false) ? "deployment_center" : "run_from_package")) == "zip_deploy_with_build"
        ) ? {
        SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
        ENABLE_ORYX_BUILD              = "true"
      } : {}
      app_name         = "web-${local.name_suffix}-${key}"
      plan_name        = "asp-${local.name_suffix}-${key}"
      default_hostname = "web-${local.name_suffix}-${key}.azurewebsites.net"
    })
    if app_service.enabled
  } : {}

  enabled_automation_accounts = local.feature_flags.enable_automation_accounts ? {
    for key, automation_account in var.automation_accounts :
    key => merge(automation_account, {
      automation_account_name = try(trimspace(automation_account.name), "") != "" ? trimspace(automation_account.name) : "aa-${local.name_suffix}-${key}"
      private_endpoint_subnet_id_effective = try(automation_account.private_endpoint_enabled, false) ? (
        try(trimspace(automation_account.private_endpoint_subnet_id), "") != "" ? trimspace(automation_account.private_endpoint_subnet_id) : module.spoke_virtual_network.subnet_ids["snet-private-endpoints"]
      ) : ""
      private_dns_zone_id_effective = try(trimspace(automation_account.private_dns_zone_id), "") != "" ? trimspace(automation_account.private_dns_zone_id) : (
        try(automation_account.private_endpoint_enabled, false) && contains(local.private_dns_zone_names_effective, "privatelink.azure-automation.net") ? try(module.private_dns.zone_ids["privatelink.azure-automation.net"], "") : ""
      )
    })
    if automation_account.enabled
  } : {}

  automation_ari_default_runtime_packages = {
    AzureResourceInventory           = "https://www.powershellgallery.com/api/v2/package/AzureResourceInventory/3.6.11"
    ImportExcel                      = "https://www.powershellgallery.com/api/v2/package/ImportExcel/7.8.10"
    "Microsoft.PowerShell.ThreadJob" = "https://www.powershellgallery.com/api/v2/package/Microsoft.PowerShell.ThreadJob/2.2.0"
    "Az.Accounts"                    = "https://www.powershellgallery.com/api/v2/package/Az.Accounts/5.3.3"
    "Az.Compute"                     = "https://www.powershellgallery.com/api/v2/package/Az.Compute/11.4.0"
    "Az.Storage"                     = "https://www.powershellgallery.com/api/v2/package/Az.Storage/9.6.0"
    "Az.ResourceGraph"               = "https://www.powershellgallery.com/api/v2/package/Az.ResourceGraph/1.2.1"
    "Az.CostManagement"              = "https://www.powershellgallery.com/api/v2/package/Az.CostManagement/0.4.2"
  }

  enabled_automation_ari_workloads = local.feature_flags.enable_automation_accounts && local.feature_flags.enable_automation_ari_workloads ? {
    for key, workload in var.automation_ari_workloads :
    key => merge(workload, {
      automation_account_name_effective              = try(local.enabled_automation_accounts[workload.automation_account_key].automation_account_name, "")
      storage_container_name_effective               = try(trimspace(workload.storage_container_name), "") != "" ? trimspace(workload.storage_container_name) : "ari"
      report_name_effective                          = try(trimspace(workload.report_name), "") != "" ? trimspace(workload.report_name) : "AZURE"
      report_dir_effective                           = try(trimspace(workload.report_dir), "") != "" ? trimspace(workload.report_dir) : "C:\\AzureResourceInventory"
      ari_lite_mode_effective                        = try(workload.ari_lite_mode, false)
      ari_diagram_full_environment_enabled_effective = try(workload.ari_diagram_full_environment_enabled, true)
      ari_security_center_enabled_effective          = try(workload.ari_security_center_enabled, true)
      runbook_name_effective                         = try(trimspace(workload.runbook_name), "") != "" ? trimspace(workload.runbook_name) : "ARI_Runbook"
      runtime_environment_name_effective             = try(trimspace(workload.runtime_environment_name), "") != "" ? trimspace(workload.runtime_environment_name) : "PowerShell-7.4-Env"
      runbook_template_path_effective                = try(trimspace(workload.runbook_template_path), "") != "" ? trimspace(workload.runbook_template_path) : "runbooks/ari.ps1.tftpl"
      runtime_packages_effective                     = length(try(workload.runtime_packages, {})) > 0 ? workload.runtime_packages : local.automation_ari_default_runtime_packages
      schedule_name_effective                        = try(trimspace(workload.schedule_name), "") != "" ? trimspace(workload.schedule_name) : "Azure Inventory Collection - daily"
      schedule_description_effective                 = try(trimspace(workload.schedule_description), "") != "" ? trimspace(workload.schedule_description) : "Daily schedule for the ARI runbook."
      schedule_start_time_effective                  = try(trimspace(workload.schedule_start_time), "") != "" ? trimspace(workload.schedule_start_time) : "${substr(timeadd(timestamp(), "24h"), 0, 10)}T08:00:00-04:00"
      job_failure_alert_name_effective               = try(trimspace(workload.job_failure_alert_name), "") != "" ? trimspace(workload.job_failure_alert_name) : "ara-${local.name_suffix}-${key}-job-failure"
      long_running_alert_name_effective              = try(trimspace(workload.long_running_alert_name), "") != "" ? trimspace(workload.long_running_alert_name) : "ara-${local.name_suffix}-${key}-long-running"
    })
    if workload.enabled
  } : {}

  app_registration_display_name_override = var.app_registration_display_name == null ? "" : trimspace(var.app_registration_display_name)
  app_registration_display_names = {
    for key, app_service in local.enabled_app_services :
    key => local.app_registration_display_name_override != "" ? "${local.app_registration_display_name_override}-${key}" : "${local.app_registration_name}-${key}"
  }
  effective_enable_app_registration_for_appservice = local.feature_flags.enable_app_services && local.feature_flags.enable_app_registration_for_appservice && var.enable_app_registration_for_appservice
  effective_app_service_auth_mode                  = local.effective_enable_app_registration_for_appservice ? (var.app_service_auth_mode == "none" ? "msal" : var.app_service_auth_mode) : "none"
  app_service_platform_auth_enabled                = contains(["easy_auth", "both"], local.effective_app_service_auth_mode)
  app_registration_generated_redirect_uri_hostnames = {
    for key, app_service in local.enabled_app_services :
    key => length(var.app_registration_web_redirect_uris) > 0 ? [] : [app_service.default_hostname]
  }

  mg_platform_hierarchy = {
    for key, child in var.mg_platform_children :
    key => {
      name         = "mg-${replace(var.workload, "-", "")}-${key}"
      display_name = child.display_name
    }
  }
  mg_landingzone_hierarchy = {
    for key, child in var.mg_landingzone_children :
    key => {
      name         = "mg-${replace(var.workload, "-", "")}-${key}"
      display_name = child.display_name
    }
  }
  subscription_management_group_ids = merge(
    {
      platform    = try(module.mg_platform[0].id, "")
      landingzone = try(module.mg_landingzone[0].id, "")
      sandboxes   = try(module.mg_sandboxes[0].id, "")
    },
    { for key, group in module.mg_platform_children : key => group.id },
    { for key, group in module.mg_landingzone_children : key => group.id }
  )

  hierarchy_subscription_management_group_keys = {
    for key, subscription in var.hierarchy_subscriptions :
    key => try(trimspace(subscription.management_group_key), "") != "" ? subscription.management_group_key : key
  }

  hierarchy_subscription_targets = {
    for key, subscription in var.hierarchy_subscriptions :
    key => subscription
    if contains(keys(local.subscription_management_group_ids), local.hierarchy_subscription_management_group_keys[key])
  }

  spoke_nsg_subnet_ids = {
    app                = module.spoke_virtual_network.subnet_ids["snet-app"]
    aks                = module.spoke_virtual_network.subnet_ids["snet-aks"]
    jumpbox            = module.spoke_virtual_network.subnet_ids["snet-jumpbox"]
    databricks_public  = module.spoke_virtual_network.subnet_ids["snet-databricks-public"]
    databricks_private = module.spoke_virtual_network.subnet_ids["snet-databricks-private"]
  }

  private_dns_zones = {
    for zone_name in local.private_dns_zone_names_effective :
    zone_name => {
      vnet_links = {
        # hub = {
        #   virtual_network_id   = module.hub_virtual_network.id
        #   registration_enabled = false
        #   tags                 = {}
        # }
        spoke = {
          virtual_network_id   = module.spoke_virtual_network.id
          registration_enabled = false
          tags                 = {}
        }
      }
      a_records = {}
    }
  }

  common_tags = merge(
    var.rg_tags,
    {
      Workload = var.workload
    }
  )

  linux_vm_key_vault_secret_override_values = {
    "azure-user"        = var.linux_vm_admin_username
    "azure-password"    = var.linux_vm_admin_password
    "azureadmin-pubkey" = var.linux_vm_admin_ssh_key
  }

  linux_vm_key_vault_secret_override_names = toset([
    for secret_name, secret_value in local.linux_vm_key_vault_secret_override_values :
    secret_name
    if nonsensitive(trimspace(secret_value)) != ""
  ])

  storage_account_blob_service_properties = {
    changeFeed = merge(
      {
        enabled = var.storage_account_change_feed_enabled
      },
      var.storage_account_change_feed_retention_in_days != null ? {
        retentionInDays = var.storage_account_change_feed_retention_in_days
      } : {}
    )
    deleteRetentionPolicy = {
      allowPermanentDelete = false
      days                 = var.storage_account_blob_soft_delete_retention_days
      enabled              = var.storage_account_blob_soft_delete_enabled
    }
    containerDeleteRetentionPolicy = {
      allowPermanentDelete = false
      days                 = var.storage_account_container_soft_delete_retention_days
      enabled              = var.storage_account_container_soft_delete_enabled
    }
    isVersioningEnabled = var.storage_account_blob_versioning_enabled
  }

  storage_account_blob_service_properties_effective = merge(
    local.storage_account_blob_service_properties,
    var.storage_account_blob_restore_policy_enabled ? {
      restorePolicy = {
        days    = var.storage_account_blob_restore_policy_days
        enabled = true
      }
    } : {}
  )

  # Ensure the shared IaC/script containers exist in the landing zone storage account
  # (default name: stplatformccsbx) so downstream Linux VM/bootstrap flows can rely on them.
  shared_storage_container_names = toset([
    "localization",
    "scripts",
    "terraform"
  ])
}

# -------------------------------------------------------------------
# Azure Provider Context
# -------------------------------------------------------------------

data "azurerm_client_config" "current" {}

# -------------------------------------------------------------------
# Governance: Management Groups
# -------------------------------------------------------------------

module "mg_platform" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"
  #source = "./modules/template/modules/managementgroups"

  name                       = local.platform_mg_name
  display_name               = local.platform_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.common_tags
}
module "mg_landingzone" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"
  #source = "../template/modules/managementgroups"

  name                       = local.landingzone_mg_name
  display_name               = local.landingzone_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.common_tags
}
module "mg_sandboxes" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"
  #source = "../template/modules/managementgroups"

  name                       = local.sandbox_mg_name
  display_name               = local.sandbox_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.common_tags
}
module "mg_platform_children" {
  for_each = local.feature_flags.enable_management_group ? local.mg_platform_hierarchy : {}
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"
  #source  = "../template/modules/managementgroups"

  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = module.mg_platform[0].id
  subscription_ids           = []
  tags                       = local.common_tags
}
module "mg_landingzone_children" {
  for_each = local.feature_flags.enable_management_group ? local.mg_landingzone_hierarchy : {}
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"
  #source  = "../template/modules/managementgroups"

  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = module.mg_landingzone[0].id
  subscription_ids           = []
  tags                       = local.common_tags
}

# -------------------------------------------------------------------
# Governance: Subscription Vending
# -------------------------------------------------------------------

module "subscription_vending" {
  for_each = local.feature_flags.enable_subscription_bootstrap && local.feature_flags.enable_management_group ? local.hierarchy_subscription_targets : {}
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/subscription_vending?ref=main"
  #source  = "../template/modules/subscription_vending"

  subscription_alias_enabled          = try(each.value.subscription_alias_enabled, false)
  subscription_alias_name             = try(each.value.subscription_alias_name, "")
  subscription_name                   = each.value.subscription_name
  billing_scope_id                    = try(each.value.billing_scope_id, "")
  existing_subscription_id            = each.value.existing_subscription_id
  enable_management_group_association = true
  management_group_id                 = local.subscription_management_group_ids[local.hierarchy_subscription_management_group_keys[each.key]]
  resource_provider_registrations     = var.subscription_resource_provider_registrations
  bootstrap_resource_groups           = {}
  tags                                = local.common_tags
}

# -------------------------------------------------------------------
# Foundation: Resource Group
# -------------------------------------------------------------------

module "resource_group" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/rg?ref=main"
  #source = "../template/modules/rg"

  name            = local.resource_group_name
  location        = var.location
  enable_lock     = false
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.common_tags
}

# -------------------------------------------------------------------
# Foundation: Log Analytics Workspace
# -------------------------------------------------------------------

module "log_analytics" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/loganalytics?ref=main"
  #source = "../template/modules/loganalytics"

  name                               = local.log_analytics_name
  resource_group_name                = module.resource_group.name
  location                           = module.resource_group.location
  retention_in_days                  = var.log_analytics_retention_in_days
  internet_ingestion_enabled         = var.log_analytics_internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics_internet_query_enabled
  local_authentication_disabled      = var.log_analytics_local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.log_analytics_reservation_capacity_in_gb_per_day
  tags                               = local.common_tags
}

# -------------------------------------------------------------------
# Network: Hub Virtual Network
# -------------------------------------------------------------------

module "hub_virtual_network" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/vnet?ref=main"
  #source = "../template/modules/vnet"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = local.hub_vnet_name
  address_space       = var.hub_address_space

  subnets = {
    AzureFirewallSubnet = {
      address_prefixes                  = var.firewall_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
    }
  }

  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.common_tags

  depends_on = [module.resource_group]
}

# -------------------------------------------------------------------
# Network: Spoke Virtual Network
# -------------------------------------------------------------------

module "spoke_virtual_network" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/vnet?ref=main"
  #source = "../template/modules/vnet"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = local.spoke_vnet_name
  address_space       = var.spoke_address_space

  subnets = {
    snet-app = {
      address_prefixes                  = var.app_subnet_prefixes
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Enabled"
    }
    snet-private-endpoints = {
      address_prefixes                  = var.private_endpoint_subnet_prefixes
      private_endpoint_network_policies = "Disabled"
    }
    snet-databricks-public = {
      address_prefixes                  = var.databricks_public_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
      delegations = {
        databricks = {
          name                    = "databricks-public"
          service_delegation_name = "Microsoft.Databricks/workspaces"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/join/action"
          ]
        }
      }
    }
    snet-databricks-private = {
      address_prefixes                  = var.databricks_private_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
      delegations = {
        databricks = {
          name                    = "databricks-private"
          service_delegation_name = "Microsoft.Databricks/workspaces"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/join/action"
          ]
        }
      }
    }
    snet-aks = {
      address_prefixes                  = var.aks_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    snet-jumpbox = {
      address_prefixes                  = var.jumpbox_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
    }
    snet-sqlmi = {
      address_prefixes                  = var.sqlmi_subnet_prefixes
      private_endpoint_network_policies = "Enabled"
      delegations = {
        sqlmi = {
          name                    = "sqlmi-delegation"
          service_delegation_name = "Microsoft.Sql/managedInstances"
          actions                 = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
        }
      }
    }
    vnet-integration = {
      address_prefixes = var.vnet_integration_prefixes
    }
  }

  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.common_tags

  depends_on = [module.resource_group]
}

# -------------------------------------------------------------------
# Network: Hub and Spoke Peering
# -------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "peer-${module.hub_virtual_network.name}-to-${module.spoke_virtual_network.name}"
  resource_group_name          = module.resource_group.name
  virtual_network_name         = module.hub_virtual_network.name
  remote_virtual_network_id    = module.spoke_virtual_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    module.hub_virtual_network,
    module.spoke_virtual_network,
    azurerm_subnet_network_security_group_association.spoke_network_security_group
  ]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-${module.spoke_virtual_network.name}-to-${module.hub_virtual_network.name}"
  resource_group_name          = module.resource_group.name
  virtual_network_name         = module.spoke_virtual_network.name
  remote_virtual_network_id    = module.hub_virtual_network.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  depends_on = [
    module.hub_virtual_network,
    module.spoke_virtual_network,
    azurerm_subnet_network_security_group_association.spoke_network_security_group
  ]
}

# -------------------------------------------------------------------
# Network Security: Spoke NSG
# -------------------------------------------------------------------

module "network_security_group" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/nsg?ref=main"
  #source = "../template/modules/nsg"

  name                = local.nsg_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  security_rules = {
    allow_https_in = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "107.171.157.217/32" # TODO: parameterize or remove this source address prefix to allow from anywhere
      destination_address_prefix = "*"
      description                = "Allow HTTPS inbound to workloads in the app subnet."
    }

    allow_ssh_in = {
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "107.171.157.217/32" # TODO: parameterize or remove this source address prefix to allow from anywhere
      destination_address_prefix = "*"
      description                = "Allow SSH inbound to workloads in the app subnet."
    }

    allow_vnet_in = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow east-west traffic within the landing zone virtual network."
    }
  }

  subnet_ids = []

  tags = local.common_tags
}

resource "azurerm_subnet_network_security_group_association" "spoke_network_security_group" {
  for_each = local.spoke_nsg_subnet_ids

  subnet_id                 = each.value
  network_security_group_id = module.network_security_group.id

  depends_on = [
    module.network_security_group,
    module.spoke_virtual_network
  ]
}

# -------------------------------------------------------------------
# Optional Network Services: Firewall and Private DNS
# -------------------------------------------------------------------

# module "firewall" {
#   source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/firewall?ref=main"

#   name                = local.firewall_name
#   resource_group_name = module.resource_group.name
#   location            = module.resource_group.location
#   subnet_id           = module.hub_virtual_network.subnet_ids["AzureFirewallSubnet"]
#   sku_tier            = var.firewall_sku_tier
#   tags                = local.common_tags
# }

module "private_dns" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/private_dns?ref=main"
  #source = "../template/modules/private_dns"

  resource_group_name = module.resource_group.name
  zones               = local.private_dns_zones
  tags                = local.common_tags
}

# -------------------------------------------------------------------
# Data Foundation: Storage Account
# -------------------------------------------------------------------

module "storage_account" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/storageaccount?ref=main"
  #source = "../template/modules/storageaccount"

  # providers = {
  #   azurerm      = azurerm
  #   azurerm.prod = azurerm.prod
  # }

  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  name                          = local.storage_account_name
  public_network_access_enabled = true
  enable_network_rules          = false
  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  tags                          = local.common_tags

  depends_on = [module.resource_group]
}


# -------------------------------------------------------------------
# Data Foundation: Key Vault
# -------------------------------------------------------------------

module "keyvault" {
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/keyvault?ref=main"
  #source = "../template/modules/keyvault"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  name                          = local.key_vault_name
  tenant_id                     = ""
  enable_rbac_authorization     = true
  public_network_access_enabled = true
  enable_network_acls           = false
  enable_private_endpoint       = false
  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  tags                          = local.common_tags

  depends_on = [module.resource_group]
}

resource "azapi_update_resource" "storage_account_blob_service" {
  type        = "Microsoft.Storage/storageAccounts/blobServices@2025-01-01"
  resource_id = "${module.storage_account.id}/blobServices/default"

  body = {
    properties = local.storage_account_blob_service_properties_effective
  }

  depends_on = [module.storage_account]
}

resource "azurerm_key_vault_secret" "linux_vm_admin_override" {
  for_each = local.linux_vm_key_vault_secret_override_names

  name         = each.key
  value        = local.linux_vm_key_vault_secret_override_values[each.key]
  key_vault_id = module.keyvault.id

  depends_on = [module.keyvault]
}

# -------------------------------------------------------------------
# App Service: Hosting Plan
# -------------------------------------------------------------------

module "app_service_plan" {
  for_each = local.enabled_app_services
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appserviceplan?ref=main"
  #source  = "../template/modules/appserviceplan"

  name                = each.value.plan_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = each.value.plan_os_type
  sku_name            = each.value.sku_name

  enable_diagnostics         = var.app_service_plan_enable_diagnostics
  log_analytics_workspace_id = var.app_service_plan_enable_diagnostics ? local.log_analytics_resource_id : null
  diagnostic_metrics         = ["AllMetrics"]

  enable_autoscale                   = var.app_service_plan_enable_autoscale
  autoscale_min_capacity             = var.app_service_plan_autoscale_min_capacity
  autoscale_default_capacity         = var.app_service_plan_autoscale_default_capacity
  autoscale_max_capacity             = var.app_service_plan_autoscale_max_capacity
  autoscale_cpu_threshold_scale_up   = var.app_service_plan_autoscale_cpu_threshold_scale_up
  autoscale_cpu_threshold_scale_down = var.app_service_plan_autoscale_cpu_threshold_scale_down
  autoscale_scale_up_increment       = var.app_service_plan_autoscale_scale_up_increment
  autoscale_scale_down_increment     = var.app_service_plan_autoscale_scale_down_increment

  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.common_tags

  depends_on = [module.resource_group, module.log_analytics]
}

# -------------------------------------------------------------------
# App Service: Entra App Registration
# -------------------------------------------------------------------

module "app_registration_appservice" {
  for_each = local.effective_enable_app_registration_for_appservice ? local.enabled_app_services : {}
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appregistration?ref=main"
  #source  = "../template/modules/appregistration"

  display_name                        = local.app_registration_display_names[each.key]
  web_redirect_uris                   = var.app_registration_web_redirect_uris
  app_service_redirect_hostnames      = local.app_registration_generated_redirect_uri_hostnames[each.key]
  app_service_auth_mode               = local.effective_app_service_auth_mode
  create_service_principal            = true
  create_client_secret                = var.app_registration_create_client_secret
  add_current_caller_as_owner         = true
  key_vault_id                        = var.app_registration_create_client_secret ? local.key_vault_resource_id : null
  client_secret_key_vault_secret_name = var.app_registration_create_client_secret ? local.app_registration_display_names[each.key] : null
  depends_on = [
    module.app_service_plan,
    module.keyvault
  ]
}

# -------------------------------------------------------------------
# App Service: Web App
# -------------------------------------------------------------------

# Module label is retained for state/module-cache continuity; for_each provisions every enabled stack.
module "app_service" {
  for_each = local.enabled_app_services
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appservice?ref=main"
  #source  = "../template/modules/appservice"


  app_name            = each.value.app_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  app_service_plan_id = module.app_service_plan[each.key].id

  kind                       = each.value.kind
  log_analytics_workspace_id = local.log_analytics_resource_id

  auth_mode                  = local.effective_app_service_auth_mode
  allow_anonymous            = var.app_service_allow_anonymous
  unauthenticated_action     = var.app_service_unauthenticated_action
  active_directory_client_id = local.effective_enable_app_registration_for_appservice ? module.app_registration_appservice[each.key].application_id : null

  app_settings = merge(
    {
      AAD_TENANT_ID     = data.azurerm_client_config.current.tenant_id
      AAD_REDIRECT_PATH = "/auth/callback"
      AAD_SCOPES        = "User.Read"
      APP_SECRET_KEY    = var.app_service_app_secret_key
    },
    local.effective_enable_app_registration_for_appservice ? {
      AAD_CLIENT_ID = module.app_registration_appservice[each.key].application_id
    } : {},
    local.effective_enable_app_registration_for_appservice && var.app_registration_create_client_secret ? {
      AAD_CLIENT_SECRET                        = module.app_registration_appservice[each.key].client_secret
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET = module.app_registration_appservice[each.key].client_secret
    } : {},
    var.app_service_app_settings,
    each.value.app_settings,
    each.value.deployment_method_app_settings
  )

  enable_private_endpoint              = var.app_service_enable_private_endpoint
  private_endpoint_subnet_id           = var.app_service_enable_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  private_dns_zone_name                = var.app_service_enable_private_endpoint ? "privatelink.azurewebsites.net" : null
  private_dns_zone_resource_group_name = var.app_service_enable_private_endpoint ? module.resource_group.name : null
  public_network_access_enabled        = var.app_service_public_network_access_enabled
  ip_restrictions                      = var.app_service_ip_restrictions
  ip_restriction_default_action        = var.app_service_ip_restriction_default_action
  scm_ip_restrictions                  = var.app_service_scm_ip_restrictions
  scm_ip_restriction_default_action    = var.app_service_scm_ip_restriction_default_action
  scm_use_main_ip_restriction          = var.app_service_scm_use_main_ip_restriction
  scmIpSecurityRestrictionsUseMain     = var.app_service_scmIpSecurityRestrictionsUseMain

  virtual_network_subnet_id = var.app_service_vnet_integration_enabled ? local.spoke_subnet_resource_ids.app : null
  vnet_route_all_enabled    = var.app_service_vnet_route_all_enabled
  websockets_enabled        = true
  use_32_bit_worker         = coalesce(try(each.value.use_32_bit_worker, null), contains(["F1", "D1"], upper(each.value.sku_name)))

  scm_basic_auth_publishing_credentials_enabled  = var.app_service_scm_basic_auth_publishing_credentials_enabled
  webdeploy_publish_basic_authentication_enabled = var.app_service_webdeploy_publish_basic_authentication_enabled

  deployment_center_enabled                  = each.value.deployment_method_effective == "deployment_center"
  deployment_center_azure_repos_organization = try(each.value.deployment_center_azure_repos_organization, null)
  deployment_center_azure_repos_project      = try(each.value.deployment_center_azure_repos_project, null)
  deployment_center_azure_repos_repository   = try(each.value.deployment_center_azure_repos_repository, null)
  deployment_center_azure_repos_branch       = try(each.value.deployment_center_azure_repos_branch, "main")
  deployment_center_use_manual_integration   = try(each.value.deployment_center_use_manual_integration, true)
  system_assigned_identity_enabled           = true

  application_stack = merge(
    {
      current_stack = each.value.stack
    },
    each.value.stack == "dotnet" ? {
      dotnet_version = each.value.dotnet_version
    } : {},
    each.value.stack == "node" ? {
      node_version = each.value.node_version
    } : {},
    each.value.stack == "python" ? {
      python_version = each.value.python_version
    } : {}
  )

  app_env         = var.environment
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.common_tags

  depends_on = [
    module.app_service_plan,
    module.keyvault,
    module.log_analytics,
    module.private_dns,
    module.spoke_virtual_network
  ]
}

# -------------------------------------------------------------------
# Automation Account
# -------------------------------------------------------------------

module "automation_account" {
  for_each = local.enabled_automation_accounts
  source   = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/automationaccount?ref=main"
  #source  = "../template/modules/automationaccount"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = each.value.automation_account_name
  sku_name            = each.value.sku_name

  local_auth_enabled              = each.value.local_auth_enabled
  public_access_enabled           = each.value.public_access_enabled
  system_managed_identity_enabled = each.value.system_managed_identity_enabled

  app_admin_group                   = length(each.value.app_admin_group) > 0 ? each.value.app_admin_group : var.app_admin_group
  app_user_group                    = length(each.value.app_user_group) > 0 ? each.value.app_user_group : var.app_user_group
  managed_identity_role_assignments = each.value.managed_identity_role_assignments

  private_endpoint_subresource_name            = each.value.private_endpoint_subresource_name
  enable_webhook_private_endpoint              = try(each.value.enable_webhook_private_endpoint, null)
  enable_hrw_private_endpoint                  = try(each.value.enable_hrw_private_endpoint, null)
  private_endpoint_subnet_id                   = each.value.private_endpoint_subnet_id_effective
  private_endpoint_subnet_name                 = try(each.value.private_endpoint_subnet_name, null)
  private_endpoint_vnet_name                   = try(each.value.private_endpoint_vnet_name, null)
  private_endpoint_network_resource_group_name = try(each.value.private_endpoint_network_resource_group_name, null)
  private_dns_zone_id                          = each.value.private_dns_zone_id_effective

  enable_diagnostics           = each.value.enable_diagnostics
  log_analytics_workspace_id   = each.value.enable_diagnostics ? local.log_analytics_resource_id : ""
  diagnostic_log_categories    = each.value.diagnostic_log_categories
  diagnostic_metric_categories = each.value.diagnostic_metric_categories

  tags = merge(local.common_tags, each.value.tags)

  depends_on = [
    module.resource_group,
    module.log_analytics,
    module.private_dns,
    module.spoke_virtual_network
  ]
}

# -------------------------------------------------------------------
# Automation Account: Root RBAC
# -------------------------------------------------------------------

resource "azurerm_role_assignment" "automation_account_storage_blob_data_contributor" {
  for_each = {
    for key, automation_account in local.enabled_automation_accounts :
    key => automation_account
    if try(automation_account.system_managed_identity_enabled, true)
  }

  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.automation_account[each.key].principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    module.storage_account,
    module.automation_account
  ]
}

resource "azurerm_role_assignment" "automation_account_key_vault_secrets_officer" {
  for_each = {
    for key, automation_account in local.enabled_automation_accounts :
    key => automation_account
    if try(automation_account.system_managed_identity_enabled, true)
  }

  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = module.automation_account[each.key].principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    module.keyvault,
    module.automation_account
  ]
}

# -------------------------------------------------------------------
# Automation ARI: Storage and Runtime
# -------------------------------------------------------------------

resource "azapi_resource" "shared_storage_container" {
  for_each = local.shared_storage_container_names

  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01"
  name      = each.value
  parent_id = "${module.storage_account.id}/blobServices/default"

  body = {
    properties = {
      publicAccess = "None"
    }
  }

  depends_on = [
    module.storage_account,
    azapi_update_resource.storage_account_blob_service
  ]
}

resource "azapi_resource" "shared_storage_container_immutability_policy" {
  for_each = var.storage_account_container_immutability_policies

  type      = "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2025-01-01"
  name      = "default"
  parent_id = "${module.storage_account.id}/blobServices/default/containers/${each.key}"

  body = {
    properties = {
      allowProtectedAppendWrites            = try(each.value.allow_protected_append_writes, false)
      allowProtectedAppendWritesAll         = try(each.value.allow_protected_append_writes_all, false)
      immutabilityPeriodSinceCreationInDays = each.value.immutability_period_since_creation_in_days
    }
  }

  depends_on = [
    azapi_resource.shared_storage_container,
    azapi_update_resource.storage_account_blob_service
  ]
}

resource "azurerm_storage_container" "automation_ari" {
  for_each = {
    for container_name in distinct([
      for _, workload in local.enabled_automation_ari_workloads :
      workload.storage_container_name_effective
    ]) :
    container_name => container_name
  }

  name                  = each.value
  storage_account_id    = module.storage_account.id
  container_access_type = "private"

  depends_on = [
    module.storage_account
  ]
}

resource "azurerm_automation_runtime_environment" "automation_ari" {
  for_each = local.enabled_automation_ari_workloads

  name                  = each.value.runtime_environment_name_effective
  automation_account_id = module.automation_account[each.value.automation_account_key].id
  location              = module.resource_group.location
  runtime_language      = "PowerShell"
  runtime_version       = "7.4"

  depends_on = [
    module.automation_account
  ]
}

resource "azapi_resource" "automation_ari_runtime_package" {
  for_each = {
    for package in flatten([
      for workload_key, workload in local.enabled_automation_ari_workloads : [
        for package_name, package_uri in workload.runtime_packages_effective : {
          key          = "${workload_key}/${package_name}"
          workload_key = workload_key
          name         = package_name
          uri          = package_uri
        }
      ]
    ]) :
    package.key => {
      workload_key = package.workload_key
      name         = package.name
      uri          = package.uri
    }
  }

  type      = "Microsoft.Automation/automationAccounts/runtimeEnvironments/packages@2024-10-23"
  name      = each.value.name
  parent_id = azurerm_automation_runtime_environment.automation_ari[each.value.workload_key].id

  body = {
    allOf      = { location = module.resource_group.location }
    properties = { contentLink = { uri = each.value.uri } }
  }

  depends_on = [
    azurerm_automation_runtime_environment.automation_ari
  ]
}

# -------------------------------------------------------------------
# Automation ARI: Runbook and Schedule
# -------------------------------------------------------------------

resource "azurerm_automation_runbook" "automation_ari" {
  for_each = local.enabled_automation_ari_workloads

  name                     = each.value.runbook_name_effective
  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  automation_account_name  = module.automation_account[each.value.automation_account_key].name
  runbook_type             = "PowerShell"
  runtime_environment_name = azurerm_automation_runtime_environment.automation_ari[each.key].name
  log_verbose              = each.value.runbook_log_verbose
  log_progress             = each.value.runbook_log_progress
  description              = "Runs Azure Resource Inventory and writes output to the configured blob container."

  content = templatefile("${path.module}/${each.value.runbook_template_path_effective}", {
    tenant_id                            = data.azurerm_client_config.current.tenant_id
    storage_account_name                 = module.storage_account.name
    storage_container                    = azurerm_storage_container.automation_ari[each.value.storage_container_name_effective].name
    report_name                          = each.value.report_name_effective
    report_dir                           = each.value.report_dir_effective
    ari_lite_mode                        = each.value.ari_lite_mode_effective ? "$true" : "$false"
    ari_diagram_full_environment_enabled = each.value.ari_diagram_full_environment_enabled_effective ? "$true" : "$false"
    ari_security_center_enabled          = each.value.ari_security_center_enabled_effective ? "$true" : "$false"
  })

  depends_on = [
    module.automation_account,
    azurerm_storage_container.automation_ari,
    azapi_resource.automation_ari_runtime_package
  ]
  tags = merge(local.common_tags, each.value.tags)
}

resource "azurerm_automation_schedule" "automation_ari" {
  for_each = {
    for key, workload in local.enabled_automation_ari_workloads :
    key => workload
    if try(workload.schedule_enabled, true)
  }

  name                    = each.value.schedule_name_effective
  resource_group_name     = module.resource_group.name
  automation_account_name = module.automation_account[each.value.automation_account_key].name
  frequency               = each.value.schedule_frequency
  interval                = each.value.schedule_interval
  timezone                = each.value.schedule_timezone
  start_time              = each.value.schedule_start_time_effective
  description             = each.value.schedule_description_effective

  lifecycle {
    ignore_changes = [start_time]
  }

  depends_on = [
    module.automation_account
  ]
}

resource "azurerm_automation_job_schedule" "automation_ari" {
  for_each = {
    for key, workload in local.enabled_automation_ari_workloads :
    key => workload
    if try(workload.schedule_enabled, true)
  }

  resource_group_name     = module.resource_group.name
  automation_account_name = module.automation_account[local.enabled_automation_ari_workloads[each.key].automation_account_key].name
  schedule_name           = azurerm_automation_schedule.automation_ari[each.key].name
  runbook_name            = azurerm_automation_runbook.automation_ari[each.key].name

  depends_on = [
    azurerm_automation_schedule.automation_ari,
    azurerm_automation_runbook.automation_ari
  ]
}

# -------------------------------------------------------------------
# Automation ARI: Monitoring
# -------------------------------------------------------------------

# resource "azurerm_monitor_scheduled_query_rules_alert_v2" "automation_ari_job_failure" {
#   for_each = {
#     for key, workload in local.enabled_automation_ari_workloads :
#     key => workload
#     if try(workload.enable_job_failure_alert, true)
#   }

#   name                    = each.value.job_failure_alert_name_effective
#   resource_group_name     = module.resource_group.name
#   location                = module.resource_group.location
#   scopes                  = [local.log_analytics_resource_id]
#   severity                = each.value.job_failure_severity
#   evaluation_frequency    = each.value.alert_evaluation_frequency
#   window_duration         = each.value.alert_window_duration
#   enabled                 = true
#   auto_mitigation_enabled = true
#   skip_query_validation   = true
#   description             = "Alerts when the ARI runbook fails, stops, or is suspended."
#   display_name            = "ARI runbook failure - ${each.key}"
#   tags                    = merge(local.common_tags, each.value.tags)

#   criteria {
#     query                   = <<-KQL
#       AzureDiagnostics
#       | where ResourceProvider == "MICROSOFT.AUTOMATION"
#       | where Category == "JobLogs"
#       | where _ResourceId =~ "${module.automation_account[each.value.automation_account_key].id}"
#       | where RunbookName_s == "${azurerm_automation_runbook.automation_ari[each.key].name}"
#       | where ResultType in ("Failed", "Stopped", "Suspended")
#       | summarize AggregatedValue = count() by bin(TimeGenerated, 15m)
#     KQL
#     time_aggregation_method = "Count"
#     threshold               = 0
#     operator                = "GreaterThan"
#     failing_periods {
#       minimum_failing_periods_to_trigger_alert = 1
#       number_of_evaluation_periods             = 1
#     }
#   }

#   dynamic "action" {
#     for_each = length(each.value.monitor_action_group_ids) > 0 ? [1] : []
#     content {
#       action_groups = each.value.monitor_action_group_ids
#       custom_properties = {
#         workload_name          = each.key
#         automation_account_key = each.value.automation_account_key
#         runbook_name           = azurerm_automation_runbook.automation_ari[each.key].name
#         alert_type             = "job_failure"
#       }
#     }
#   }
# }

# resource "azurerm_monitor_scheduled_query_rules_alert_v2" "automation_ari_long_running" {
#   for_each = {
#     for key, workload in local.enabled_automation_ari_workloads :
#     key => workload
#     if try(workload.enable_long_running_alert, true)
#   }

#   name                      = each.value.long_running_alert_name_effective
#   resource_group_name       = module.resource_group.name
#   location                  = module.resource_group.location
#   scopes                    = [local.log_analytics_resource_id]
#   severity                  = each.value.long_running_severity
#   evaluation_frequency      = each.value.alert_evaluation_frequency
#   window_duration           = each.value.alert_window_duration
#   query_time_range_override = "P1D"
#   enabled                   = true
#   auto_mitigation_enabled   = true
#   skip_query_validation     = true
#   description               = "Alerts when the ARI runbook appears to run longer than the configured threshold."
#   display_name              = "ARI runbook long running - ${each.key}"
#   tags                      = merge(local.common_tags, each.value.tags)

#   criteria {
#     query                   = <<-KQL
#       let ThresholdMinutes = ${each.value.long_running_threshold_minutes};
#       AzureDiagnostics
#       | where ResourceProvider == "MICROSOFT.AUTOMATION"
#       | where _ResourceId =~ "${module.automation_account[each.value.automation_account_key].id}"
#       | where RunbookName_s == "${azurerm_automation_runbook.automation_ari[each.key].name}"
#       | where Category in ("JobLogs", "JobStreams")
#       | summarize StartTime = min(TimeGenerated), EndTime = max(TimeGenerated) by JobId_g
#       | extend DurationMinutes = datetime_diff("minute", EndTime, StartTime)
#       | where DurationMinutes >= ThresholdMinutes
#       | summarize AggregatedValue = count() by bin(EndTime, 15m)
#     KQL
#     time_aggregation_method = "Count"
#     threshold               = 0
#     operator                = "GreaterThan"
#     failing_periods {
#       minimum_failing_periods_to_trigger_alert = 1
#       number_of_evaluation_periods             = 1
#     }
#   }

#   dynamic "action" {
#     for_each = length(each.value.monitor_action_group_ids) > 0 ? [1] : []
#     content {
#       action_groups = each.value.monitor_action_group_ids
#       custom_properties = {
#         workload_name          = each.key
#         automation_account_key = each.value.automation_account_key
#         runbook_name           = azurerm_automation_runbook.automation_ari[each.key].name
#         alert_type             = "long_running"
#       }
#     }
#   }
# }



# -------------------------------------------------------------------
# Azure AI Search Module
# -------------------------------------------------------------------

module "azure_ai_search" {
  count  = local.feature_flags.enable_azure_ai_search ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/azure_ai_search?ref=main"
  #source = "../template/modules/azure_ai_search"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = trimspace(var.azure_ai_search_name) != "" ? var.azure_ai_search_name : local.azure_ai_search_name

  sku                                      = var.azure_ai_search_sku
  replica_count                            = var.azure_ai_search_replica_count
  partition_count                          = var.azure_ai_search_partition_count
  hosting_mode                             = var.azure_ai_search_hosting_mode
  semantic_search_sku                      = var.azure_ai_search_semantic_search_sku
  public_network_access_enabled            = var.azure_ai_search_public_network_access_enabled
  allowed_ips                              = var.azure_ai_search_allowed_ips
  network_rule_bypass_option               = var.azure_ai_search_network_rule_bypass_option
  local_authentication_enabled             = var.azure_ai_search_local_authentication_enabled
  authentication_failure_mode              = var.azure_ai_search_authentication_failure_mode
  customer_managed_key_enforcement_enabled = var.azure_ai_search_customer_managed_key_enforcement_enabled
  identity                                 = var.azure_ai_search_identity

  enable_private_endpoint    = var.enable_azure_ai_search_private_endpoint
  private_endpoint_subnet_id = var.enable_azure_ai_search_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  private_dns_zone_id = trimspace(var.azure_ai_search_private_dns_zone_id) != "" ? trimspace(var.azure_ai_search_private_dns_zone_id) : (
    var.enable_azure_ai_search_private_endpoint && local.feature_flags.enable_private_dns && contains(local.private_dns_zone_names_effective, "privatelink.search.windows.net")
    ? try(module.private_dns.zone_ids["privatelink.search.windows.net"], "")
    : ""
  )

  app_admin_group              = var.app_admin_group
  app_user_group               = var.app_user_group
  enable_diagnostics           = var.azure_ai_search_enable_diagnostics
  log_analytics_workspace_id   = var.azure_ai_search_enable_diagnostics ? local.log_analytics_resource_id : ""
  diagnostic_log_categories    = var.azure_ai_search_diagnostic_log_categories
  diagnostic_metric_categories = var.azure_ai_search_diagnostic_metric_categories

  tags = local.common_tags

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Azure AI Services Module
# -------------------------------------------------------------------

module "azure_ai_service" {
  count  = local.feature_flags.enable_azure_ai_service ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/azure_ai_service?ref=main"
  #source = "../template/modules/azure_ai_service"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = trimspace(var.azure_ai_service_name) != "" ? var.azure_ai_service_name : local.azure_ai_service_name

  custom_subdomain_name              = trimspace(var.azure_ai_service_custom_subdomain_name) != "" ? var.azure_ai_service_custom_subdomain_name : local.azure_ai_service_name
  sku_name                           = var.azure_ai_service_sku_name
  public_network_access_enabled      = var.azure_ai_service_public_network_access_enabled
  outbound_network_access_restricted = var.azure_ai_service_outbound_network_access_restricted
  local_auth_enabled                 = var.azure_ai_service_local_auth_enabled
  dynamic_throttling_enabled         = var.azure_ai_service_dynamic_throttling_enabled
  fqdns                              = var.azure_ai_service_fqdns
  project_management_enabled         = var.azure_ai_service_project_management_enabled
  identity                           = var.azure_ai_service_identity
  customer_managed_key               = var.azure_ai_service_customer_managed_key
  storage                            = var.azure_ai_service_storage
  network_acls                       = var.azure_ai_service_network_acls

  enable_private_endpoint    = var.enable_azure_ai_service_private_endpoint
  private_endpoint_subnet_id = var.enable_azure_ai_service_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  private_dns_zone_id = trimspace(var.azure_ai_service_private_dns_zone_id) != "" ? trimspace(var.azure_ai_service_private_dns_zone_id) : (
    var.enable_azure_ai_service_private_endpoint && local.feature_flags.enable_private_dns && contains(local.private_dns_zone_names_effective, "privatelink.cognitiveservices.azure.com")
    ? try(module.private_dns.zone_ids["privatelink.cognitiveservices.azure.com"], "")
    : ""
  )

  app_admin_group              = var.app_admin_group
  app_user_group               = var.app_user_group
  enable_diagnostics           = var.azure_ai_service_enable_diagnostics
  log_analytics_workspace_id   = var.azure_ai_service_enable_diagnostics ? local.log_analytics_resource_id : ""
  diagnostic_log_categories    = var.azure_ai_service_diagnostic_log_categories
  diagnostic_metric_categories = var.azure_ai_service_diagnostic_metric_categories

  tags = local.common_tags

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Azure OpenAI Module
# -------------------------------------------------------------------

module "openai" {
  count  = local.feature_flags.enable_openai ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/openai?ref=main"
  #source = "../template/modules/openai"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = trimspace(var.openai_name) != "" ? var.openai_name : local.openai_name

  custom_subdomain_name              = trimspace(var.openai_custom_subdomain_name) != "" ? var.openai_custom_subdomain_name : local.openai_name
  sku_name                           = var.openai_sku_name
  public_network_access_enabled      = var.openai_public_network_access_enabled
  outbound_network_access_restricted = var.openai_outbound_network_access_restricted
  local_auth_enabled                 = var.openai_local_auth_enabled
  dynamic_throttling_enabled         = var.openai_dynamic_throttling_enabled
  network_acls                       = var.openai_network_acls

  enable_private_endpoint    = var.enable_openai_private_endpoint
  private_endpoint_subnet_id = var.enable_openai_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  private_dns_zone_id = trimspace(var.openai_private_dns_zone_id) != "" ? trimspace(var.openai_private_dns_zone_id) : (
    var.enable_openai_private_endpoint && local.feature_flags.enable_private_dns && contains(local.private_dns_zone_names_effective, "privatelink.openai.azure.com")
    ? try(module.private_dns.zone_ids["privatelink.openai.azure.com"], "")
    : ""
  )

  deployments                  = var.openai_deployments
  app_admin_group              = var.app_admin_group
  app_user_group               = var.app_user_group
  enable_diagnostics           = var.openai_enable_diagnostics
  log_analytics_workspace_id   = var.openai_enable_diagnostics ? local.log_analytics_resource_id : ""
  diagnostic_log_categories    = var.openai_diagnostic_log_categories
  diagnostic_metric_categories = var.openai_diagnostic_metric_categories

  tags = local.common_tags

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Azure Container Registry Module
# -------------------------------------------------------------------

module "acr" {
  count  = local.feature_flags.enable_acr ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/acr?ref=main"
  #source = "../template/modules/acr"

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = trimspace(var.acr_name) != "" ? var.acr_name : local.acr_name
  app_env             = var.environment

  sku                           = var.acr_sku
  admin_enabled                 = var.acr_admin_enabled
  public_network_access_enabled = var.acr_public_network_access_enabled
  anonymous_pull_enabled        = var.acr_anonymous_pull_enabled
  data_endpoint_enabled         = var.acr_data_endpoint_enabled

  identity_type                           = var.acr_identity_type
  identity_ids                            = var.acr_identity_ids
  managed_identity_role_assignments       = var.acr_managed_identity_role_assignments
  customer_managed_key_id                 = var.acr_customer_managed_key_id
  customer_managed_key_identity_client_id = var.acr_customer_managed_key_identity_client_id

  export_policy_enabled     = var.acr_export_policy_enabled
  quarantine_policy_enabled = var.acr_quarantine_policy_enabled
  retention_policy_in_days  = var.acr_retention_policy_in_days
  trust_policy_enabled      = var.acr_trust_policy_enabled
  zone_redundancy_enabled   = var.acr_zone_redundancy_enabled
  georeplications           = var.acr_georeplications

  enable_network_rule_set     = var.acr_enable_network_rule_set
  network_rule_bypass_option  = var.acr_network_rule_bypass_option
  network_rule_default_action = var.acr_network_rule_default_action
  network_rule_ip_rules       = var.acr_network_rule_ip_rules

  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group

  enable_private_endpoint    = var.acr_enable_private_endpoint
  private_endpoint_subnet_id = var.acr_enable_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  private_dns_zone_id = trimspace(var.acr_private_dns_zone_id) != "" ? trimspace(var.acr_private_dns_zone_id) : (
    var.acr_enable_private_endpoint && local.feature_flags.enable_private_dns && contains(local.private_dns_zone_names_effective, "privatelink.azurecr.io")
    ? try(module.private_dns.zone_ids["privatelink.azurecr.io"], "")
    : ""
  )
  private_dns_zone_name                = var.acr_private_dns_zone_name
  private_dns_zone_resource_group_name = var.acr_private_dns_zone_resource_group_name

  enable_diagnostics           = var.acr_enable_diagnostics
  log_analytics_workspace_id   = var.acr_enable_diagnostics ? local.log_analytics_resource_id : ""
  diagnostic_log_categories    = var.acr_diagnostic_log_categories
  diagnostic_metric_categories = var.acr_diagnostic_metric_categories

  tags = local.common_tags

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Integration: Azure Data Factory
# -------------------------------------------------------------------

module "adf_basic" {
  count  = local.feature_flags.enable_adf ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/adf?ref=main"
  #source = "../template/modules/adf"

  name     = var.workload
  app_env  = var.environment
  location = module.resource_group.location

  resource_group = module.resource_group.name

  custom_adf_name                         = local.adf_name
  custom_default_ir_name                  = var.adf_default_integration_runtime_name
  custom_diagnostics_name                 = var.adf_diagnostics_name
  custom_shir_name                        = var.adf_shir_name
  public_network_enabled                  = var.adf_public_network_enabled
  managed_virtual_network_enabled         = var.adf_managed_virtual_network_enabled
  cleanup_enabled                         = var.adf_cleanup_enabled
  compute_type                            = var.adf_compute_type
  core_count                              = var.adf_core_count
  time_to_live_min                        = var.adf_time_to_live_min
  virtual_network_enabled                 = var.adf_virtual_network_enabled
  self_hosted_integration_runtime_enabled = var.adf_self_hosted_integration_runtime_enabled

  iac_rg = module.resource_group.name
  iac_kv = module.keyvault.name
  iac_st = module.storage_account.name

  # The upstream adf module still validates these inputs even when SHIR and
  # control-plane private endpoints are disabled, so we pass the landing zone's
  # existing spoke/network naming for forward compatibility.
  app_rg      = module.resource_group.name
  app_snet    = "snet-private-endpoints"
  app_vnet_rg = module.resource_group.name
  app_vnet    = local.spoke_vnet_name
  app_vm      = local.windows_jumpbox_name

  app_admin_group  = var.app_admin_group
  app_user_group   = var.app_user_group
  permissions      = var.adf_permissions
  global_parameter = var.adf_global_parameters

  log_analytics_workspace = var.adf_enable_diagnostics ? {
    default = local.log_analytics_resource_id
  } : {}
  analytics_destination_type = var.adf_analytics_destination_type

  managed_private_endpoint = var.adf_managed_private_endpoints
  vsts_configuration       = var.adf_vsts_configuration

  enable_private_endpoint              = var.adf_enable_private_endpoint
  private_dns_zone_id                  = trimspace(var.adf_private_dns_zone_id) != "" ? var.adf_private_dns_zone_id : (var.adf_enable_private_endpoint ? try(module.private_dns.zone_ids["privatelink.datafactory.azure.net"], "") : "")
  private_dns_zone_name                = var.adf_private_dns_zone_name
  private_dns_zone_resource_group_name = var.adf_private_dns_zone_resource_group_name

  tags = local.common_tags

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns,
    module.storage_account,
    module.keyvault,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Linux VM: Jumpbox
# -------------------------------------------------------------------

module "linux_vm_basic" {
  count = local.feature_flags.enable_linux_vm ? 1 : 0

  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/linuxvm?ref=main"
  #source = "../template/modules/linuxvm"
  #source = "../allmodules/modules/linuxvm"

  common_tags = var.linux_vm_common_tags
  rg_tags     = var.linux_vm_rg_tags

  location = var.linux_vm_location
  app_env  = var.linux_vm_app_env
  workload = var.linux_vm_workload

  # Admin credential behavior:
  # - Set linux_vm_admin_username, linux_vm_admin_password, or linux_vm_admin_ssh_key to non-empty values to override Key Vault secrets.
  # - Leave any of them empty ("") to let the linuxvm module read the corresponding secret from linux_vm_iac_kv.
  # Post-init behavior:
  # - Set linux_vm_post_init_script to additional bash content when you need workload-specific customization.
  # - Leave linux_vm_post_init_script empty ("") to run only the module's built-in init.sh bootstrap.
  admin_username                  = var.linux_vm_admin_username
  admin_password                  = var.linux_vm_admin_password
  admin_ssh_key                   = var.linux_vm_admin_ssh_key
  disable_password_authentication = var.linux_vm_disable_password_authentication

  admin_credentials_key_vault_id = trimspace(var.linux_vm_admin_credentials_key_vault_id) != "" ? var.linux_vm_admin_credentials_key_vault_id : (
    trimspace(var.linux_vm_iac_kv_id) != "" ? var.linux_vm_iac_kv_id : module.keyvault.id
  )
  admin_username_secret_name = trimspace(var.linux_vm_admin_username_secret_name) != "" ? var.linux_vm_admin_username_secret_name : "azure-user"
  admin_password_secret_name = trimspace(var.linux_vm_admin_password_secret_name) != "" ? var.linux_vm_admin_password_secret_name : "azure-password"
  admin_ssh_key_secret_name  = trimspace(var.linux_vm_admin_ssh_key_secret_name) != "" ? var.linux_vm_admin_ssh_key_secret_name : "azureadmin-pubkey"

  post_init_script = <<-EOT
  export ADO_RUNNER_COUNT="${var.linux_vm_ado_runner_count}"
  ${file("scripts/post_init_script.sh")}
  EOT
  datadog_api_key  = var.linux_vm_datadog_api_key

  data_disk_size_gb               = var.linux_vm_data_disk_size_gb
  vm_count                        = var.linux_vm_vm_count
  vm_size                         = var.linux_vm_vm_size
  enable_entra_ssh_login          = var.linux_vm_enable_entra_ssh_login
  enable_linux_vm_extension       = var.linux_vm_enable_linux_vm_extension
  enable_system_assigned_identity = var.linux_vm_enable_system_assigned_identity
  localization_container_name     = var.linux_vm_localization_container_name
  localization_os_script_name     = var.linux_vm_localization_os_script_name
  localization_vm_script_content = merge(
    {
      for vm_name in local.linux_vm_names :
      "${vm_name}.sh" => file("${path.module}/scripts/${vm_name}.sh")
      if fileexists("${path.module}/scripts/${vm_name}.sh")
    },
    var.linux_vm_upload_shared_localization_scripts ? {
      "ubuntu.sh" = file("${path.module}/scripts/ubuntu.sh")
      "redhat.sh" = file("${path.module}/scripts/redhat.sh")
    } : {}
  )
  # Domain join behavior:
  # - Set linux_vm_enable_domain_join = true only when you want the Linux bootstrap to attempt AD join.
  # - Leave it false to skip the domain-join secret lookup and keep the VM off domain.
  enable_domain_join = var.linux_vm_enable_domain_join
  image_publisher    = var.linux_vm_image_publisher
  image_offer        = var.linux_vm_image_offer
  image_sku          = var.linux_vm_image_sku
  image_version      = var.linux_vm_image_version

  iac_rg = trimspace(var.linux_vm_iac_rg) != "" ? var.linux_vm_iac_rg : module.resource_group.name
  iac_kv = trimspace(var.linux_vm_iac_kv) != "" ? var.linux_vm_iac_kv : module.keyvault.name
  iac_kv_id = trimspace(var.linux_vm_admin_credentials_key_vault_id) != "" ? var.linux_vm_admin_credentials_key_vault_id : (
    trimspace(var.linux_vm_iac_kv_id) != "" ? var.linux_vm_iac_kv_id : module.keyvault.id
  )
  iac_st                       = trimspace(var.linux_vm_iac_st) != "" ? var.linux_vm_iac_st : module.storage_account.name
  iac_st_id                    = trimspace(var.linux_vm_iac_st_id) != "" ? var.linux_vm_iac_st_id : module.storage_account.id
  iac_st_primary_blob_endpoint = trimspace(var.linux_vm_iac_st_primary_blob_endpoint) != "" ? var.linux_vm_iac_st_primary_blob_endpoint : module.storage_account.primary_blob_endpoint

  resource_group_name = trimspace(var.linux_vm_resource_group_name) != "" ? var.linux_vm_resource_group_name : module.resource_group.name
  #app_snet            = trimspace(var.linux_vm_subnet_name) != "" ? var.linux_vm_subnet_name : module.spoke_virtual_network.subnet_names["snet-jumpbox"]
  subnet_id = trimspace(var.linux_vm_subnet_id) != "" ? var.linux_vm_subnet_id : module.spoke_virtual_network.subnet_ids["snet-jumpbox"]
  vm_name   = trimspace(var.linux_vm_vm_name) != "" ? var.linux_vm_vm_name : local.linux_jumpbox_name

  enable_spot_instance = false
  spot_eviction_policy = "Deallocate"
  spot_max_bid_price   = -1



  # domain           = var.linux_vm_domain
  # domain_join_user = var.linux_vm_domain_join_user
  # domain_join_ou   = var.linux_vm_domain_join_ou

  # Linux access groups:
  # - app_user_group is the preferred SSH access input and gets Reader on each VM resource.
  # - app_admin_group is the preferred sudo/admin access input and gets Contributor on each VM resource.
  # - when Bastion is configured, both groups also get Network Contributor on the Bastion host.
  app_user_group              = var.linux_vm_app_user_group
  app_admin_group             = var.linux_vm_app_admin_group
  bastion_resource_name       = var.bastion_resource_name
  bastion_resource_group_name = var.bastion_resource_group_name

  public_network_enabled = var.linux_vm_public_network_enabled

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.storage_account,
    module.keyvault,
    azapi_update_resource.storage_account_blob_service,
    azapi_resource.shared_storage_container
  ]
}

# -------------------------------------------------------------------
# Linux VM: App Service Deployment RBAC
# -------------------------------------------------------------------

resource "azurerm_role_assignment" "linux_vm_app_service_website_contributor" {
  for_each = local.feature_flags.enable_linux_vm && var.linux_vm_enable_system_assigned_identity ? {
    for pair in setproduct(keys(local.enabled_app_services), range(var.linux_vm_vm_count)) :
    "linux-vm-${pair[0]}-${pair[1]}-website-contributor" => {
      app_key  = pair[0]
      vm_index = pair[1]
    }
  } : {}

  scope                = module.app_service[each.value.app_key].app_id
  role_definition_name = "Website Contributor"
  principal_id         = module.linux_vm_basic[0].managed_identity_principal_ids[each.value.vm_index]
  principal_type       = "ServicePrincipal"

  depends_on = [
    module.app_service,
    module.linux_vm_basic
  ]
}

# -------------------------------------------------------------------
# AKS Module
# -------------------------------------------------------------------

module "aks" {
  count  = local.feature_flags.enable_aks ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/aks?ref=main"
  #source = "../template/modules/aks"

  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = trimspace(var.aks_name) != "" ? var.aks_name : local.aks_name
  dns_prefix          = trimspace(var.aks_dns_prefix) != "" ? var.aks_dns_prefix : local.aks_name

  kubernetes_version        = var.aks_kubernetes_version
  sku_tier                  = var.aks_sku_tier
  automatic_upgrade_channel = var.aks_automatic_upgrade_channel

  private_cluster_enabled              = var.aks_private_cluster_enabled
  private_dns_zone_id                  = var.aks_private_dns_zone_id
  private_dns_zone_name                = var.aks_private_dns_zone_name
  private_dns_zone_resource_group_name = var.aks_private_dns_zone_resource_group_name

  role_based_access_control_enabled = var.aks_role_based_access_control_enabled
  azure_rbac_enabled                = var.aks_azure_rbac_enabled
  local_account_disabled            = var.aks_local_account_disabled
  oidc_issuer_enabled               = var.aks_oidc_issuer_enabled
  workload_identity_enabled         = var.aks_workload_identity_enabled

  app_admin_group              = var.aks_app_admin_group
  app_user_group               = var.aks_app_user_group
  terraform_execution_aks_role = var.aks_terraform_execution_aks_role

  default_node_pool = merge(
    var.aks_default_node_pool,
    {
      vnet_subnet_id = local.spoke_subnet_resource_ids.aks
    }
  )
  network_profile = var.aks_network_profile

  enable_diagnostics           = var.aks_enable_diagnostics
  log_analytics_workspace_id   = trimspace(var.aks_log_analytics_workspace_id) != "" ? var.aks_log_analytics_workspace_id : local.log_analytics_resource_id
  diagnostic_log_categories    = var.aks_diagnostic_log_categories
  diagnostic_metric_categories = var.aks_diagnostic_metric_categories

  tags = merge(local.common_tags, var.aks_tags)

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.log_analytics,
    module.private_dns
  ]
}

# -------------------------------------------------------------------
# SQL DB Module
# -------------------------------------------------------------------

module "sqldb" {
  count  = local.feature_flags.enable_sqldb ? 1 : 0
  source = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/sqldb?ref=main"
  #source = "../template/modules/sqldb"

  server_name                    = local.sql_server_name
  database_name                  = local.sql_database_name
  max_size_gb                    = var.sql_max_size_gb
  backup_storage_redundancy      = var.sql_backup_storage_redundancy
  public_network_access_enabled  = var.sql_public_network_access_enabled
  firewall_rules                 = var.sql_firewall_rules
  admin_username                 = var.sql_admin_username
  admin_password                 = var.sql_admin_password
  admin_credentials_key_vault_id = local.sql_admin_credentials_key_vault_id_effective
  admin_username_secret_name     = trimspace(var.sql_admin_username_secret_name) != "" ? var.sql_admin_username_secret_name : "azure-user"
  admin_password_secret_name     = trimspace(var.sql_admin_password_secret_name) != "" ? var.sql_admin_password_secret_name : "azure-password"
  ad_admin_login_name            = var.sql_ad_admin_login
  ad_admin_object_id             = var.sql_ad_admin_object_id
  sku_name                       = var.sql_sku_name
  resource_group_name            = module.resource_group.name
  app_env                        = var.environment
  location                       = var.location
  private_endpoint_subnet_id     = local.spoke_subnet_resource_ids.private_endpoints
  app_admin_group                = var.app_admin_group
  app_user_group                 = var.app_user_group
  tags                           = local.common_tags


  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.private_dns
  ]
}
