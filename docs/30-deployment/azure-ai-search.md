# Azure AI Search

This landing zone supports Azure AI Search as an optional root-level service using the shared `azure_ai_search` module from the template repository.

The root wiring follows the same standard as the other optional services:

- feature-flag driven enablement through `features`
- generated name convention based on workload, region, and environment
- shared resource group, Log Analytics workspace, and private endpoint subnet
- root `app_admin_group` / `app_user_group` RBAC inputs
- optional private DNS auto-wiring through the root private DNS module

## Root Inputs

The root-level Azure AI Search inputs are:

- `enable_azure_ai_search`
- `azure_ai_search_name`
- `azure_ai_search_sku`
- `azure_ai_search_replica_count`
- `azure_ai_search_partition_count`
- `azure_ai_search_hosting_mode`
- `azure_ai_search_semantic_search_sku`
- `azure_ai_search_public_network_access_enabled`
- `azure_ai_search_allowed_ips`
- `azure_ai_search_network_rule_bypass_option`
- `azure_ai_search_local_authentication_enabled`
- `azure_ai_search_authentication_failure_mode`
- `azure_ai_search_customer_managed_key_enforcement_enabled`
- `azure_ai_search_identity`
- `enable_azure_ai_search_private_endpoint`
- `azure_ai_search_private_dns_zone_id`
- `azure_ai_search_enable_diagnostics`
- `azure_ai_search_diagnostic_log_categories`
- `azure_ai_search_diagnostic_metric_categories`

## Naming

If `azure_ai_search_name` is left empty, the root module generates:

```hcl
srch-${local.name_suffix}
```

Example:

```text
srch-platform-cc-sbx
```

## Minimal Example

```hcl
features = {
  enable_azure_ai_search = true
}

azure_ai_search_sku             = "standard"
azure_ai_search_replica_count   = 1
azure_ai_search_partition_count = 1
```

## Private Endpoint and DNS

To use a private endpoint:

1. Set `enable_azure_ai_search_private_endpoint = true`
2. Add `"privatelink.search.windows.net"` to `private_dns_zone_names` if you want the root private DNS module to manage the zone automatically
3. Optionally set `azure_ai_search_private_dns_zone_id` if the DNS zone already exists elsewhere

The root module uses the shared `snet-private-endpoints` subnet by default, matching the pattern used by the other private endpoint-capable services.

## Notes

- The free SKU does not support private endpoints, IP firewall rules, or semantic ranker configuration.
- `hosting_mode = "highDensity"` requires `azure_ai_search_sku = "standard3"`.
- Keep the service disabled in environments where you do not want recurring hourly search charges.

## Current Environment Defaults

At the root tfvars level:

- `environments/dev/terraform.tfvars`: `enable_azure_ai_search = false`
- `environments/sandbox/terraform.tfvars`: `enable_azure_ai_search = false`
