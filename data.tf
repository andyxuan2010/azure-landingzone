# data "azurerm_client_config" "current" {}
# #data.azurerm_client_config.current.tenant_id
# #data.azurerm_client_config.current.client_id
# #data.azurerm_client_config.current.subscription_id

# data "azurerm_subscriptions" "available" {}
# #data.azurerm_subscriptions.available.subscriptions

# data "azurerm_subscription" "current" {
#   subscription_id = data.azurerm_client_config.current.subscription_id
# }




# # #get existing vnet
# # data "azurerm_virtual_network" "app" {
# #   name                = var.app_vnet
# #   resource_group_name = var.app_vnet_rg
# # }

# # # # get existing subnet inside a vnet
# # data "azurerm_subnet" "app" {
# #   name                 = var.app_snet
# #   virtual_network_name = var.app_vnet
# #   resource_group_name  = var.app_vnet_rg
# # }
# # # get existing DB subnet inside a vnet
# # data "azurerm_subnet" "db" {
# #   name                 = var.db_snet
# #   virtual_network_name = var.app_vnet
# #   resource_group_name  = var.app_vnet_rg
# # }
# #get existing resource group
# data "azurerm_resource_group" "iac" {
#   name = var.iac_rg
# }
# # get existing storage account, for iac purpose
# data "azurerm_storage_account" "iac" {
#   name                = var.iac_st
#   resource_group_name = var.iac_rg
# }
# # get existing key vault and secret, for iac purpose
# data "azurerm_key_vault" "iac" {
#   name                = var.iac_kv
#   resource_group_name = var.iac_rg
# }

# # data "azurerm_key_vault_secret" "sqladminuser-password" {
# #   name         = "sqladminuser-password"
# #   key_vault_id = data.azurerm_key_vault.iac.id
# # }

# # data "azurerm_log_analytics_workspace" "this" {
# #   provider            = azurerm.prod
# #   name                = "log-ba-cc-prod"
# #   resource_group_name = "rg-ba-cc-prod-automation"
# # }

# # data "azurerm_private_dns_zone" "automation" {
# #   count               = local.automation_private_endpoints_enabled ? 1 : 0
# #   provider            = azurerm.prod
# #   name                = "privatelink.azure-automation.net"
# #   resource_group_name = "rg-ba-eus-prod-hub-network"
# # }

# # data "azurerm_virtual_machine" "hybrid_worker" {
# #   provider            = azurerm.prod
# #   name                = var.hybrid_worker_vm_name
# #   resource_group_name = var.hybrid_worker_vm_resource_group
# # }

# # data "azapi_resource" "automation_account" {
# #   type                   = "Microsoft.Automation/automationAccounts@2023-11-01"
# #   resource_id            = module.automation_account.id
# #   response_export_values = ["properties.automationHybridServiceUrl", "identity"]

# #   depends_on = [module.automation_account]
# # }

# # data "azuread_service_principal" "sharepoint_online" {
# #   client_id = "00000003-0000-0ff1-ce00-000000000000"
# # }

# data "azurerm_resource_group" "app" {
#   name = var.app_rg
#   #name       = module.rg.azurerm_resource_group.app.name
#   # name       = module.rg.name
#   # depends_on = [module.rg]
# }

data "azurerm_key_vault" "sql_iac" {
  count = trimspace(var.sql_admin_credentials_key_vault_id) == "" && trimspace(var.sql_iac_rg) != "" && trimspace(var.sql_iac_kv) != "" ? 1 : 0

  name                = var.sql_iac_kv
  resource_group_name = var.sql_iac_rg
}

data "azurerm_resource_group" "landingzone" {
  name = module.resource_group.name

  depends_on = [module.resource_group]
}

# -------------------------------------------------------------------
# AI Service Data Sources
# -------------------------------------------------------------------

data "azurerm_search_service" "azure_ai_search" {
  count = local.feature_flags.enable_azure_ai_search ? 1 : 0

  name                = module.azure_ai_search[0].name
  resource_group_name = module.azure_ai_search[0].resource_group_name

  depends_on = [module.azure_ai_search]
}

data "azurerm_cognitive_account" "azure_ai_service" {
  count = local.feature_flags.enable_azure_ai_service ? 1 : 0

  name                = module.azure_ai_service[0].name
  resource_group_name = module.azure_ai_service[0].resource_group_name

  depends_on = [module.azure_ai_service]
}

data "azurerm_cognitive_account" "openai" {
  count = local.feature_flags.enable_openai ? 1 : 0

  name                = module.openai[0].name
  resource_group_name = module.openai[0].resource_group_name

  depends_on = [module.openai]
}

data "azurerm_data_factory" "adf" {
  count = local.feature_flags.enable_adf ? 1 : 0

  name                = module.adf_basic[0].name
  resource_group_name = module.resource_group.name

  depends_on = [module.adf_basic]
}

data "azurerm_linux_web_app" "app_service_linux" {
  for_each = local.feature_flags.enable_app_services ? {
    for key, app_service in local.enabled_app_services :
    key => app_service
    if lower(app_service.kind) == "linux"
  } : {}

  name                = module.app_service[each.key].app_name
  resource_group_name = module.resource_group.name

  depends_on = [module.app_service]
}

data "azurerm_windows_web_app" "app_service_windows" {
  for_each = local.feature_flags.enable_app_services ? {
    for key, app_service in local.enabled_app_services :
    key => app_service
    if lower(app_service.kind) == "windows"
  } : {}

  name                = module.app_service[each.key].app_name
  resource_group_name = module.resource_group.name

  depends_on = [module.app_service]
}

data "azurerm_kubernetes_cluster" "aks" {
  count = local.feature_flags.enable_aks ? 1 : 0

  name                = module.aks[0].name
  resource_group_name = module.aks[0].resource_group_name

  depends_on = [module.aks]
}

data "azurerm_mssql_server" "sqldb" {
  count = local.feature_flags.enable_sqldb ? 1 : 0

  name                = module.sqldb[0].server_name
  resource_group_name = module.resource_group.name

  depends_on = [module.sqldb]
}

data "azurerm_mssql_database" "sqldb" {
  count = local.feature_flags.enable_sqldb ? 1 : 0

  name      = module.sqldb[0].database_name
  server_id = module.sqldb[0].server_id

  depends_on = [module.sqldb]
}

data "azurerm_key_vault" "landingzone" {
  name                = module.keyvault.name
  resource_group_name = module.keyvault.resource_group_name

  depends_on = [module.keyvault]
}

data "azurerm_storage_account" "landingzone" {
  name                = module.storage_account.name
  resource_group_name = module.storage_account.resource_group_name

  depends_on = [module.storage_account]
}

# # data "azurerm_resource_group" "function_app" {
# #   name = local.effective_function_app_resource_group_name
# # }

