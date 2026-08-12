# Root-Level Module Guide

This document describes the root-level module blocks in `main.tf`, the matching inputs in `variables.tf` and `terraform.tfvars`, and the recommended dependency order when enabling modules in the root template.

## Current Root State

- The root template contains isolated module sections for the repository modules that are intended to be wired from the root.
- This repo now actively provisions a smaller opinionated landing zone subset rather than validating every template module from the upstream module repo.
- Some module patterns still remain commented or unused so the root stack can continue to act as a controlled template for future expansion.
- The matching root inputs live in `variables.tf`, and sample environment values live in `terraform.tfvars`.
- The root wrapper now uses a filtered `local.app_resource_group_inherited_tags` helper before merging resource group tags into module tag inputs. This avoids validation failures when an existing resource group contains blank tag keys or values.

## Resources Provisioned By The Current Repo

This section reflects the resources wired in `main.tf` and enabled by the checked-in `terraform.tfvars` at the time this document was updated.

### Core governance and subscription bootstrap

- Management group hierarchy:
  `mg_platform`, `mg_landingzone`, `mg_sandboxes`, plus platform child groups for `connectivity`, `identity`, `security`, and `management`
- Subscription vending and management group association for the subscriptions listed in `hierarchy_subscriptions`

### Shared foundation

- One shared resource group
- One Log Analytics workspace
- One shared storage account
- One shared Key Vault
- Storage blob service configuration updates for versioning, soft delete, change feed, and restore policy
- Key Vault secrets for Linux VM admin override values when those values are set in root inputs

### Network

- One hub virtual network with `AzureFirewallSubnet`
- One spoke virtual network with these subnets:
  `snet-app`, `snet-private-endpoints`, `snet-databricks-public`, `snet-databricks-private`, `snet-aks`, `snet-jumpbox`, `snet-sqlmi`
- Hub-to-spoke and spoke-to-hub VNet peering
- One spoke Network Security Group
- NSG associations for the app, AKS, jumpbox, and Databricks subnets
- Private DNS zones defined in `private_dns_zone_names`
  The current checked-in `terraform.tfvars` enables `privatelink.azurewebsites.net`
  App Service private endpoints rely on this root-level private DNS creation path in the current landing zone. If `app_service_enable_private_endpoint = true` but `privatelink.azurewebsites.net` is not included in `private_dns_zone_names` for that environment, the downstream App Service module will try to look up an existing zone with `data.azurerm_private_dns_zone` and fail with `Private Dns Zone ... was not found` instead of creating it.

### App platform

- One App Service Plan per enabled app entry in `app_services`
- One Entra app registration per enabled app when `enable_app_registration_for_appservice = true`
- One App Service per enabled app entry in `app_services`
  The current checked-in `terraform.tfvars` enables `dotnet`, `node`, and `python`
- Optional private endpoints for App Services when `app_service_enable_private_endpoint = true`
  The current checked-in `terraform.tfvars` enables this

### Automation and ARI

- One Azure Automation Account per enabled entry in `automation_accounts`
  The current checked-in `terraform.tfvars` enables `default`
- Role assignments from Automation Account managed identities to:
  shared storage as `Storage Blob Data Contributor`
  shared Key Vault as `Key Vault Secrets Officer`
- Shared storage containers for `localization`, `scripts`, and `terraform`
- One ARI output container per enabled ARI workload
- One Automation runtime environment per enabled ARI workload
- One runtime package resource per configured ARI package
- One Automation runbook per enabled ARI workload
- One Automation schedule and job schedule per enabled ARI workload when scheduling is enabled
  The current checked-in `terraform.tfvars` enables the `default` ARI workload and its daily schedule

### Integration

- One Azure Data Factory deployment when `enable_adf = true`
  The current checked-in `environments/sandbox/terraform.tfvars` enables this with the default Azure IR, shared storage/Key Vault pattern, and SHIR disabled.

### Linux runner / jumpbox

