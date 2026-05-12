# output "management_group_id" {
#   description = "Platform and landing zone management group IDs when enable_management_group is true."
#   value = {
#     platform    = try(module.mg_platform[0].id, null)
#     landingzone = try(module.mg_landingzone[0].id, null)
#     sandboxes   = try(module.mg_sandboxes[0].id, null)
#   }
# }

# output "management_group_hierarchy_ids" {
#   description = "Child management group IDs keyed by hierarchy name."
#   value = {
#     platform_children    = { for key, group in module.mg_platform_children : key => group.id }
#     landingzone_children = { for key, group in module.mg_landingzone_children : key => group.id }
#   }
# }

# output "hierarchy_subscription_ids" {
#   description = "Subscription IDs targeted or created by subscription_vending keyed by child management group name."
#   value       = { for key, subscription in module.subscription_vending : key => subscription.subscription_id }
# }

# output "resource_group" {
#   description = "Landing zone resource group details."
#   value = {
#     id       = module.resource_group.id
#     name     = module.resource_group.name
#     location = module.resource_group.location
#   }
# }

# output "log_analytics_workspace" {
#   description = "Landing zone Log Analytics workspace details."
#   value = {
#     id           = module.log_analytics.id
#     name         = module.log_analytics.name
#     workspace_id = module.log_analytics.workspace_id
#   }
# }

# output "hub_virtual_network" {
#   description = "Hub virtual network details."
#   value = {
#     id             = module.hub_virtual_network.id
#     name           = module.hub_virtual_network.name
#     resource_group = module.hub_virtual_network.resource_group_name
#     location       = module.hub_virtual_network.location
#     address_space  = module.hub_virtual_network.address_space
#     subnet_ids     = module.hub_virtual_network.subnet_ids
#     subnet_names   = module.hub_virtual_network.subnet_names
#   }
# }

# output "spoke_virtual_network" {
#   description = "Spoke virtual network details."
#   value = {
#     id             = module.spoke_virtual_network.id
#     name           = module.spoke_virtual_network.name
#     resource_group = module.spoke_virtual_network.resource_group_name
#     location       = module.spoke_virtual_network.location
#     address_space  = module.spoke_virtual_network.address_space
#     subnet_ids     = module.spoke_virtual_network.subnet_ids
#     subnet_names   = module.spoke_virtual_network.subnet_names
#   }
# }

# output "virtual_network_peerings" {
#   description = "Hub and spoke virtual network peering IDs."
#   value = {
#     hub_to_spoke = azurerm_virtual_network_peering.hub_to_spoke.id
#     spoke_to_hub = azurerm_virtual_network_peering.spoke_to_hub.id
#   }
# }

# output "network_security_group" {
#   description = "Landing zone spoke NSG details."
#   value = {
#     id                     = module.network_security_group.id
#     name                   = module.network_security_group.name
#     security_rule_names    = module.network_security_group.security_rule_names
#     subnet_association_ids = module.network_security_group.subnet_association_ids
#   }
# }

# output "storage_account" {
#   description = "Landing zone storage account details."
#   value = {
#     id                     = module.storage_account.id
#     name                   = module.storage_account.name
#     resource_group         = module.storage_account.resource_group_name
#     location               = module.storage_account.location
#     primary_blob_endpoint  = module.storage_account.primary_blob_endpoint
#     primary_file_endpoint  = module.storage_account.primary_file_endpoint
#     primary_queue_endpoint = module.storage_account.primary_queue_endpoint
#     primary_table_endpoint = module.storage_account.primary_table_endpoint
#   }
# }

# output "key_vault" {
#   description = "Landing zone Key Vault details."
#   value = {
#     id             = module.keyvault.id
#     name           = module.keyvault.name
#     resource_group = module.keyvault.resource_group_name
#     location       = module.keyvault.location
#     vault_uri      = module.keyvault.vault_uri
#     tenant_id      = module.keyvault.tenant_id
#   }
# }

