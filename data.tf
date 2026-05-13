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

# # data "azurerm_resource_group" "function_app" {
# #   name = local.effective_function_app_resource_group_name
# # }