- One Linux VM deployment via the `linuxvm` module when `enable_linux_vm = true`
  The current checked-in `terraform.tfvars` enables this
- Shared localization scripts uploaded through the Linux VM module when enabled
- `Website Contributor` role assignments from the Linux VM managed identity to each enabled App Service

### Not currently provisioned by this repo

These module patterns exist in the broader template ecosystem or in the guide below, but are not currently wired as active root module blocks here:

- `acr`
- `aks`
- `azure_ai_service`
- `databricks`
- `eventhub`
- `firewall`
- `functionapp`
- `managedidentity`
- `openai`
- `policy`
- `roleassignments`
- `route_table`
- `servicebus`
- `sqldb`
- `sqlmi`
- `sqlmi_db`
- `winvm`

## Root-Level Module Order

The root file order currently matches the module inventory under `modules/`:

1. `acr_basic`
2. `adf_basic`
3. `aks_basic`
4. `app_registration`
5. `app_service`
6. `app_service_plan`
7. `automation_account`
8. `azure_ai_service_basic`
9. `databricks_basic`
10. `eventhub_basic`
11. `firewall_basic`
12. `function_app_basic`
13. `key_vault_basic`
14. `linux_vm_basic`
15. `log_analytics_workspace_basic`
16. `managed_identity`
17. `management_groups`
18. `network_security_group`
19. `openai_basic`
20. `policy_definition`
21. `private_dns_basic`
22. `resource_group_basic`
23. `role_assignments_basic`
24. `route_table_basic`
25. `servicebus_basic`
26. `sqlmi_basic`
27. `storage_account_basic`
28. `subscription_vending_basic`
29. `vnet_basic`

## Root-Level Dependency Order

Use this order when enabling modules for a new landing zone or shared platform stack:

1. `management_groups`
2. `policy_definition`
3. `subscription_vending_basic`
4. `resource_group_basic`
5. `log_analytics_workspace_basic`
6. `vnet_basic`
7. `network_security_group`
8. `firewall_basic`
9. `route_table_basic`
10. `private_dns_basic`
11. `role_assignments_basic`
12. `storage_account_basic`
13. `key_vault_basic`
14. `managed_identity`
15. `azure_ai_service_basic` / `openai_basic`
16. `app_service_plan`
17. `eventhub_basic` / `servicebus_basic`
18. `databricks_basic`
19. `app_service` / `function_app_basic` / `aks_basic`
20. `linux_vm_basic`
21. `automation_account`
22. `adf_basic`
23. `acr_basic`
24. `sqlmi_basic`

Use only the subset that applies to the environment. The root template is not meant to enable every module in a single deployment by default.

## Root-Level Dependency Matrix