# output "app_service_plans" {
#   description = "App Service Plans keyed by stack."
#   value = {
#     for key, plan in module.app_service_plan :
#     key => {
#       id                  = plan.id
#       name                = plan.name
#       resource_group_name = plan.resource_group_name
#       location            = plan.location
#       os_type             = plan.os_type
#       sku_name            = plan.sku_name
#     }
#   }
# }

# output "app_services" {
#   description = "App Services keyed by stack."
#   value = {
#     for key, app in module.app_service :
#     key => {
#       id                    = app.app_id
#       name                  = app.app_name
#       default_hostname      = app.default_hostname
#       identity_principal_id = app.identity_principal_id
#       private_endpoint_id   = app.private_endpoint_sites_id
#     }
#   }
# }

# -------------------------------------------------------------------
# Automation Outputs
# -------------------------------------------------------------------

# output "automation_accounts" {
#   description = "Automation Accounts keyed by logical name."
#   value = {
#     for key, account in module.automation_account :
#     key => {
#       id           = account.id
#       name         = account.name
#       principal_id = try(account.principal_id, null)
#     }
#   }
# }

# output "automation_ari_workloads" {
#   description = "ARI Automation workload resources keyed by workload name."
#   value = {
#     for key, workload in local.enabled_automation_ari_workloads :
#     key => {
#       automation_account_key   = workload.automation_account_key
#       storage_container_name   = azurerm_storage_container.automation_ari[workload.storage_container_name_effective].name
#       runtime_environment_name = azurerm_automation_runtime_environment.automation_ari[key].name
#       runbook_name             = azurerm_automation_runbook.automation_ari[key].name
#       schedule_enabled         = try(workload.schedule_enabled, true)
#       schedule_name            = try(azurerm_automation_schedule.automation_ari[key].name, null)
#     }
#   }
# }

# output "automation_role_assignment_ids" {
#   description = "Automation Account managed identity role assignments created at the root level."
#   value = {
#     storage_blob_data_contributor = {
#       for key, assignment in azurerm_role_assignment.automation_account_storage_blob_data_contributor :
#       key => assignment.id
#     }
#     key_vault_secrets_officer = {
#       for key, assignment in azurerm_role_assignment.automation_account_key_vault_secrets_officer :
#       key => assignment.id
#     }
#   }
# }

# output "automation_ari_alert_rule_ids" {
#   description = "ARI alert rule IDs keyed by workload name."
#   value = {
#     job_failure = {
#       for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.automation_ari_job_failure :
#       key => alert.id
#     }
#     long_running = {
#       for key, alert in azurerm_monitor_scheduled_query_rules_alert_v2.automation_ari_long_running :
#       key => alert.id
#     }
#   }
# }

# -------------------------------------------------------------------
# Linux VM Outputs
# -------------------------------------------------------------------

output "linux_jumpbox" {
  description = "Linux jumpbox VM details."
  value = {
    ids                            = try(module.linux_vm_basic[0].id, [])
    names                          = try(module.linux_vm_basic[0].name, [])
    computer_names                 = try(module.linux_vm_basic[0].computer_name, [])
    private_ips                    = try(module.linux_vm_basic[0].private_ip, [])
    private_ip_by_vm_name          = try(module.linux_vm_basic[0].private_ip_by_vm_name, {})
    public_ips                     = try(module.linux_vm_basic[0].public_ip, [])
    network_interface_ids          = try(module.linux_vm_basic[0].network_interface_ids, [])
    managed_identity_principal_ids = try(module.linux_vm_basic[0].managed_identity_principal_ids, [])
    managed_disk_ids               = try(module.linux_vm_basic[0].managed_disk_ids, [])
  }
}

# output "linux_jumpbox_role_assignment_ids" {
#   description = "Role assignment IDs created by the Linux VM module."
#   value       = try(module.linux_vm_basic[0].role_assignment_ids, {})
# }

# output "root_role_assignment_ids" {
#   description = "Role assignment IDs created by the root-level Linux VM to App Service deployment RBAC resources."
#   value       = { for k, v in azurerm_role_assignment.linux_vm_app_service_website_contributor : k => v.id }
# }
