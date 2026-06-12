locals {
  tags = var.tags

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
  sql_server_name         = "sql-${replace(var.workload, "-", "")}-${local.location_code}-${var.environment}"
  sql_database_name       = "sqldb-${replace(var.workload, "-", "")}-${var.environment}"
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
    enable_databricks                      = lookup(var.features, "enable_databricks", var.enable_databricks)
    enable_app_services                    = lookup(var.features, "enable_app_services", true)
    enable_app_registration_for_appservice = lookup(var.features, "enable_app_registration_for_appservice", var.enable_app_registration_for_appservice)
    enable_automation_accounts             = lookup(var.features, "enable_automation_accounts", true)
    enable_automation_ari_workloads        = lookup(var.features, "enable_automation_ari_workloads", true)
    enable_winvm                           = lookup(var.features, "enable_winvm", var.enable_winvm)
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
  environment_tag_map = {
    dev         = "Development"
    development = "Development"
    sbx         = "Sandbox"
    sandbox     = "Sandbox"
    prod        = "Production"
    production  = "Production"
    stg         = "Staging"
    stage       = "Staging"
    staging     = "Staging"
    qa          = "QA"
    test        = "Test"
    poc         = "POC"
    demo        = "Demo"
    pentest     = "Pentest"
  }
  environment_tag_value = local.environment_tag_map[lower(trimspace(var.environment))]
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
        hub = {
          virtual_network_id   = module.hub_virtual_network.id
          registration_enabled = false
          #tags                 = {}
        }
        # spoke = {
        #   virtual_network_id   = module.spoke_virtual_network.id
        #   registration_enabled = false
        #   tags                 = {}
        #   #tags                 = local.rg_tags
        # }
      }
      a_records = {}
    }
  }

  reserved_tag_keys = ["environment", "workload"]

  input_tags = merge(
    var.rg_tags,
    var.tags
  )

  normalized_input_tags = {
    for key, value in local.input_tags :
    trimspace(key) => trimspace(value)
    if !contains(local.reserved_tag_keys, lower(trimspace(key)))
  }

  mandatory_tags = {
    Environment = local.environment_tag_value
    Workload    = trimspace(var.workload)
  }

  rg_tags = merge(
    local.normalized_input_tags,
    local.mandatory_tags
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
