output "features" {
  description = "Feature enablement and compact connection details for enabled resources. Resource IDs, tags, firewalls, and empty values are intentionally omitted."
  value = {
    enable_app_services = merge(
      { enabled = local.feature_flags.enable_app_services },
      local.feature_flags.enable_app_services && length(module.app_service) > 0 ? {
        items = {
          for key, app in module.app_service : key => merge(
            {
              name = app.app_name
            },
            try(app.default_hostname, "") != "" ? {
              hostname = app.default_hostname
            } : {},
            try(app.default_url, "") != "" ? {
              url = app.default_url
            } : {},
            try(app.app_kind, "") != "" ? {
              kind = app.app_kind
            } : {}
          )
        }
      } : {}
    )

    enable_automation_accounts = merge(
      { enabled = local.feature_flags.enable_automation_accounts },
      local.feature_flags.enable_automation_accounts && length(module.automation_account) > 0 ? {
        items = {
          for key, account in module.automation_account : key => merge(
            {
              name = account.name
            },
            try(account.dsc_server_endpoint, "") != "" ? {
              dsc_server_endpoint = account.dsc_server_endpoint
            } : {},
            try(account.hybrid_service_url, "") != "" ? {
              hybrid_service_url = account.hybrid_service_url
            } : {}
          )
        }
      } : {}
    )

    enable_acr = merge(
      { enabled = local.feature_flags.enable_acr },
      local.feature_flags.enable_acr ? merge(
        {
          name = module.acr[0].name
        },
        try(module.acr[0].login_server, "") != "" ? {
          login_server = module.acr[0].login_server
        } : {},
        try(module.acr[0].private_endpoint_ip_address, "") != "" ? {
          private_ip = module.acr[0].private_endpoint_ip_address
        } : {}
      ) : {}
    )

    enable_databricks = {
      enabled                = local.feature_flags.enable_databricks
      name                   = local.feature_flags.enable_databricks ? module.databricks[0].name : null
      workspace_url          = local.feature_flags.enable_databricks ? try(module.databricks[0].workspace_url, null) : null
      private_endpoint_names = local.feature_flags.enable_databricks ? tomap(try(module.databricks[0].private_endpoint_names, {})) : tomap({})
    }

    enable_adf = merge(
      { enabled = local.feature_flags.enable_adf },
      local.feature_flags.enable_adf ? merge(
        {
          name = module.adf_basic[0].name
        },
        try(module.adf_basic[0].private_endpoint_ip_address, "") != "" ? {
          private_ip = module.adf_basic[0].private_endpoint_ip_address
        } : {},
        try(length(module.adf_basic[0].managed_private_endpoint_fqdns), 0) > 0 ? {
          managed_private_endpoint_fqdns = module.adf_basic[0].managed_private_endpoint_fqdns
        } : {}
      ) : {}
    )

    enable_azure_ai_search = merge(
      { enabled = local.feature_flags.enable_azure_ai_search },
      local.feature_flags.enable_azure_ai_search ? merge(
        {
          name = module.azure_ai_search[0].name
        },
        try(module.azure_ai_search[0].endpoint, "") != "" ? {
          endpoint = module.azure_ai_search[0].endpoint
        } : {},
        try(length(module.azure_ai_search[0].private_endpoint_fqdns), 0) > 0 ? {
          private_endpoint_fqdns = module.azure_ai_search[0].private_endpoint_fqdns
        } : {},
        try(length(module.azure_ai_search[0].private_endpoint_ip_addresses), 0) > 0 ? {
          private_ips = module.azure_ai_search[0].private_endpoint_ip_addresses
        } : {}
      ) : {}
    )

    enable_azure_ai_service = merge(
      { enabled = local.feature_flags.enable_azure_ai_service },
      local.feature_flags.enable_azure_ai_service ? merge(
        {
          name = module.azure_ai_service[0].name
        },
        try(module.azure_ai_service[0].endpoint, "") != "" ? {
          endpoint = module.azure_ai_service[0].endpoint
        } : {},
        try(module.azure_ai_service[0].custom_subdomain_name, "") != "" ? {
          custom_subdomain_name = module.azure_ai_service[0].custom_subdomain_name
        } : {},
        try(length(module.azure_ai_service[0].private_endpoint_fqdns), 0) > 0 ? {
          private_endpoint_fqdns = module.azure_ai_service[0].private_endpoint_fqdns
        } : {},
        try(length(module.azure_ai_service[0].private_endpoint_ip_addresses), 0) > 0 ? {
          private_ips = module.azure_ai_service[0].private_endpoint_ip_addresses
        } : {}
      ) : {}
    )

    enable_openai = merge(
      { enabled = local.feature_flags.enable_openai },
      local.feature_flags.enable_openai ? merge(
        {
          name = module.openai[0].name
        },
        try(module.openai[0].endpoint, "") != "" ? {
          endpoint = module.openai[0].endpoint
        } : {},
        try(module.openai[0].custom_subdomain_name, "") != "" ? {
          custom_subdomain_name = module.openai[0].custom_subdomain_name
        } : {},
        try(length(module.openai[0].deployment_names), 0) > 0 ? {
          deployments = module.openai[0].deployment_names
        } : {},
        try(length(module.openai[0].private_endpoint_fqdns), 0) > 0 ? {
          private_endpoint_fqdns = module.openai[0].private_endpoint_fqdns
        } : {},
        try(length(module.openai[0].private_endpoint_ip_addresses), 0) > 0 ? {
          private_ips = module.openai[0].private_endpoint_ip_addresses
        } : {}
      ) : {}
    )

    enable_linux_vm = merge(
      { enabled = local.feature_flags.enable_linux_vm },
      local.feature_flags.enable_linux_vm ? merge(
        {
          names       = module.linux_vm_basic[0].name
          private_ips = module.linux_vm_basic[0].private_ip
        },
        try(length(module.linux_vm_basic[0].public_ip), 0) > 0 ? {
          public_ips = module.linux_vm_basic[0].public_ip
        } : {}
      ) : {}
    )

    enable_winvm = merge(
      { enabled = local.feature_flags.enable_winvm },
      local.feature_flags.enable_winvm ? merge(
        {
          names = [
            for vm_index in range(var.winvm_vm_count) :
            "${trimspace(var.winvm_vm_name) != "" ? var.winvm_vm_name : substr("vm${replace(var.workload, "-", "")}", 0, 13)}${format("%02d", vm_index + 1)}"
          ]
          private_ips = module.winvm_basic[0].privateips
        },
        try(module.winvm_basic[0].public_ip, "") != "" && try(module.winvm_basic[0].public_ip, "") != "No Public IP Assigned" ? {
          public_ip = module.winvm_basic[0].public_ip
        } : {}
      ) : {}
    )

    enable_aks = merge(
      { enabled = local.feature_flags.enable_aks },
      local.feature_flags.enable_aks ? merge(
        {
          name = module.aks[0].name
        },
        try(module.aks[0].fqdn, "") != "" ? {
          fqdn = module.aks[0].fqdn
        } : {},
        try(module.aks[0].private_fqdn, "") != "" ? {
          private_fqdn = module.aks[0].private_fqdn
        } : {},
        try(module.aks[0].portal_fqdn, "") != "" ? {
          portal_fqdn = module.aks[0].portal_fqdn
        } : {},
        try(length(module.aks[0].node_pool_names), 0) > 0 ? {
          node_pools = module.aks[0].node_pool_names
        } : {}
      ) : {}
    )

    enable_sqldb = merge(
      { enabled = local.feature_flags.enable_sqldb },
      local.feature_flags.enable_sqldb ? merge(
        {
          server_name   = module.sqldb[0].server_name
          database_name = module.sqldb[0].database_name
        },
        try(module.sqldb[0].server_fqdn, "") != "" ? {
          fqdn = module.sqldb[0].server_fqdn
        } : {},
        try(module.sqldb[0].private_endpoint_name, "") != "" ? {
          private_endpoint_name = module.sqldb[0].private_endpoint_name
        } : {},
        try(length(module.sqldb[0].private_endpoint_fqdns), 0) > 0 ? {
          private_endpoint_fqdns = module.sqldb[0].private_endpoint_fqdns
        } : {},
        try(length(module.sqldb[0].private_endpoint_ip_addresses), 0) > 0 ? {
          private_ips = module.sqldb[0].private_endpoint_ip_addresses
        } : {}
      ) : {}
    )

    enable_fortigate = {
      enabled                   = local.feature_flags.enable_fortigate
      virtual_machine_ids       = local.feature_flags.enable_fortigate ? tomap(module.fortigate[0].virtual_machine_ids) : tomap({})
      network_interface_ids     = local.feature_flags.enable_fortigate ? tomap(module.fortigate[0].network_interface_ids) : tomap({})
      private_ip_addresses      = local.feature_flags.enable_fortigate ? tomap(module.fortigate[0].private_ip_addresses) : tomap({})
      subnet_ids                = local.feature_flags.enable_fortigate ? tomap(module.fortigate[0].subnet_ids) : tomap({})
      virtual_network_name      = local.feature_flags.enable_fortigate ? module.fortigate[0].virtual_network_name : null
      dedicated_virtual_network = local.feature_flags.enable_fortigate ? var.fortigate_create_dedicated_vnet : false
      network_security_group_id = local.feature_flags.enable_fortigate ? module.fortigate[0].network_security_group_id : null
    }
  }
}

# output "tag_debug" {
#   description = "Debug view of root tag inputs and effective root tag locals."
#   value = {
#     var_tags      = var.tags
#     var_rg_tags   = var.rg_tags
#     local_tags    = local.tags
#     local_rg_tags = local.rg_tags
#   }
# }