| Root module block | Primary use case | Required dependencies | Common optional dependencies |
| --- | --- | --- | --- |
| `acr_basic` | Container registry for AKS or app delivery | Existing resource group | Private endpoint subnet, private DNS zone, Log Analytics |
| `adf_basic` | Data Factory with shared-IaC integration pattern | Existing resource group; shared key vault and storage | VNet/subnet, SHIR VM, private endpoint, repo integration |
| `aks_basic` | AKS platform cluster | Existing resource group | VNet/subnet, private DNS zone, Log Analytics, managed identity |
| `app_registration` | Entra application registration and service principal | Provider access only | Key Vault for client secret storage |
| `app_service` | Web app workload | Existing resource group; `app_service_plan` | VNet integration subnet, private endpoint, auth app registration, Azure DevOps repo for Deployment Center, runner VM RBAC for private deployments |
| `app_service_plan` | Shared hosting plan for App Service and Function App | Existing resource group | Downstream web and function workloads |
| `automation_account` | Azure Automation Accounts plus optional ARI workload layer | Existing resource group | Private endpoint, storage, role assignment scopes, optional ARI schedule/runbook wiring |
| `azure_ai_service_basic` | Azure AI Services endpoint for shared AI capabilities | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics |
| `databricks_basic` | Databricks workspace | Existing resource group | VNet injection subnets, NSG associations, Log Analytics |
| `eventhub_basic` | Event Hubs namespace and hubs | Existing resource group | Private endpoint subnet, private DNS zone, diagnostics, RBAC groups |
| `firewall_basic` | Azure Firewall with policy and rule collections | Existing resource group; existing `AzureFirewallSubnet` | Route tables, hub VNet, Log Analytics |
| `function_app_basic` | Function App workload | Existing resource group; `app_service_plan`; existing or shared storage | VNet integration subnet, private endpoint, managed identity |
| `key_vault_basic` | Secrets, certificates, platform config store | Existing resource group | Private endpoint, private DNS zone, RBAC groups |
| `linux_vm_basic` | Linux VM workload | Existing resource group; VNet/subnet; shared key vault and storage pattern | Domain join, Entra SSH, diagnostics |
| `log_analytics_workspace_basic` | Central monitoring workspace | Existing resource group | Diagnostics-enabled modules, Sentinel, monitoring add-ons |
| `managed_identity` | User-assigned managed identity | Existing resource group | Federated credentials, role assignment scopes, app/function/AKS consumers |
| `management_groups` | Enterprise governance hierarchy | Tenant-level permissions | Subscription placement |
| `network_security_group` | NSG and subnet/NIC associations | Existing resource group | `vnet_basic`, Linux VM, Azure Firewall subnet design |
| `openai_basic` | Azure OpenAI account with optional deployments | Existing resource group | Private endpoint subnet, private DNS zone, Key Vault, managed identity, Log Analytics |
| `policy_definition` | Custom policy and optional assignment | Optional `management_groups` when using MG scope | Subscription or resource group scope |
| `private_dns_basic` | Private DNS zones, VNet links, and records | Existing resource group | VNet IDs, private endpoint-enabled services |
| `resource_group_basic` | Resource group, lock, and RBAC | None | Downstream everything else |
| `role_assignments_basic` | Generic RBAC at Azure scope | Target scope IDs and principals | Management groups, subscriptions, RGs, managed identities |
| `route_table_basic` | User-defined routes and subnet associations | Existing resource group | Azure Firewall private IP, workload subnet IDs |
| `servicebus_basic` | Service Bus namespace, queues, topics, subscriptions | Existing resource group | Private endpoint, private DNS zone, network rules, diagnostics |
| `sqlmi_basic` | SQL Managed Instance | Existing resource group; delegated subnet | Diagnostics, user-assigned identities |
| `storage_account_basic` | Shared or workload storage account | Existing resource group | VNet rules, private endpoint, private DNS zone, diagnostics |
| `subscription_vending_basic` | Subscription bootstrap and management group placement | Existing or newly created subscription context | Management groups, bootstrap resource groups, provider registration list |
| `vnet_basic` | Virtual network and subnets | Existing resource group | NSG attachment, delegated subnets, private endpoint subnets |

## Common Root Dependency Chains

- `management_groups` -> `policy_definition`
- `management_groups` -> `subscription_vending_basic`
- `subscription_vending_basic` -> `resource_group_basic`
- `resource_group_basic` -> `log_analytics_workspace_basic`
- `resource_group_basic` -> `vnet_basic` -> `network_security_group`
- `resource_group_basic` -> `vnet_basic` -> `firewall_basic` -> `route_table_basic`
- `resource_group_basic` -> `private_dns_basic`
- `resource_group_basic` -> `role_assignments_basic`
- `resource_group_basic` -> `storage_account_basic`
- `resource_group_basic` -> `key_vault_basic`
- `resource_group_basic` -> `managed_identity`
- `resource_group_basic` -> `azure_ai_service_basic`
- `resource_group_basic` -> `openai_basic`
- `resource_group_basic` -> `app_service_plan` -> `app_service`
- `resource_group_basic` -> `app_service_plan` + `storage_account_basic` -> `function_app_basic`
- `resource_group_basic` -> `eventhub_basic`
- `resource_group_basic` -> `servicebus_basic`
- `resource_group_basic` -> `vnet_basic` -> `network_security_group` -> `databricks_basic`
- `resource_group_basic` -> `vnet_basic` + shared storage + shared key vault -> `linux_vm_basic`
- `resource_group_basic` -> `vnet_basic` + shared key vault + shared storage -> `adf_basic`
- `resource_group_basic` -> `storage_account_basic` + `key_vault_basic` -> `automation_account` + `automation_ari_workloads` + Log Analytics-backed ARI monitoring
- `resource_group_basic` -> `aks_basic` -> `acr_basic`
- `resource_group_basic` -> delegated subnet from `vnet_basic` -> `sqlmi_basic`

