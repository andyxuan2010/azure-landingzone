# -------------------------------------------------------------------
# Shared Landing Zone Inputs
# -------------------------------------------------------------------

features = {
  enable_management_group                = false
  enable_subscription_bootstrap          = false
  enable_private_dns                     = true
  enable_adf                             = true
  enable_azure_ai_search                 = true
  enable_azure_ai_service                = true
  enable_openai                          = true
  enable_acr                             = false
  enable_app_services                    = true
  enable_app_registration_for_appservice = true
  enable_automation_accounts             = true
  enable_automation_ari_workloads        = true
  enable_winvm                           = false
  enable_linux_vm                        = false
  enable_aks                             = false
  enable_sqldb                           = true
  enable_databricks                      = false
  enable_vnet                            = true
  enable_nsg                             = true
  enable_fortigate                       = false

}

azure_ai_search_sku = "free" # "standard", "standard2", "standard3", or "free"


subscription_id              = "bb759f2e-505c-4524-9e64-8bfae839b384"
tenant_id                    = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
prod_subscription_id         = "bb759f2e-505c-4524-9e64-8bfae839b384"
prod_tenant_id               = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
identity_subscription_id     = "bb759f2e-505c-4524-9e64-8bfae839b384"
identity_tenant_id           = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
management_subscription_id   = "bb759f2e-505c-4524-9e64-8bfae839b384"
management_tenant_id         = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
connectivity_subscription_id = "bb759f2e-505c-4524-9e64-8bfae839b384"
connectivity_tenant_id       = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
security_subscription_id     = "bb759f2e-505c-4524-9e64-8bfae839b384"
security_tenant_id           = "b0f3630d-e5de-4172-b492-0cf5cd387a41"

location            = "canadacentral"
workload            = "platform"
environment         = "sbx"
resource_group_name = "rg-platform-sbx"
hub_vnet_name       = "vnet-hub-platform-sbx"
spoke_vnet_name     = "vnet-spoke-platform-sbx"
nsg_name            = "nsg-platform-sbx-spoke"

# -------------------------------------------------------------------
# Governance Module Inputs
# -------------------------------------------------------------------

# Governance modules are optional because they require broader tenant or billing permissions.
enable_management_group = false
platform_mg_name        = "mg-platform-sbx"
landingzone_mg_name     = "mg-landingzone-sbx"
sandbox_mg_name         = "mg-sandboxes"
landingzone_mg_display  = "Landing Zones Sbx"
platform_mg_display     = "Platform Sbx"
sandbox_mg_display      = "Sandboxes"

