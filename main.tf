# -------------------------------------------------------------------
# Local Naming and Shared Values
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# Azure Provider Context
# -------------------------------------------------------------------

data "azurerm_client_config" "current" {}

# -------------------------------------------------------------------
# Governance: Management Groups
# -------------------------------------------------------------------

module "mg_platform" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "../template/modules/managementgroups"
  #source = "./modules/template/modules/managementgroups"

  name                       = local.platform_mg_name
  display_name               = local.platform_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.rg_tags
}
module "mg_landingzone" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "../template/modules/managementgroups"
  #source = "../template/modules/managementgroups"

  name                       = local.landingzone_mg_name
  display_name               = local.landingzone_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.rg_tags
}
module "mg_sandboxes" {
  count  = local.feature_flags.enable_management_group ? 1 : 0
  source = "../template/modules/managementgroups"
  #source = "../template/modules/managementgroups"

  name                       = local.sandbox_mg_name
  display_name               = local.sandbox_mg_display
  parent_management_group_id = trimspace(var.management_group_parent_management_group_id) != "" ? var.management_group_parent_management_group_id : null
  subscription_ids           = []
  tags                       = local.rg_tags
}
module "mg_platform_children" {
  for_each = local.feature_flags.enable_management_group ? local.mg_platform_hierarchy : {}
  source   = "../template/modules/managementgroups"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"

  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = module.mg_platform[0].id
  subscription_ids           = []
  tags                       = local.rg_tags
}
module "mg_landingzone_children" {
  for_each = local.feature_flags.enable_management_group ? local.mg_landingzone_hierarchy : {}
  source   = "../template/modules/managementgroups"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/managementgroups?ref=main"

  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = module.mg_landingzone[0].id
  subscription_ids           = []
  tags                       = local.rg_tags
}

# -------------------------------------------------------------------
# Governance: Subscription Vending
# -------------------------------------------------------------------

module "subscription_vending" {
  for_each = local.feature_flags.enable_subscription_bootstrap && local.feature_flags.enable_management_group ? local.hierarchy_subscription_targets : {}
  source   = "../template/modules/subscription_vending"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/subscription_vending?ref=main"

  subscription_alias_enabled          = try(each.value.subscription_alias_enabled, false)
  subscription_alias_name             = try(each.value.subscription_alias_name, "")
  subscription_name                   = each.value.subscription_name
  billing_scope_id                    = try(each.value.billing_scope_id, "")
  existing_subscription_id            = each.value.existing_subscription_id
  enable_management_group_association = true
  management_group_id                 = local.subscription_management_group_ids[local.hierarchy_subscription_management_group_keys[each.key]]
  resource_provider_registrations     = var.subscription_resource_provider_registrations
  bootstrap_resource_groups           = {}
  tags                                = local.rg_tags
}

# -------------------------------------------------------------------
# Foundation: Resource Group
# -------------------------------------------------------------------

module "resource_group" {
  source = "../template/modules/rg"
  #source = "../template/modules/rg"

  name            = local.resource_group_name
  location        = var.location
  app_env         = var.environment
  enable_lock     = false
  app_admin_group = var.app_admin_group
  app_user_group  = var.app_user_group
  tags            = local.rg_tags
}

# -------------------------------------------------------------------
# Foundation: Log Analytics Workspace
# -------------------------------------------------------------------

module "log_analytics" {
  source = "../template/modules/loganalytics"
  #source = "../template/modules/loganalytics"

  name                               = local.log_analytics_name
  resource_group_name                = module.resource_group.name
  location                           = module.resource_group.location
  retention_in_days                  = var.log_analytics_retention_in_days
  internet_ingestion_enabled         = var.log_analytics_internet_ingestion_enabled
  internet_query_enabled             = var.log_analytics_internet_query_enabled
  local_authentication_disabled      = var.log_analytics_local_authentication_disabled
  reservation_capacity_in_gb_per_day = var.log_analytics_reservation_capacity_in_gb_per_day
  inherit_resource_group_tags        = true
  inherited_resource_group_tags      = local.rg_tags
  tags                               = {}
}

# -------------------------------------------------------------------
# Network: Hub Virtual Network
# -------------------------------------------------------------------

module "hub_virtual_network" {
  source = "../template/modules/vnet"
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

  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  #depends_on = [module.resource_group]
}

# -------------------------------------------------------------------
# Network: Spoke Virtual Network
# -------------------------------------------------------------------