## Root-Level Use Cases

### Governance and Subscription Foundation

Enable these first when the template is being used as a landing zone platform baseline:

- `management_groups`
- `policy_definition`
- `subscription_vending_basic`
- `role_assignments_basic`

Typical use cases:

- management group hierarchy rollout
- management group policy assignment
- onboarding subscriptions into the landing zone
- assigning platform-team RBAC at management group, subscription, or resource group scope

### Network and Connectivity Foundation

Enable these when the template is building the core connectivity layer:

- `resource_group_basic`
- `vnet_basic`
- `network_security_group`
- `firewall_basic`
- `route_table_basic`
- `private_dns_basic`

Typical use cases:

- hub-spoke or shared-services VNet setup
- subnet segmentation with NSGs
- centralized egress or inspection through Azure Firewall
- subnet routing control
- private endpoint DNS ownership for platform services

### Management and Shared Platform Services

Enable these when the template is building a reusable shared-services layer:

- `log_analytics_workspace_basic`
- `storage_account_basic`
- `key_vault_basic`
- `managed_identity`
- `automation_account`

Typical use cases:

- central diagnostics workspace
- shared storage and secret management
- reusable user-assigned identity for workloads and CI/CD
- runbooks and hybrid worker automation

### Messaging and Integration

Enable these when the platform needs asynchronous integration services:

- `eventhub_basic`
- `servicebus_basic`
- `adf_basic`

Typical use cases:

- telemetry ingestion and streaming
- queue and topic-based workload integration
- enterprise data movement and integration pipelines

### AI and Data Platform

Enable these when the platform needs managed analytics or AI endpoints:

- `azure_ai_service_basic`
- `openai_basic`
- `databricks_basic`

Typical use cases:

- shared AI service endpoints
- governed Azure OpenAI model hosting
- lakehouse, notebook, and data engineering platforms

### Application and Compute Hosting

Enable these for runtime or compute stacks:

- `app_service_plan`
- `app_service`
- `function_app_basic`
- `aks_basic`
- `linux_vm_basic`
- `acr_basic`

Typical use cases:

- web apps
- function-based jobs and APIs
- container platforms
- Linux VM workloads
- image supply for AKS or app delivery

For the current root `app_services` map, each enabled web app can now choose its deployment path with:

- `deployment_method`

Supported values:

- `external_zip_deploy`: CI uploads a prebuilt runnable ZIP and App Service extracts it
- `run_from_package`: CI uploads a prebuilt runnable ZIP that App Service mounts with `WEBSITE_RUN_FROM_PACKAGE=1`
- `deployment_center`: GitHub or Azure Repos is wired through App Service Deployment Center
- `zip_deploy_with_build`: CI pushes a ZIP package with `az webapp deploy`, then App Service/Oryx builds it remotely

Use `deployment_method` as the only deployment-path selector for each app. The legacy `deployment_center_enabled` flag is retained only for backward compatibility and should not be combined with another selected method. See [APP_SERVICE_DEPLOYMENT_METHODS.md](./APP_SERVICE_DEPLOYMENT_METHODS.md) for artifact contracts, pipeline compatibility, and Deployment Center authorization behavior.

When `deployment_method = "deployment_center"`, each app can also declare:

- `deployment_center_azure_repos_organization`
- `deployment_center_azure_repos_project`
- `deployment_center_azure_repos_repository`
- `deployment_center_azure_repos_branch`
- `deployment_center_repo_url` for a GitHub repository
- `deployment_center_use_manual_integration`

Keep private endpoints disabled for `F1` and `D1` App Service plans in the root stack. If the app needs a private endpoint, move the workload to `B1` or higher first.

When `app_service_enable_private_endpoint = true` in the root landing zone, keep the environment's `private_dns_zone_names` list aligned with that decision. In practice, that means including `privatelink.azurewebsites.net` unless you are intentionally pointing the app service module at an already-existing private DNS zone by ID or by correct name and resource group. Otherwise the root wiring becomes inconsistent: the landing zone asks the app service module to attach a private endpoint DNS zone, but the zone is neither created by `module.private_dns` nor discoverable as an existing resource.

## Root-Level Examples

### Governance-First Rollout

```hcl
management_group_display_name                 = "Platform Landing Zone"
management_group_parent_management_group_id   = "/providers/Microsoft.Management/managementGroups/contoso-root"
management_group_subscription_ids             = []

policy_name                  = "require-tag-owner"
policy_display_name          = "Require Owner Tag"
policy_rule                  = "{\"if\":{\"field\":\"tags['Owner']\",\"exists\":\"false\"},\"then\":{\"effect\":\"audit\"}}"
policy_metadata              = "{\"category\":\"Tags\"}"
policy_create_assignment     = true
policy_assignment_scope      = "/providers/Microsoft.Management/managementGroups/contoso-platform"

subscription_vending_existing_subscription_id = "/subscriptions/<subscription-id>"
subscription_vending_management_group_id      = "/providers/Microsoft.Management/managementGroups/contoso-platform"
subscription_vending_resource_provider_registrations = [
  "Microsoft.Network",
  "Microsoft.KeyVault"
]
```

Use case:

- create the governance hierarchy, assign policy, and onboard a subscription into the landing zone

### Connectivity Foundation Rollout

```hcl
resource_group_name     = "rg-ba-eus-prd-shared-management-02"
resource_group_location = "eastus"

vnet_name          = "vnet-ba-cc-prd-shared-management-01"
vnet_address_space = ["10.250.0.0/16"]

nsg_name = "nsg-iactest-prod-001"
nsg_security_rules = {
  allow_https_in = {
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS inbound."
  }
}

firewall_name      = "afw-iactest-prod-001"
firewall_subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<network-rg>/providers/Microsoft.Network/virtualNetworks/<hub-vnet>/subnets/AzureFirewallSubnet"

route_table_name  = "rt-iactest-prod-001"
route_table_routes = {
  default = {
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.250.0.4"
  }
}
```

Use case:

- establish the shared resource group, VNet, NSG, firewall, and egress routing before workloads are attached

### Monitoring and Shared Services Rollout

```hcl
loganalytics_name               = "law-iactest-prod-001"
loganalytics_retention_in_days  = 30
loganalytics_internet_query_enabled = true

storage_account_name = "stiactestprod001"

managed_identity_name = "id-iactest-prod-001"
managed_identity_federated_identity_credentials = {
  github = {
    audience = ["api://AzureADTokenExchange"]
    issuer   = "https://token.actions.githubusercontent.com"
    subject  = "repo:example-org/example-repo:ref:refs/heads/main"
  }
}
```

Use case:

- create the monitoring workspace, shared storage, and reusable identity used by downstream platform workloads

### Private DNS Rollout

```hcl
private_dns_zones = {
  "privatelink.blob.core.windows.net" = {
    vnet_links = {}
    a_records  = {}
  }
  "privatelink.vaultcore.azure.net" = {
    vnet_links = {}
    a_records  = {}
  }
}
```

Use case:

- centralize private endpoint DNS for storage and key vault before private networking is enabled on those services

### RBAC Rollout