management_group_parent_management_group_id = ""
mg_platform_children = {
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

mg_landingzone_children = {}

# -------------------------------------------------------------------
# Subscription Vending Module Inputs
# -------------------------------------------------------------------

enable_subscription_bootstrap    = false
subscription_alias_enabled       = false
subscription_alias_name          = ""
subscription_name                = "platform-landingzone-sbx"
billing_scope_id                 = ""
existing_subscription_id         = "/subscriptions/<subscription-id>"
subscription_management_group_id = ""
subscription_resource_provider_registrations = [
  # "Microsoft.Network",
  # "Microsoft.KeyVault",
  # "Microsoft.Storage",
  # "Microsoft.Web",
  # "Microsoft.Insights",
  # "Microsoft.DataFactory",
  # "Microsoft.Databricks",
  # "Microsoft.Compute"
]
hierarchy_subscriptions = {
  landingzone = {
    subscription_name        = "sub-landingzone-sbx"
    existing_subscription_id = "/subscriptions/1ec5edd4-5654-4246-8027-b29ef63b3393"
    management_group_key     = "landingzone"
  }
  # sandbox_74c3c03d = {
  #   subscription_name        = "sub-sandbox-74c3c03d"
  #   existing_subscription_id = "/subscriptions/74c3c03d-217f-4138-b9a6-79145d37781a"
  #   management_group_key     = "sandboxes"
  # }
  # sandbox_624ce74e = {
  #   subscription_name        = "sub-sandbox-624ce74e"
  #   existing_subscription_id = "/subscriptions/624ce74e-cf6e-4eed-afba-352bcf08bca0"
  #   management_group_key     = "sandboxes"
  # }

  # Add more existing subscriptions by using a unique map key and a subscription_name that starts with "sub-".

  # connectivity_hub = {
  #   subscription_alias_enabled = true
  #   subscription_alias_name    = "sub-connectivity-hub-sbx"
  #   subscription_name          = "sub-connectivity-hub-sbx"
  # #  #billing_scope_id           = "/providers/Microsoft.Billing/billingAccounts/4731eb74-36ce-5a78-aebe-3f1ac242125d:baddfb2d-4636-4058-912a-f5493d28e166_2019-05-31/billingProfiles/MI36-G4SS-BG7-PGB/invoiceSections/ZOUU-SIAW-PJA-PGB"
  #   billing_scope_id           = "/providers/Microsoft.Billing/billingAccounts/4731eb74-36ce-5a78-aebe-3f1ac242125d:baddfb2d-4636-4058-912a-f5493d28e166_2019-05-31/billingProfiles/RVBO-3VST-BG7-PGB/invoiceSections/ZSKE-S42H-PJA-PGB"
  #   existing_subscription_id   = ""
  #   management_group_key       = "connectivity"
  # }
  connectivity_hub = {
    subscription_name        = "sub-connectivity-hub-sbx"
    existing_subscription_id = "/subscriptions/d3927a5b-0ea7-40e1-bbb5-d3ba34515fb0"
    management_group_key     = "connectivity"
  }
  #landing zone 1ec5edd4-5654-4246-8027-b29ef63b3393
  #RVBO-3VST-BG7-PGB/ZSKE-S42H-PJA-PGB

  #Identity Service 74c3c03d-217f-4138-b9a6-79145d37781a
  #MI36-G4SS-BG7-PGB/ZOUU-SIAW-PJA-PGB
  #Magement Shared 624ce74e-cf6e-4eed-afba-352bcf08bca0
  #NMMZ-K5KB-BG7-PGB/DH7B-ZORQ-PJA-PGB

  identity_services = {
    subscription_name        = "sub-identity-services-sbx"
    existing_subscription_id = "/subscriptions/74c3c03d-217f-4138-b9a6-79145d37781a"
    management_group_key     = "identity"
  }
  security_tools = {
    subscription_alias_enabled = true
    subscription_alias_name    = "sub-security-tools-sbx"
    subscription_name          = "sub-security-tools-sbx"
    billing_scope_id           = "/providers/Microsoft.Billing/billingAccounts/4731eb74-36ce-5a78-aebe-3f1ac242125d:baddfb2d-4636-4058-912a-f5493d28e166_2019-05-31/billingProfiles/RVBO-3VST-BG7-PGB/invoiceSections/ZSKE-S42H-PJA-PGB"
    existing_subscription_id   = ""
    management_group_key       = "security"
  }

  management_shared = {
    subscription_name        = "sub-management-shared-sbx"
    existing_subscription_id = "/subscriptions/624ce74e-cf6e-4eed-afba-352bcf08bca0"
    management_group_key     = "management"
  }
}

# -------------------------------------------------------------------
# Foundation Module Inputs
# -------------------------------------------------------------------

# Leave these empty to use the default landing zone naming convention.
managed_identity_name = "" # default: id-platform-cc-sbx
storage_account_name  = "" # default: stplatformccsbx
key_vault_name        = "" # default: kvplatformccsbx
log_analytics_name    = "" # default: law-platform-cc-sbx
firewall_name         = "" # default: afw-platform-cc-sbx
route_table_name      = "" # default: rt-platform-cc-sbx-egress
adf_name              = "adf-platform-cc-sbx"

# Storage account data protection defaults:
# - Blob versioning, blob soft delete, container soft delete, change feed, and restore policy are enabled by default.
# - Immutability is container-level and intentionally empty by default, because applying it to the terraform state container can block future state writes.
storage_account_blob_versioning_enabled              = true
storage_account_blob_soft_delete_enabled             = true
storage_account_blob_soft_delete_retention_days      = 14
storage_account_container_soft_delete_enabled        = true
storage_account_container_soft_delete_retention_days = 7
storage_account_change_feed_enabled                  = true
storage_account_change_feed_retention_in_days        = null
storage_account_blob_restore_policy_enabled          = true
storage_account_blob_restore_policy_days             = 7
storage_account_allow_state_container_immutability   = false
storage_account_container_immutability_policies      = {}

# -------------------------------------------------------------------
# Network Module Inputs
# -------------------------------------------------------------------

hub_address_space   = ["10.167.32.0/20"]
spoke_address_space = ["10.167.64.0/20"]
#gateway_subnet_prefixes            = ["10.167.64.0/26"]
firewall_subnet_prefixes                     = ["10.167.33.64/26"]
fortigate_external_subnet_prefixes           = ["10.167.34.0/24"]
fortigate_internal_subnet_prefixes           = ["10.167.35.0/24"]
fortigate_create_dedicated_vnet              = false
fortigate_virtual_network_name               = ""
fortigate_virtual_network_address_space      = ["10.168.32.0/22"]
fortigate_dedicated_external_subnet_prefixes = ["10.168.32.0/24"]
fortigate_dedicated_internal_subnet_prefixes = ["10.168.33.0/24"]
fortigate_admin_ssh_source_address_prefixes  = ["107.171.157.217/32"]
app_subnet_prefixes                          = ["10.167.70.0/24"]
private_endpoint_subnet_prefixes             = ["10.167.71.0/24"]
databricks_public_subnet_prefixes            = ["10.167.72.0/24"]
databricks_private_subnet_prefixes           = ["10.167.73.0/24"]
aks_subnet_prefixes                          = ["10.167.74.0/24"]
jumpbox_subnet_prefixes                      = ["10.167.75.0/24"]
sqlmi_subnet_prefixes                        = ["10.167.76.0/24"]
vnet_integration_prefixes                    = ["10.167.77.0/24"]
#sql_subnet_prefixes                = ["10.167.77.0/24"]

private_dns_zone_names = [
  # "privatelink.blob.core.windows.net",
  # "privatelink.vaultcore.azure.net",
  "privatelink.azurewebsites.net",
  #"privatelink.azuredatabricks.net",
  # "privatelink.azurecr.io",
  # "privatelink.azure-automation.net",
  # "privatelink.servicebus.windows.net",
  # "privatelink.cognitiveservices.azure.com",
  # "privatelink.datafactory.azure.net",
  # "privatelink.database.windows.net"
]

# -------------------------------------------------------------------
# Optional Network and Observability Inputs
# -------------------------------------------------------------------

firewall_sku_tier                                = "Standard"
log_analytics_retention_in_days                  = 30
log_analytics_internet_ingestion_enabled         = true
log_analytics_internet_query_enabled             = true
log_analytics_local_authentication_disabled      = false
log_analytics_reservation_capacity_in_gb_per_day = null

# -------------------------------------------------------------------
# Databricks Workspace
# -------------------------------------------------------------------

databricks_name                                  = "dbr-platform-cc-sbx"
databricks_inherit_resource_group_tags           = false
databricks_sku                                   = "premium"
databricks_managed_resource_group_name           = ""
databricks_public_network_access_enabled         = true
databricks_network_security_group_rules_required = "NoAzureDatabricksRules"

# -------------------------------------------------------------------
# Databricks Access Connector / Storage Firewall
# -------------------------------------------------------------------

databricks_default_storage_firewall_enabled                  = false
databricks_access_connector_id                               = ""
databricks_create_access_connector                           = false
databricks_access_connector_name                             = ""
databricks_access_connector_system_assigned_identity_enabled = true
databricks_access_connector_identity_ids                     = []
databricks_access_connector_role_assignments                 = {}

# -------------------------------------------------------------------
# Databricks VNet Injection
# -------------------------------------------------------------------

databricks_custom_parameters = {
  no_public_ip         = true
  virtual_network_id   = ""
  public_subnet_name   = "snet-databricks-public"
  private_subnet_name  = "snet-databricks-private"
  storage_account_name = ""
}

# -------------------------------------------------------------------
# Databricks Private Endpoint / Private DNS
# -------------------------------------------------------------------

databricks_private_endpoint_subnet_id                   = ""
databricks_private_endpoint_subnet_name                 = "snet-private-endpoints"
databricks_private_endpoint_vnet_name                   = "vnet-spoke-platform-sbx"
databricks_private_endpoint_network_resource_group_name = "rg-platform-sbx"
databricks_private_endpoint_subresource_names           = []
databricks_private_dns_zone_ids                         = []
databricks_private_dns_zone_names                       = []
databricks_private_dns_zone_resource_group_name         = null
databricks_private_endpoint_manual_connection_enabled   = false
databricks_private_endpoint_request_message             = ""
databricks_private_endpoint_network_interface_name      = ""

# -------------------------------------------------------------------
# Databricks Diagnostics / RBAC
# -------------------------------------------------------------------

databricks_enable_diagnostics                        = false
databricks_log_analytics_workspace_id                = ""
databricks_diagnostic_storage_account_id             = null
databricks_diagnostic_eventhub_authorization_rule_id = null
databricks_diagnostic_eventhub_name                  = null
databricks_diagnostic_setting_name                   = ""
databricks_role_assignments                          = {}

# -------------------------------------------------------------------
# Shared RBAC and Jumpbox Inputs
# -------------------------------------------------------------------

# Applies to both the shared storage account and Key Vault modules.
# Storage account: Contributor; Key Vault: Key Vault Administrator.
app_admin_group                = ["534422f9-5a5e-4ebe-86f6-714fb9d17fe3"]
app_user_group                 = []
jumpbox_public_network_enabled = true

# -------------------------------------------------------------------
# Windows VM Module Inputs
# -------------------------------------------------------------------

enable_winvm = true

winvm_vm_name  = "vmplatform"
winvm_app_env  = "sbx"
winvm_vm_count = 1
winvm_vm_size  = "Standard_B2ms"

# Leave these values empty ("") to use secrets from winvm_admin_credentials_key_vault_id.
winvm_admin_username                 = ""
winvm_admin_password                 = ""
winvm_admin_credentials_key_vault_id = "/subscriptions/bb759f2e-505c-4524-9e64-8bfae839b384/resourceGroups/rg-ccoe-iac-cc-sbx/providers/Microsoft.KeyVault/vaults/kv-ccoe-cc-sbx"
winvm_admin_username_secret_name     = "azure-user"
winvm_admin_password_secret_name     = "azure-password"

winvm_iac_rg = "rg-ccoe-iac-cc-sbx"
winvm_iac_kv = "kv-ccoe-cc-sbx"
winvm_iac_st = "stccoeiacccsbx"

winvm_resource_group_name      = ""
winvm_subnet_name              = ""
winvm_vnet_resource_group_name = ""
winvm_vnet_name                = ""

winvm_public_network_enabled           = false
winvm_enable_entra_login               = true
winvm_enable_domain_join               = false
winvm_domain                           = "example.com"
winvm_domain_join_user                 = "serviceaccount@example.com"
winvm_enable_custom_script_extension   = false
winvm_enable_defender_performance_mode = false
winvm_enable_shir                      = false
winvm_enable_diagnostics               = false

winvm_app_user_group  = []
winvm_app_admin_group = ["534422f9-5a5e-4ebe-86f6-714fb9d17fe3"]
winvm_tags = {
  "ADO Project" = "CCOE-Azure"
  "ADO Repo"    = "landingzone"
}

# -------------------------------------------------------------------
# Azure Container Registry Module Inputs
# -------------------------------------------------------------------

enable_acr = false

acr_name                          = ""
acr_sku                           = "Premium"
acr_admin_enabled                 = false
acr_public_network_access_enabled = false
acr_anonymous_pull_enabled        = false
acr_data_endpoint_enabled         = false

acr_identity_type                           = "None"
acr_identity_ids                            = []
acr_managed_identity_role_assignments       = {}
acr_customer_managed_key_id                 = null
acr_customer_managed_key_identity_client_id = null

acr_export_policy_enabled     = true
acr_quarantine_policy_enabled = false
acr_retention_policy_in_days  = null
acr_trust_policy_enabled      = false
acr_zone_redundancy_enabled   = false
acr_georeplications           = []

acr_enable_network_rule_set     = false
acr_network_rule_bypass_option  = "AzureServices"
acr_network_rule_default_action = "Deny"
acr_network_rule_ip_rules       = []

acr_enable_private_endpoint              = false
acr_private_dns_zone_id                  = ""
acr_private_dns_zone_name                = ""
acr_private_dns_zone_resource_group_name = ""
acr_enable_diagnostics                   = false
acr_diagnostic_log_categories            = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
acr_diagnostic_metric_categories         = ["AllMetrics"]

# Common jumpbox choices:
# Windows Server 2022 Datacenter:
# jumpbox_windows_image_publisher = "MicrosoftWindowsServer"
# jumpbox_windows_image_offer     = "WindowsServer"
# jumpbox_windows_image_sku       = "2022-Datacenter"
# Windows Server 2022 Azure Edition:
# jumpbox_windows_image_publisher = "MicrosoftWindowsServer"
# jumpbox_windows_image_offer     = "WindowsServer"
# jumpbox_windows_image_sku       = "2022-datacenter-azure-edition"
# Azure Virtual Desktop example:
# jumpbox_windows_image_publisher = "MicrosoftWindowsDesktop"
# jumpbox_windows_image_offer     = "windows-11"
# jumpbox_windows_image_sku       = "win11-23h2-avd"
# Make sure jumpbox_windows_image_publisher, jumpbox_windows_image_offer, jumpbox_windows_image_sku, and jumpbox_windows_image_version match the same image family.
jumpbox_windows_image_publisher = "MicrosoftWindowsServer"
jumpbox_windows_image_offer     = "WindowsServer"
jumpbox_windows_image_sku       = "2022-Datacenter"
jumpbox_windows_image_version   = "latest"

# -------------------------------------------------------------------
# SQL Example Inputs
# -------------------------------------------------------------------

# SQL administrator values for sandbox.
enable_sqldb = true
# Azure SQL free offer profile. When free-limit AutoPause is enabled, the SQL module omits max_size_gb so Azure can use the required platform default.
sql_sku_name                       = "GP_S_Gen5_2"
sql_use_free_limit                 = false
sql_free_limit_exhaustion_behavior = "AutoPause"
sql_auto_pause_delay_in_minutes    = 60
sql_min_capacity                   = 0.5
sql_geo_backup_enabled             = true
sql_max_size_gb                    = 32
sql_backup_storage_redundancy      = "Local"
sql_public_network_access_enabled  = true
sql_enable_private_endpoint        = false
# Example:
sql_firewall_rules = {
  my_ip = {
    start_ip_address = "107.171.157.217"
    end_ip_address   = "107.171.157.217"
  }
}
# sql_admin_username = ""
# sql_admin_password = ""
# sql_admin_username_secret_name     = "azure-user"
# sql_admin_password_secret_name     = "azure-password"
sql_iac_rg = "rg-ccoe-iac-cc-sbx"
sql_iac_kv = "kv-ccoe-cc-sbx"
# sql_admin_credentials_key_vault_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>"
sql_ad_admin_login     = "BA-G-Azure-Owner-F"
sql_ad_admin_object_id = "534422f9-5a5e-4ebe-86f6-714fb9d17fe3"
allowed_policy_locations = [
  "eastus",
  "canadaeast"
]

# -------------------------------------------------------------------
# Platform RBAC and Tag Inputs
# -------------------------------------------------------------------

# Optional platform RBAC assignments.
platform_role_assignments = {}

tags = {}

# -------------------------------------------------------------------
# Beginning of App Service Inputs
# -------------------------------------------------------------------

app_services = {
  dotnet = {
    enabled           = true
    stack             = "dotnet"
    kind              = "Windows"
    plan_os_type      = "Windows"
    sku_name          = "F1"
    use_32_bit_worker = true
    dotnet_version    = "v8.0"
    health_check_path = "/health"
    # deployment_method options:
    # - "deployment_center"
    # - "run_from_package"
    # - "zip_deploy_with_build"
    deployment_method                          = "external_zip_deploy"
    deployment_center_azure_repos_organization = "Bombardier-Enterprise"
    deployment_center_azure_repos_project      = "CCoE-Infra-IaC"
    deployment_center_azure_repos_repository   = "web-ccoedemo-dotnet"
    deployment_center_azure_repos_branch       = "main"
    deployment_center_use_manual_integration   = true
  }

  # seems node 64bit can't be on the F1 plan
  # F1 requires private endpoints and VNet integration to remain disabled.
  #use_32_bit_worker
  node = {
    enabled           = true
    stack             = "node"
    kind              = "Linux"
    plan_os_type      = "Linux"
    sku_name          = "F1"
    use_32_bit_worker = true
    node_version      = "24-lts"
    health_check_path = "/health"
    # deployment_method options:
    # - "deployment_center"
    # - "run_from_package"
    # - "zip_deploy_with_build"
    deployment_method                        = "external_zip_deploy"
    startup_command                          = "cd /home/site/wwwroot && npm start"
    deployment_center_repo_url               = "https://github.com/andyxuan2010/web-ccoedemo-node"
    deployment_center_use_manual_integration = true
    app_settings = {
      WEBSITE_NODE_DEFAULT_VERSION = "~24"
    }
  }

  #linux is cheaper
  # F1 requires private endpoints and VNet integration to remain disabled.
  #use_32_bit_worker
  # deployment_method options:
  # - "deployment_center" : Azure DevOps repo wired through App Service Deployment Center
  # - "run_from_package"  : fully built package mounted with WEBSITE_RUN_FROM_PACKAGE=1
  # - "zip_deploy_with_build" : ZIP pushed by pipeline, then built remotely by App Service/Oryx
  python = {
    enabled      = true
    stack        = "python"
    kind         = "Linux"
    plan_os_type = "Linux"
    sku_name     = "F1"
    #deployment_method                          = "deployment_center"
    # for python, run_from_package is NOT recommended by MS. zip_deploy_with_build is usually the preferable way.
    #deployment_method = "run_from_package"
    deployment_method                        = "run_from_package"
    use_32_bit_worker                        = true
    startup_command                          = "gunicorn --bind=0.0.0.0 --timeout 600 --access-logfile '-' --error-logfile '-' --chdir /home/site/wwwroot app:app"
    python_version                           = "3.12"
    health_check_path                        = "/health"
    deployment_center_repo_url               = "https://github.com/andyxuan2010/web-ccoedemo-python"
    deployment_center_use_manual_integration = true
  }
}

app_service_plan_enable_diagnostics                 = true
app_service_plan_enable_autoscale                   = false
app_service_plan_autoscale_min_capacity             = 1
app_service_plan_autoscale_default_capacity         = 1
app_service_plan_autoscale_max_capacity             = 3
app_service_plan_autoscale_cpu_threshold_scale_up   = 75
app_service_plan_autoscale_cpu_threshold_scale_down = 25
app_service_plan_autoscale_scale_up_increment       = 1
app_service_plan_autoscale_scale_down_increment     = 1

enable_app_registration_for_appservice = true
app_service_auth_mode                  = "both"
app_service_allow_anonymous            = true
app_service_unauthenticated_action     = "AllowAnonymous"
app_registration_display_name          = null
app_registration_web_redirect_uris     = []
app_registration_create_client_secret  = true

app_service_app_secret_key                = "replace-with-a-random-secret-32-long"
app_service_enable_private_endpoint       = false
app_service_public_network_access_enabled = true
app_service_ip_restriction_default_action = "Deny"
app_service_ip_restrictions = [
  {
    name       = "Allow-HTTPS-107-171-157-217"
    priority   = 100
    action     = "Allow"
    ip_address = "107.171.157.217/32"
  }
]
app_service_scm_ip_restriction_default_action              = "Deny"
app_service_scm_ip_restrictions                            = []
app_service_scm_use_main_ip_restriction                    = false
app_service_scmIpSecurityRestrictionsUseMain               = null
app_service_vnet_integration_enabled                       = false
app_service_vnet_route_all_enabled                         = false
app_service_scm_basic_auth_publishing_credentials_enabled  = true
app_service_webdeploy_publish_basic_authentication_enabled = true


# these 2 settings for ado git source deployment
# deployment_method controls these two settings for each app:
# - deployment_center / zip_deploy_with_build => true
# - run_from_package => false
app_service_app_settings = {
  SCM_DO_BUILD_DURING_DEPLOYMENT = true
  ENABLE_ORYX_BUILD              = true
  AZURE_OPENAI_CHAT_DEPLOYMENT   = "gpt-4o"
  AZURE_OPENAI_EMBED_DEPLOYMENT  = "text-embedding-ada-002"
  AZURE_SEARCH_INDEX             = "index"
}

# -------------------------------------------------------------------
# End of App Service Inputs
# -------------------------------------------------------------------


# -------------------------------------------------------------------
# Beginning of Automation Account Inputs
# -------------------------------------------------------------------

automation_accounts = {
  default = {
    enabled = true
    # name                          = "aa-platform-eastus-sbx-default"
    sku_name                        = "Basic"
    local_auth_enabled              = false
    public_access_enabled           = true
    system_managed_identity_enabled = true

    # Leave these empty to inherit the root app_admin_group / app_user_group values.
    app_admin_group = ["534422f9-5a5e-4ebe-86f6-714fb9d17fe3"]
    app_user_group  = []

    # Example managed identity role assignment:
    # managed_identity_role_assignments = {
    #   storage_blob_data_contributor = {
    #     scope                = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Storage/storageAccounts/<name>"
    #     role_definition_name = "Storage Blob Data Contributor"
    #   }
    # }
    managed_identity_role_assignments = {}

    # Private endpoint options:
    # - Set private_endpoint_enabled = true to use the landing zone snet-private-endpoints subnet by default.
    # - Also add "privatelink.azure-automation.net" to private_dns_zone_names when you want the root private DNS module to auto-wire the zone.
    # - enable_hrw_private_endpoint requires public_access_enabled = false.
    private_endpoint_enabled                     = false
    private_endpoint_subresource_name            = "Webhook"
    enable_webhook_private_endpoint              = null
    enable_hrw_private_endpoint                  = null
    private_endpoint_subnet_id                   = ""
    private_endpoint_subnet_name                 = null
    private_endpoint_vnet_name                   = null
    private_endpoint_network_resource_group_name = null
    private_dns_zone_id                          = ""

    enable_diagnostics           = false
    diagnostic_log_categories    = ["JobLogs", "JobStreams", "AuditEvent", "DscNodeStatus"]
    diagnostic_metric_categories = ["AllMetrics"]

    tags = {}
  }
}

# -------------------------------------------------------------------
# Beginning of Automation ARI Workload Inputs
# -------------------------------------------------------------------

automation_ari_workloads = {
  default = {
    enabled                = true
    automation_account_key = "default"

    # The landing zone creates this container in the shared storage account for ARI output.
    storage_container_name               = "ari"
    report_name                          = "CCOE_AZURE"
    report_dir                           = "C:\\AzureResourceInventory"
    ari_lite_mode                        = false
    ari_diagram_full_environment_enabled = false
    ari_security_center_enabled          = true

    runbook_name             = "ARI_Runbook"
    runtime_environment_name = "PowerShell-7.4-Env"
    runbook_template_path    = "runbooks/ari.ps1.tftpl"

    # Leave empty to use the built-in ARI package set:
    # - AzureResourceInventory
    # - ImportExcel
    # - Az.ResourceGraph
    # - Az.CostManagement
    runtime_packages = {}

    schedule_enabled     = true
    schedule_name        = "Azure Inventory Collection - daily"
    schedule_description = "Daily schedule for the ARI runbook."
    schedule_frequency   = "Day"
    schedule_interval    = 1
    schedule_timezone    = "America/Toronto"
    # schedule_start_time = "2026-04-28T08:00:00-04:00"

    runbook_log_verbose  = true
    runbook_log_progress = true

    enable_job_failure_alert = true
    job_failure_alert_name   = null
    job_failure_severity     = 2

    enable_long_running_alert      = true
    long_running_alert_name        = null
    long_running_severity          = 3
    long_running_threshold_minutes = 90

    alert_evaluation_frequency = "PT15M"
    alert_window_duration      = "PT15M"

    # Add Azure Monitor action group resource IDs when you want notifications.
    monitor_action_group_ids = []

    tags = {}
  }
}

# -------------------------------------------------------------------
# End of Automation ARI Workload Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# End of Automation Account Inputs
# -------------------------------------------------------------------



# -------------------------------------------------------------------
# Beginning of Linux VM Module Inputs
# -------------------------------------------------------------------

enable_linux_vm = true

# To refresh linux_vm_rg_tags from the existing resource group in Azure, run:
# $rgName="rg-ba-cc-prd-shared-management"; $tags=az group show --name $rgName --query tags -o json | ConvertFrom-Json; $keys=$tags.PSObject.Properties.Name | Sort-Object; $maxLen=($keys | % { $_.Length } | measure -Maximum).Maximum; "linux_vm_rg_tags = {"; foreach($key in $keys){$padding=" " * ($maxLen-$key.Length); $value=[string]$tags.$key; '  "{0}"{1} = "{2}"' -f $key,$padding,$value}; "}"

linux_vm_rg_tags = {
  "ADO Project" = "CCOE-Azure"
  "ADO Repo"    = "landingzone"
}

# use the global one
#linux_vm_location = ""
#linux_vm_app_env  = ""
linux_vm_workload = "runner"

# Linux VM admin credential precedence:
# - Leave these values empty ("") to use secrets from linux_vm_iac_kv.
# - Set any of them to a non-empty value only when you intentionally want to override the Key Vault secret at deploy time.

linux_vm_admin_password = ""
linux_vm_admin_username = ""
linux_vm_admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIqfriZJbopqGHXo1gVfxo7LNF7rx+Yq1qSFpLeojDS4DWr/a8v2dpevDf95Xku/BGLZ16eRQFlW4/YFfhpPIy1sYVlaJQVOiALN8sk1R5OuGjLXy2e22SRVgH0LQehHCLwmszjuLhbmDO8qjNnzm0JIYHmv4+VkZ56LI8rTiPozHmKGxgKfhKhV1vh9NzdCnj7Nh/iQWAU82X5UzYU6J6t7Ape1bp4C74yPH3NOcVcV51qKZXiamfM2PfPnU11I+Wd7Ho8l1yvpUUZe0FdSBZtp7oWya+oPy5AXJlfuMCq5WjVUO9LCvpZMsJWQDhocMFuDRiNw4+0G/XnathEiRP"
# linux_vm_disable_password_authentication = true
linux_vm_admin_username_secret_name = ""
linux_vm_admin_password_secret_name = ""
linux_vm_admin_ssh_key_secret_name  = ""

# this is the second priority after the above individual credential values. It should point to a Key Vault secret with a JSON object that has "username", "password", and/or "ssh_key" properties.
# linux_vm_admin_credentials_key_vault_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>"
linux_vm_iac_kv_id = "/subscriptions/bb759f2e-505c-4524-9e64-8bfae839b384/resourceGroups/rg-ccoe-iac-cc-sbx/providers/Microsoft.KeyVault/vaults/kv-ccoe-cc-sbx"

# this is the third priority credential source. The landing zone will look for secrets with specific names in this storage account and use them if found. This is useful for testing credential updates by uploading new secrets to storage without modifying terraform variables or Key Vault secrets.
linux_vm_iac_rg = "rg-ccoe-iac-cc-sbx"
linux_vm_iac_kv = "kv-ccoe-cc-sbx"

# the fourth priority credential source is the built-in defaults in the Linux VM module, which are not recommended for production use but can be useful for quick testing or as a fallback.

# Post-init customization usage:
# - Leave linux_vm_post_init_script = "" to run only the module's built-in init.sh bootstrap.
# - Or load it from a checked-in shell script under scripts/.

#linux_vm_datadog_api_key   = ""
linux_vm_data_disk_size_gb = 0
#linux_vm_vm_count          = 1
linux_vm_ado_runner_count = 1
# Set linux_vm_ado_runner_count to 2 or 3 when you want multiple Azure DevOps agents on the same VM.# Common VM sizes for linux_vm_vm_size:
# Common VM sizes for linux_vm_vm_size:
# Pricing below is Linux pay-as-you-go in Canada Central as of 2026-03-22.
# Monthly price is an estimate based on 730 hours and excludes disks, networking, backup, tax, and discounts.
# Smaller dev/test VM sizes:
# Standard_B1ls    = 1 vCPU, 0.5 GiB RAM, 4.23 USD/month
# Standard_B1s     = 1 vCPU, 1 GiB RAM, 8.47 USD/month
# Standard_B1ms    = 1 vCPU, 2 GiB RAM, 16.79 USD/month
# Standard_B2as_v2 = 2 vCPU, 4 GiB RAM, 61.03 USD/month
# Standard_B2s     = 2 vCPU, 4 GiB RAM, 33.87 USD/month
# Standard_B2ms    = 2 vCPU, 8 GiB RAM, 67.74 USD/month
# General-purpose VM sizes:
# Standard_D2s_v3  = 2 vCPU, 8 GiB RAM, 81.03 USD/month
# Standard_D4s_v3  = 4 vCPU, 16 GiB RAM, 162.06 USD/month
# Standard_D8s_v3  = 8 vCPU, 32 GiB RAM, 324.12 USD/month
# Standard_D2s_v5  = 2 vCPU, 8 GiB RAM, 78.11 USD/month
# Standard_D4s_v5  = 4 vCPU, 16 GiB RAM, 156.22 USD/month
# Standard_D8s_v5  = 8 vCPU, 32 GiB RAM, 312.44 USD/month
# Memory-optimized VM sizes:
# Standard_E2s_v3  = 2 vCPU, 16 GiB RAM, 106.58 USD/month
# Standard_E4s_v3  = 4 vCPU, 32 GiB RAM, 213.16 USD/month
# Standard_E8s_v3  = 8 vCPU, 64 GiB RAM, 426.32 USD/month
# Standard_E2s_v5  = 2 vCPU, 16 GiB RAM, 100.74 USD/month
# Standard_E4s_v5  = 4 vCPU, 32 GiB RAM, 201.48 USD/month
# Standard_E8s_v5  = 8 vCPU, 64 GiB RAM, 402.96 USD/month
# Example:
# linux_vm_vm_size = "Standard_D4s_v3"

linux_vm_vm_size = "Standard_B1ms"

linux_vm_public_network_enabled = true
linux_vm_enable_entra_ssh_login = true
# Localization extension behavior:
# - Leave linux_vm_enable_linux_vm_extension = false to rely only on custom_data/init.sh and optional post-init content.
# - Set it to true only when you want the VM to download and run localization scripts from the shared IaC storage account.
# - linux_vm_enable_system_assigned_identity must stay true when the localization extension is enabled so the VM can read from storage.

linux_vm_enable_linux_vm_extension       = false
linux_vm_enable_system_assigned_identity = true
linux_vm_localization_container_name     = "localization"
#linux_vm_localization_os_script_name     = "ubuntu.sh"
linux_vm_upload_shared_localization_scripts = true
# Domain join behavior:
# - Leave linux_vm_enable_domain_join = false to keep the Linux VM off domain and skip the domain-join secret lookup.
# - Set it to true only when you want init.sh to attempt AD join during bootstrap.

linux_vm_enable_domain_join = false

# Popular values for linux_vm_image_offer:
# Canonical:
# linux_vm_image_offer = "ubuntu-24_04-lts"
# linux_vm_image_offer = "ubuntu-22_04-lts"
# linux_vm_image_offer = "0001-com-ubuntu-server-jammy"
# Red Hat:
# linux_vm_image_offer = "RHEL"
# linux_vm_image_offer = "RHEL-SAP"
# SUSE:
# linux_vm_image_offer = "sles-15-sp5"
# Debian:
# linux_vm_image_offer = "debian-12"
# Oracle:
# linux_vm_image_offer = "oracle-linux"
# Make sure linux_vm_image_publisher, linux_vm_image_offer, linux_vm_image_sku, and linux_vm_image_version match the same image family.

linux_vm_image_publisher = "Canonical"
linux_vm_image_offer     = "ubuntu-24_04-lts"
linux_vm_image_sku       = "server"
linux_vm_image_version   = "latest"

linux_vm_domain           = "example.com"
linux_vm_domain_join_user = "serviceaccount@example.com"
linux_vm_domain_join_ou   = "azure"

# linux_vm_iac_rg = "rg-platform-sbx"
# linux_vm_iac_kv = "kvappeastusvx53"
# linux_vm_iac_kv_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>"
# linux_vm_iac_st = "stccoeiacdev"
# linux_vm_iac_st_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>"
# linux_vm_iac_st_primary_blob_endpoint = "https://<storage-account-name>.blob.core.windows.net/"
# linux_vm_resource_group_name      = "rg-platform-sbx"
# linux_vm_subnet_name    = "snet-jumpbox"
# linux_vm_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
# linux_vm_vnet_name    = "vnet-spoke-platform-sbx"
# linux_vm_vnet_resource_group_name = "rg-platform-sbx"
# linux_vm_vnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>"

linux_vm_iac_st                       = ""
linux_vm_iac_st_id                    = ""
linux_vm_iac_st_primary_blob_endpoint = ""
linux_vm_resource_group_name          = ""
linux_vm_subnet_name                  = ""
linux_vm_subnet_id                    = ""
linux_vm_vnet_name                    = ""
linux_vm_vnet_resource_group_name     = ""
linux_vm_vnet_id                      = ""
linux_vm_vm_name                      = ""
# Linux access groups:
# - linux_vm_app_user_group is the preferred input for SSH access groups and gets Reader on each VM resource.
# - linux_vm_app_admin_group is the preferred input for sudo/admin access groups and gets Contributor on each VM resource.
# linux_vm_app_user_group  = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "c4f6e953-7e5d-45fc-8092-4a48a59069d5"]
# linux_vm_app_admin_group = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
# - when Bastion is configured, both groups also get Network Contributor on that Bastion host.

linux_vm_app_user_group  = []
linux_vm_app_admin_group = ["534422f9-5a5e-4ebe-86f6-714fb9d17fe3"]

bastion_resource_name       = ""
bastion_resource_group_name = ""



# -------------------------------------------------------------------
# End of Linux VM Module Inputs
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Beginning of AKS Module Inputs
# -------------------------------------------------------------------

enable_aks                            = true
aks_sku_tier                          = "Free"
aks_private_cluster_enabled           = false
aks_role_based_access_control_enabled = true
aks_azure_rbac_enabled                = true
aks_local_account_disabled            = true
aks_oidc_issuer_enabled               = true
aks_workload_identity_enabled         = true

aks_default_node_pool = {
  name                = "system"
  vm_size             = "Standard_B2ms"
  node_count          = 1
  enable_auto_scaling = false
  os_disk_size_gb     = 64
  os_sku              = "Ubuntu"
  upgrade_settings = {
    max_surge                     = "10%"
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
  }
}

aks_network_profile = {
  network_plugin    = "azure"
  load_balancer_sku = "standard"
  outbound_type     = "loadBalancer"
}

aks_enable_diagnostics = false

# -------------------------------------------------------------------
# End of AKS Module Inputs
# -------------------------------------------------------------------