module "spoke_virtual_network" {
  source = "../template/modules/vnet"
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

  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  #depends_on = [module.resource_group]
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
  source = "../template/modules/nsg"
  #source = "../template/modules/nsg"

  name                = local.nsg_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  security_rules = merge(
    {
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
    },
    local.feature_flags.enable_databricks ? {
      databricks-worker-to-sql = {
        priority                   = 300
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "Sql"
        description                = "Required by Azure Databricks network intent policy for worker access to SQL."
      }

      databricks-worker-to-storage = {
        priority                   = 310
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "Storage"
        description                = "Required by Azure Databricks network intent policy for worker access to Storage."
      }

      databricks-worker-to-eventhub = {
        priority                   = 320
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "9093"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "EventHub"
        description                = "Required by Azure Databricks network intent policy for worker access to Event Hub."
      }
    } : {}
  )

  subnet_ids = []

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}
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
#   source = "../template/modules/firewall"

#   name                = local.firewall_name
#   resource_group_name = module.resource_group.name
#   location            = module.resource_group.location
#   subnet_id           = module.hub_virtual_network.subnet_ids["AzureFirewallSubnet"]
#   sku_tier            = var.firewall_sku_tier
#   tags                = local.rg_tags
# }

module "private_dns" {
  source = "../template/modules/private_dns"
  #source = "../template/modules/private_dns"

  resource_group_name           = module.resource_group.name
  zones                         = local.private_dns_zones
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}
}

# -------------------------------------------------------------------
# Optional Network Services: FortiGate
# -------------------------------------------------------------------

module "fortigate" {
  count  = local.feature_flags.enable_fortigate ? 1 : 0
  source = "../template/modules/fortigate"

  architecture        = local.fortigate_architecture
  resource_group_name = local.fortigate_resource_group_name
  location            = module.resource_group.location
  name_prefix         = local.fortigate_name_prefix
  license_type        = var.fortigate_license_type
  vm_size             = var.fortigate_vm_size
  single_zone         = var.fortigate_zone

  admin_username          = var.fortigate_admin_username
  admin_password          = var.fortigate_admin_password
  admin_ssh_public_key    = local.fortigate_admin_ssh_public_key
  management_access_model = var.fortigate_management_access_model

  image            = var.fortigate_image
  marketplace_plan = var.fortigate_marketplace_plan
  os_disk          = var.fortigate_os_disk
  custom_data      = var.fortigate_custom_data

  create_virtual_network              = var.fortigate_create_dedicated_vnet
  create_subnets                      = true
  virtual_network_name                = var.fortigate_create_dedicated_vnet ? var.fortigate_virtual_network_name : module.hub_virtual_network.name
  virtual_network_resource_group_name = var.fortigate_create_dedicated_vnet ? local.fortigate_resource_group_name : module.resource_group.name
  virtual_network_address_space       = var.fortigate_virtual_network_address_space
  create_network_security_group       = true
  network_security_group_name         = trimspace(var.fortigate_network_security_group_name) != "" ? trimspace(var.fortigate_network_security_group_name) : "nsg-${local.fortigate_name_prefix}"
  network_security_rules              = var.fortigate_network_security_rules
  interfaces                          = local.fortigate_module_interfaces

  tags = local.rg_tags

  depends_on = [module.hub_virtual_network]
}

# -------------------------------------------------------------------
# Data Foundation: Storage Account
# -------------------------------------------------------------------

module "storage_account" {
  source = "../template/modules/storageaccount"
  #source = "../template/modules/storageaccount"
  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  name                          = local.storage_account_name
  public_network_access_enabled = true
  enable_network_rules          = false
  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  workload                      = var.workload
  tags                          = {}

  #depends_on = [module.resource_group]
}


# -------------------------------------------------------------------
# Data Foundation: Key Vault
# -------------------------------------------------------------------

module "keyvault" {
  source = "../template/modules/keyvault"
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
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  #depends_on = [module.resource_group]
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
  source   = "../template/modules/appserviceplan"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appserviceplan?ref=main"

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

  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [module.resource_group, module.log_analytics]
}

# -------------------------------------------------------------------
# App Service: Entra App Registration
# -------------------------------------------------------------------

module "app_registration_appservice" {
  for_each = local.effective_enable_app_registration_for_appservice ? local.enabled_app_services : {}
  source   = "../template/modules/appregistration"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appregistration?ref=main"

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
  source   = "../template/modules/appservice"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/appservice?ref=main"


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