```hcl
roleassignments_assignments = {
  platform-readers = {
    scope                = "/subscriptions/<subscription-id>/resourceGroups/rg-ba-eus-prd-shared-management-02"
    role_definition_name = "Reader"
    principal_id         = "<entra-object-id>"
  }
}
```

Use case:

- assign scoped landing zone access without pushing RBAC logic into each workload module

### Azure AI and Data Platform Rollout

```hcl
azure_ai_service_sku_name                      = "S0"
azure_ai_service_public_network_access_enabled = true

openai_sku_name = "S0"
openai_deployments = {
  gpt4o_mini = {
    model_format = "OpenAI"
    model_name   = "gpt-4o-mini"
    sku_name     = "Standard"
    sku_capacity = 10
  }
}

databricks_sku                                   = "premium"
databricks_network_security_group_rules_required = "AllRules"
```

Use case:

- provide governed AI endpoints and a shared analytics workspace from the same platform foundation

### Messaging Rollout

```hcl
eventhub_sku      = "Standard"
eventhub_capacity = 1
eventhub_eventhubs = {
  telemetry = {
    partition_count   = 2
    message_retention = 1
    status            = "Active"
  }
}

servicebus_sku = "Standard"
servicebus_queues = {
  orders = {
    max_size_in_megabytes = 1024
    max_delivery_count    = 10
    lock_duration         = "PT1M"
    default_message_ttl   = "P14D"
    status                = "Active"
  }
}
```

Use case:

- provide streaming and brokered messaging services for shared integration workloads

### App Platform Rollout

```hcl
app_services = {
  dotnet = {
    enabled                               = true
    stack                                 = "dotnet"
    kind                                  = "Windows"
    plan_os_type                          = "Windows"
    sku_name                              = "B1"
    enable_diagnostics                    = false
    deployment_method                     = "deployment_center"
    dotnet_version                        = "v8.0"
    deployment_center_azure_repos_organization = "CCOE-Azure"
    deployment_center_azure_repos_project      = "YourProjectName"
    deployment_center_azure_repos_repository   = "your-website-repo"
    deployment_center_azure_repos_branch       = "main"
    deployment_center_use_manual_integration   = true
  }
}
```

Use case:

- deploy a web app after the app service plan is already in place and choose either package deployment or Azure Repos Deployment Center from the same `app_services` block
- set `app_services.<key>.enable_diagnostics = false` to avoid creating that app's Azure Monitor diagnostic setting; set `app_service_plan_enable_diagnostics = false` separately for the hosting plan

## Recommended Root Activation Patterns

- Governance-only:
  `management_groups` -> `policy_definition`
- Subscription onboarding:
  `management_groups` -> `subscription_vending_basic` -> `role_assignments_basic`
- Shared foundation:
  `resource_group_basic` -> `log_analytics_workspace_basic` -> `vnet_basic` -> `network_security_group` -> `private_dns_basic` -> `storage_account_basic` -> `key_vault_basic` -> `managed_identity`
- Connectivity platform:
  `resource_group_basic` -> `vnet_basic` -> `firewall_basic` -> `route_table_basic`
- AI platform:
  `resource_group_basic` -> `azure_ai_service_basic` and/or `openai_basic`
- Identity-first app platform:
  `resource_group_basic` -> `managed_identity` -> `app_service_plan` -> `app_service` / `function_app_basic`
- Messaging platform:
  `resource_group_basic` -> `eventhub_basic` and/or `servicebus_basic`
- Data platform:
  `resource_group_basic` -> `vnet_basic` -> `network_security_group` -> `databricks_basic`
- Integration platform:
  `resource_group_basic` -> `storage_account_basic` -> `key_vault_basic` -> `adf_basic`

## Root-Level Files to Change

- `main.tf`: uncomment and wire the target module block
- `variables.tf`: keep the root input definitions aligned with the module interfaces
- `terraform.tfvars`: provide environment-specific values

## Validation

After enabling or changing a root-level module block:

```powershell
terraform fmt
terraform validate
terraform plan
```