  app_env                       = var.environment
  app_admin_group               = var.app_admin_group
  app_user_group                = var.app_user_group
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

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
  source   = "../template/modules/automationaccount"
  #source  = "git::https://dev.azure.com/CCOE-Azure/IaC/_git/template//modules/automationaccount?ref=main"

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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = each.value.tags
  # due to the 15 tag limit on the automation account resource, we merge only the common tags with any additional tags specified for the automation account, rather than merging all common tags with all additional tags which could easily exceed the tag limit
  #tags = merge(var.common_tags, each.value.tags)
  #tags = var.common_tags

  depends_on = [
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
  tags = merge(local.rg_tags, each.value.tags)
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
#   tags                    = merge(local.rg_tags, each.value.tags)

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
#   tags                      = merge(local.rg_tags, each.value.tags)

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
  source = "../template/modules/azure_ai_search"
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [
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
  source = "../template/modules/azure_ai_service"
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [
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
  source = "../template/modules/openai"
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [
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
  source = "../template/modules/acr"
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [
    module.spoke_virtual_network,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Azure Databricks Module
# -------------------------------------------------------------------

module "databricks" {
  count  = local.feature_flags.enable_databricks ? 1 : 0
  source = "../template/modules/databricks"

  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  name                          = trimspace(var.databricks_name) != "" ? var.databricks_name : local.databricks_name
  inherit_resource_group_tags   = var.databricks_inherit_resource_group_tags
  inherited_resource_group_tags = local.rg_tags

  sku                                   = var.databricks_sku
  managed_resource_group_name           = var.databricks_managed_resource_group_name
  public_network_access_enabled         = var.databricks_public_network_access_enabled
  network_security_group_rules_required = var.databricks_network_security_group_rules_required

  customer_managed_key_enabled                        = var.databricks_customer_managed_key_enabled
  infrastructure_encryption_enabled                   = var.databricks_infrastructure_encryption_enabled
  managed_disk_cmk_key_vault_id                       = var.databricks_managed_disk_cmk_key_vault_id
  managed_disk_cmk_key_vault_key_id                   = var.databricks_managed_disk_cmk_key_vault_key_id
  managed_disk_cmk_rotation_to_latest_version_enabled = var.databricks_managed_disk_cmk_rotation_to_latest_version_enabled
  managed_services_cmk_key_vault_id                   = var.databricks_managed_services_cmk_key_vault_id
  managed_services_cmk_key_vault_key_id               = var.databricks_managed_services_cmk_key_vault_key_id
  root_dbfs_customer_managed_key                      = var.databricks_root_dbfs_customer_managed_key
  enhanced_security_compliance                        = var.databricks_enhanced_security_compliance

  default_storage_firewall_enabled                  = var.databricks_default_storage_firewall_enabled
  access_connector_id                               = var.databricks_access_connector_id
  create_access_connector                           = var.databricks_create_access_connector
  access_connector_name                             = var.databricks_access_connector_name
  access_connector_system_assigned_identity_enabled = var.databricks_access_connector_system_assigned_identity_enabled
  access_connector_identity_ids                     = var.databricks_access_connector_identity_ids
  access_connector_role_assignments                 = var.databricks_access_connector_role_assignments

  custom_parameters = var.databricks_custom_parameters != null ? merge(
    var.databricks_custom_parameters,
    {
      virtual_network_id                                   = module.spoke_virtual_network.id
      public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.spoke_network_security_group["databricks_public"].id
      private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.spoke_network_security_group["databricks_private"].id
    }
  ) : null

  private_endpoint_subnet_id                   = trimspace(var.databricks_private_endpoint_subnet_id) != "" ? var.databricks_private_endpoint_subnet_id : local.spoke_subnet_resource_ids.private_endpoints
  private_endpoint_subnet_name                 = var.databricks_private_endpoint_subnet_name
  private_endpoint_vnet_name                   = var.databricks_private_endpoint_vnet_name
  private_endpoint_network_resource_group_name = var.databricks_private_endpoint_network_resource_group_name
  private_endpoint_subresource_names           = var.databricks_private_endpoint_subresource_names
  private_dns_zone_ids = length(var.databricks_private_dns_zone_ids) > 0 ? var.databricks_private_dns_zone_ids : compact([
    local.feature_flags.enable_private_dns && contains(local.private_dns_zone_names_effective, "privatelink.azuredatabricks.net")
    ? try(module.private_dns.zone_ids["privatelink.azuredatabricks.net"], "")
    : ""
  ])
  private_dns_zone_names                     = var.databricks_private_dns_zone_names
  private_dns_zone_resource_group_name       = var.databricks_private_dns_zone_resource_group_name
  private_endpoint_manual_connection_enabled = var.databricks_private_endpoint_manual_connection_enabled
  private_endpoint_request_message           = var.databricks_private_endpoint_request_message
  private_endpoint_network_interface_name    = var.databricks_private_endpoint_network_interface_name

  enable_diagnostics                        = var.databricks_enable_diagnostics
  log_analytics_workspace_id                = trimspace(var.databricks_log_analytics_workspace_id) != "" ? var.databricks_log_analytics_workspace_id : (var.databricks_enable_diagnostics ? local.log_analytics_resource_id : "")
  diagnostic_storage_account_id             = var.databricks_diagnostic_storage_account_id
  diagnostic_eventhub_authorization_rule_id = var.databricks_diagnostic_eventhub_authorization_rule_id
  diagnostic_eventhub_name                  = var.databricks_diagnostic_eventhub_name
  diagnostic_setting_name                   = var.databricks_diagnostic_setting_name

  role_assignments = var.databricks_role_assignments
  app_env          = var.environment
  workload         = var.workload
  app_admin_group  = var.app_admin_group
  app_user_group   = var.app_user_group
  tags             = {}

  depends_on = [
    module.resource_group,
    module.spoke_virtual_network,
    module.network_security_group,
    azurerm_subnet_network_security_group_association.spoke_network_security_group,
    module.private_dns,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Integration: Azure Data Factory
# -------------------------------------------------------------------

module "adf_basic" {
  count  = local.feature_flags.enable_adf ? 1 : 0
  source = "../template/modules/adf"
  #source = "../template/modules/adf"

  name     = var.workload
  workload = var.workload
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = {}

  depends_on = [
    module.spoke_virtual_network,
    module.private_dns,
    module.storage_account,
    module.keyvault,
    module.log_analytics
  ]
}

# -------------------------------------------------------------------
# Windows VM: Jumpbox
# -------------------------------------------------------------------

module "winvm_basic" {
  count = local.feature_flags.enable_winvm ? 1 : 0

  source = "../template/modules/winvm"
  #source = "../template/modules/winvm"

  location = trimspace(var.winvm_location) != "" ? var.winvm_location : module.resource_group.location
  app_env  = trimspace(var.winvm_app_env) != "" ? var.winvm_app_env : var.environment

  app_rg      = trimspace(var.winvm_resource_group_name) != "" ? var.winvm_resource_group_name : module.resource_group.name
  app_snet    = trimspace(var.winvm_subnet_name) != "" ? var.winvm_subnet_name : "snet-jumpbox"
  app_vnet_rg = trimspace(var.winvm_vnet_resource_group_name) != "" ? var.winvm_vnet_resource_group_name : module.resource_group.name
  app_vnet    = trimspace(var.winvm_vnet_name) != "" ? var.winvm_vnet_name : local.spoke_vnet_name
  app_vm      = trimspace(var.winvm_vm_name) != "" ? var.winvm_vm_name : substr("vm${replace(var.workload, "-", "")}", 0, 13)

  iac_rg = trimspace(var.winvm_iac_rg) != "" ? var.winvm_iac_rg : module.resource_group.name
  iac_kv = trimspace(var.winvm_iac_kv) != "" ? var.winvm_iac_kv : module.keyvault.name
  iac_st = trimspace(var.winvm_iac_st) != "" ? var.winvm_iac_st : module.storage_account.name

  admin_credentials_key_vault_id = trimspace(var.winvm_admin_credentials_key_vault_id) != "" ? var.winvm_admin_credentials_key_vault_id : ""
  admin_username_secret_name     = trimspace(var.winvm_admin_username_secret_name) != "" ? var.winvm_admin_username_secret_name : "azure-user"
  admin_password_secret_name     = trimspace(var.winvm_admin_password_secret_name) != "" ? var.winvm_admin_password_secret_name : "azure-password"
  azure-user                     = var.winvm_admin_username
  azure-password                 = var.winvm_admin_password

  app_vm_number      = var.winvm_vm_count
  app_vm_size        = var.winvm_vm_size
  disksize           = var.winvm_data_disk_size_gb
  enable_zone_spread = var.winvm_enable_zone_spread
  availability_zones = var.winvm_availability_zones

  windows_image_publisher = var.jumpbox_windows_image_publisher
  windows_image_offer     = var.jumpbox_windows_image_offer
  windows_image_sku       = var.jumpbox_windows_image_sku
  windows_image_version   = var.jumpbox_windows_image_version

  AADLoginForWindows               = var.winvm_enable_entra_login
  enable_domain_join               = var.winvm_enable_domain_join
  domain                           = var.winvm_enable_domain_join ? var.winvm_domain : ""
  domain_join_user                 = var.winvm_enable_domain_join ? var.winvm_domain_join_user : ""
  enable_custom_script_extension   = var.winvm_enable_custom_script_extension
  enable_defender_performance_mode = var.winvm_enable_defender_performance_mode
  enable_shir                      = var.winvm_enable_shir
  adf_id                           = var.winvm_enable_shir ? try(module.adf_basic[0].id, null) : null
  patch_mode                       = var.winvm_patch_mode

  app_user_group  = length(var.winvm_app_user_group) > 0 ? var.winvm_app_user_group : var.app_user_group
  app_admin_group = length(var.winvm_app_admin_group) > 0 ? var.winvm_app_admin_group : var.app_admin_group

  public_network_enabled        = var.winvm_public_network_enabled
  enable_diagnostics            = var.winvm_enable_diagnostics
  log_analytics_workspace_id    = var.winvm_enable_diagnostics ? module.log_analytics.id : ""
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = var.winvm_tags

  depends_on = [
    module.spoke_virtual_network,
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

  source = "../template/modules/linuxvm"
  #source = "../template/modules/linuxvm"
  #source = "../allmodules/modules/linuxvm"

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
  #datadog_api_key  = var.linux_vm_datadog_api_key

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
    module.spoke_virtual_network,
    module.storage_account,
    module.keyvault,
    azapi_update_resource.storage_account_blob_service,
    azapi_resource.shared_storage_container
  ]
  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = var.linux_vm_rg_tags
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
  source = "../template/modules/aks"
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

  inherit_resource_group_tags   = true
  inherited_resource_group_tags = local.rg_tags
  tags                          = var.aks_tags

  depends_on = [
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
  source = "../template/modules/sqldb"
  #source = "../template/modules/sqldb"

  server_name                    = local.sql_server_name
  database_name                  = local.sql_database_name
  workload                       = var.workload
  max_size_gb                    = var.sql_max_size_gb
  backup_storage_redundancy      = var.sql_backup_storage_redundancy
  public_network_access_enabled  = var.sql_public_network_access_enabled
  firewall_rules                 = var.sql_firewall_rules
  admin_username                 = var.sql_admin_username
  admin_password                 = var.sql_admin_password
  admin_credentials_key_vault_id = local.sql_admin_credentials_key_vault_id_effective
  admin_username_secret_name     = trimspace(var.sql_admin_username_secret_name) != "" ? var.sql_admin_username_secret_name : "sqladmin-username"
  admin_password_secret_name     = trimspace(var.sql_admin_password_secret_name) != "" ? var.sql_admin_password_secret_name : "sqladminuser-password"
  ad_admin_login_name            = var.sql_ad_admin_login
  ad_admin_object_id             = var.sql_ad_admin_object_id
  sku_name                       = var.sql_sku_name
  use_free_limit                 = var.sql_use_free_limit
  free_limit_exhaustion_behavior = var.sql_free_limit_exhaustion_behavior
  auto_pause_delay_in_minutes    = var.sql_auto_pause_delay_in_minutes
  min_capacity                   = var.sql_min_capacity
  geo_backup_enabled             = var.sql_geo_backup_enabled
  resource_group_name            = module.resource_group.name
  app_env                        = var.environment
  location                       = var.location
  enable_private_endpoint        = var.sql_enable_private_endpoint
  private_endpoint_subnet_id     = var.sql_enable_private_endpoint ? local.spoke_subnet_resource_ids.private_endpoints : ""
  app_admin_group                = var.app_admin_group
  app_user_group                 = var.app_user_group
  inherit_resource_group_tags    = true
  inherited_resource_group_tags  = local.rg_tags
  tags                           = {}


  depends_on = [
    module.spoke_virtual_network,
    module.private_dns
  ]
}
