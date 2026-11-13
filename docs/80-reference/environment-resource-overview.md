# Azure Landing Zone | Resource & Environment Guide

> **At a glance**<br>
> This repository composes a shared Azure landing zone from Terraform modules. The checked-in **Dev** configuration describes a platform environment in **Canada Central** (`rg-platform-dev`) with hub-and-spoke networking, shared data and security services, application hosting, automation, and selected analytics/AI services.

<p align="center">
  <strong>Governance → Foundation → Network → Platform workloads</strong><br>
  A modular baseline configured by environment-specific Terraform variables
</p>

## What this guide covers

This guide combines the Terraform configuration inventory with live Azure Resource Manager listings for the Dev and Sandbox resource groups. The Portal links below are based on resource IDs returned from their configured subscriptions on November 13, 2026. Each live list covers only the named resource group; it is not a complete subscription-wide inventory.

The root configuration uses shared modules pinned to an upstream revision. Environment inputs live in `environments/<environment>/terraform.tfvars`; backend state configuration is separate.

## Environment snapshot

| Environment | Location | Resource group | Configuration status | Notable enabled services |
| --- | --- | --- | --- | --- |
| **Dev** | Canada Central | `rg-platform-dev` | Detailed checked-in configuration | App Services, Free Static Web App, Automation/ARI, Azure Data Factory, Azure AI Search, Azure AI Services, Azure OpenAI, Databricks, hub/spoke network |
| **Sandbox** | Canada Central | `rg-platform-sbx` | Detailed checked-in configuration | App Services, Automation/ARI, Azure Data Factory, AI services, SQL Database, private DNS, hub/spoke network |
| **Prod** | East US | `TODO-rg-platform-prod` | **Placeholder only**; subscription and resource-group values must be replaced | FortiGate explicitly disabled; no production workload inventory can be inferred yet |

The repository root does not select an active environment by itself. The table summarizes the checked-in inputs; deployment depends on the chosen `-var-file`, backend, credentials, and successful Terraform apply.

## Live Azure resource links — Dev

These are direct Azure Portal links for the **Dev** deployment in resource group **`rg-platform-dev`**, the subscription configured for Dev. Resource IDs were read from Azure Resource Manager on **November 13, 2026** and matched against the resources enabled in this repository's Dev configuration. Azure access is required to open them.

| Resource | Azure resource type |
| --- | --- |
| [rg-platform-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/overview) | `Microsoft.Resources/resourceGroups` |
| [aa-platform-cc-dev-default](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Automation/automationAccounts/aa-platform-cc-dev-default/overview) | `Microsoft.Automation/automationAccounts` |
| [aa-platform-cc-dev-default/ARI_Runbook](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Automation/automationAccounts/aa-platform-cc-dev-default/runbooks/ARI_Runbook/overview) | `Microsoft.Automation/automationAccounts/runbooks` |
| [ai-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.CognitiveServices/accounts/ai-platform-cc-dev/overview) | `Microsoft.CognitiveServices/accounts` |
| [oai-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.CognitiveServices/accounts/oai-platform-cc-dev/overview) | `Microsoft.CognitiveServices/accounts` |
| [dbr-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Databricks/workspaces/dbr-platform-cc-dev/overview) | `Microsoft.Databricks/workspaces` |
| [adf-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.DataFactory/factories/adf-platform-cc-dev/overview) | `Microsoft.DataFactory/factories` |
| [kvplatformccdev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.KeyVault/vaults/kvplatformccdev/overview) | `Microsoft.KeyVault/vaults` |
| [adb-canadacentral-dp-to-cp-pl-bc4e738f9cff727e206a568b](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Network/networkIntentPolicies/adb-canadacentral-dp-to-cp-pl-bc4e738f9cff727e206a568b/overview) | `Microsoft.Network/networkIntentPolicies` |
| [adb-canadacentral-dp-to-cp-pl-cdb7efc0cf5bc02562025043](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Network/networkIntentPolicies/adb-canadacentral-dp-to-cp-pl-cdb7efc0cf5bc02562025043/overview) | `Microsoft.Network/networkIntentPolicies` |
| [nsg-platform-dev-spoke](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Network/networkSecurityGroups/nsg-platform-dev-spoke/overview) | `Microsoft.Network/networkSecurityGroups` |
| [vnet-hub-platform-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Network/virtualNetworks/vnet-hub-platform-dev/overview) | `Microsoft.Network/virtualNetworks` |
| [vnet-spoke-platform-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Network/virtualNetworks/vnet-spoke-platform-dev/overview) | `Microsoft.Network/virtualNetworks` |
| [law-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.OperationalInsights/workspaces/law-platform-cc-dev/overview) | `Microsoft.OperationalInsights/workspaces` |
| [srch-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Search/searchServices/srch-platform-cc-dev/overview) | `Microsoft.Search/searchServices` |
| [stplatformccdev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Storage/storageAccounts/stplatformccdev/overview) | `Microsoft.Storage/storageAccounts` |
| [asp-platform-cc-dev-dotnet](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/serverFarms/asp-platform-cc-dev-dotnet/overview) | `Microsoft.Web/serverFarms` |
| [asp-platform-cc-dev-node](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/serverFarms/asp-platform-cc-dev-node/overview) | `Microsoft.Web/serverFarms` |
| [asp-platform-cc-dev-python](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/serverFarms/asp-platform-cc-dev-python/overview) | `Microsoft.Web/serverFarms` |
| [web-platform-cc-dev-dotnet](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/sites/web-platform-cc-dev-dotnet/overview) | `Microsoft.Web/sites` |
| [web-platform-cc-dev-node](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/sites/web-platform-cc-dev-node/overview) | `Microsoft.Web/sites` |
| [web-platform-cc-dev-python](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/sites/web-platform-cc-dev-python/overview) | `Microsoft.Web/sites` |
| [demo-platform-cc-dev](https://portal.azure.com/#@d5b038fb-4b39-41cc-8a10-fba75212180b/resource/subscriptions/%31%65%63%35%65%64%64%34%2D%35%36%35%34%2D%34%32%34%36%2D%38%30%32%37%2D%62%32%39%65%66%36%33%62%33%33%39%33/resourceGroups/rg-platform-dev/providers/Microsoft.Web/staticSites/demo-platform-cc-dev/overview) | `Microsoft.Web/staticSites` |

> The resource group also contains other resources (including separate workload sites and services) that are not represented by this repository's enabled root modules, so they are omitted from this repo-focused list. Terraform state could not be read in this workspace because the required provider packages are not installed; the links above are based on the live Azure resource IDs.

## Resource map

### Governance and subscription placement

The Terraform composition can create platform, landing-zone, and sandbox management groups, child groups, and subscription vending/association. These are separately controlled because they require tenant and billing permissions. **Dev and Sandbox have management group and subscription bootstrap disabled**, so their checked-in subscription maps are not by themselves evidence of those resources being created.

### Shared foundation

The root composition includes a resource group, Log Analytics workspace, shared Storage Account, and Key Vault. Storage receives data-protection configuration such as blob versioning, soft delete, change feed, and restore policy. Optional Linux administrator secrets are written only when the corresponding inputs are supplied.

### Network and access controls

The baseline defines a hub VNet and a spoke VNet, two-way VNet peering, a spoke NSG, selected subnet-to-NSG associations, and private DNS zones when enabled and named. VNet and NSG modules are currently wired unconditionally in `main.tf`; the similarly named feature-map values do not gate these module blocks. The hub includes `AzureFirewallSubnet`; the spoke defines application, private-endpoint, Databricks, AKS, jumpbox, SQL MI, and VNet-integration subnets. Subnet definitions are not proof that the associated service (for example AKS or SQL MI) is enabled.

The Azure Firewall module is commented out in `main.tf`; the firewall subnet alone does not deploy a firewall. FortiGate is disabled in the checked-in Dev, Sandbox, and Prod settings. Review `trusted_ingress_ipv4_cidrs` and shared-data allowlists before deployment.

### Application hosting

When enabled, each entry in `app_services` creates an App Service Plan and App Service, with optional Entra app registration/auth wiring. Dev and Sandbox enable App Services and define `dotnet`, `node`, and `python` apps on Free (`F1`) plans. The environment files configure public network access and IP restrictions; inspect the exact per-app settings before exposing an endpoint.

Dev also enables one **Free Azure Static Web App** (`demo-platform-cc-dev`) in **East US 2**. Its resource group stays in Canada Central because Static Web Apps are not available in Canada Central for this subscription. Sandbox has no configured Static Web App entry; production remains a placeholder.

### Data, AI, and analytics workloads

These optional services are represented as root modules and are toggled independently by environment:

| Service | Dev | Sandbox | What the root module represents |
| --- | :---: | :---: | --- |
| Azure Data Factory | On | On | Data Factory instance and configured networking/options |
| Azure AI Search | On | On | Search service; SKU configured as `free` in both files |
| Azure AI Services | On | On | Cognitive/Azure AI service account and configured options |
| Azure OpenAI | On | On | Azure OpenAI account and configured deployments |
| Azure Databricks | On | Off | Workspace and its selected network integration |
| Azure Container Registry | Off | Off | Optional registry module; not selected in these configs |
| Azure SQL Database | Off | On | SQL database workload module |
| AKS | Off | Off | Kubernetes cluster module; reserved subnet does not create a cluster |

Enabled means “selected by the checked-in Terraform inputs,” not “verified deployed.” Service-specific SKU, deployment, public-access, private endpoint, and diagnostic settings are defined in the environment files and may affect cost and exposure.

### Automation and inventory

Dev and Sandbox enable an Automation Account and an Azure Resource Inventory (ARI) workload. The composition wires a managed identity, shared Storage containers, runtime environment/packages, runbook, and a daily schedule. Alert settings are configured, but notifications require action-group IDs; the ARI Monitor alert blocks in `main.tf` are commented out.

### Virtual machines

Linux and Windows VM modules are part of the root configuration, but the environment-level `features` maps currently set both VM feature switches to **false** for Dev and Sandbox. A separate VM input appearing as `true` does not override that feature-map value. Prod does not have sufficient inputs for a meaningful VM inventory. Review the feature map and secret sources before enabling either workload.

## Quick environment detail

### Dev

- Environment: `dev`; workload: `platform`; region: `canadacentral`.
- Resource group: `rg-platform-dev`; hub/spoke names: `vnet-hub-platform-dev` and `vnet-spoke-platform-dev`.
- Selected: VNet/NSG, App Services, Static Web Apps, Automation/ARI, Data Factory, AI Search, Azure AI Services, OpenAI, Databricks.
- Not selected: management group creation, subscription bootstrap, ACR, Linux VM, Windows VM, AKS, SQL Database, FortiGate, private DNS feature flag.
- The `private_dns_zone_names` list has entries, but the Dev `enable_private_dns` flag is false; those zones therefore do not create private DNS resources through this root configuration.

### Sandbox

- Environment: `sbx`; workload: `platform`; region: `canadacentral`.
- Resource group: `rg-platform-sbx`; hub/spoke names: `vnet-hub-platform-sbx` and `vnet-spoke-platform-sbx`.
- Selected: VNet/NSG, private DNS, App Services, Automation/ARI, Data Factory, AI Search, Azure AI Services, OpenAI, SQL Database.
- Not selected: management group creation, subscription bootstrap, ACR, Linux VM, Windows VM, AKS, Databricks, Static Web Apps, FortiGate.
- App Service registration is enabled in the feature map; verify effective auth inputs and redirect URIs when planning.

### Prod

`environments/prod/terraform.tfvars` is explicitly marked as a placeholder. Replace TODO values and supply the full required environment inputs before attempting a production plan/apply. Its current short feature map only sets FortiGate to false, so it should not be read as a complete production design.

## Cost and exposure cues

- Dev and Sandbox select several metered Azure services. Review current SKU and pricing for the chosen region before applying; this guide does not estimate spend.
- The Dev Static Web App and configured App Service plans use Free SKUs in the checked-in inputs. Other enabled services may incur charges even when the app hosting tier is Free.
- Public access is enabled for some configured services. Private endpoint and public-network settings vary by module; inspect the selected environment values and plan output.
- State backends and credentials are environment-specific. Do not infer an Azure deployment from a variable file alone.

## How to verify the actual deployment

Use the environment’s documented backend and variable file to initialize and create a plan, then compare the planned resources to Terraform state and Azure Resource Graph. Example for Dev:

```powershell
terraform init -reconfigure -backend-config="environments/dev/backend.hcl"
terraform plan -var-file="environments/dev/terraform.tfvars"
```

The plan is the review point for what Terraform proposes. `terraform state list` reports resources tracked by the selected state; Azure Resource Graph can reveal resources that exist outside that state. Avoid publishing plan/state output that contains sensitive values.

## Repository pointers

- [Root Terraform composition](../../main.tf)
- [Dev inputs](../../environments/dev/terraform.tfvars)
- [Sandbox inputs](../../environments/sandbox/terraform.tfvars)
- [Prod placeholder inputs](../../environments/prod/terraform.tfvars)
- [Current landing-zone inventory](current-landingzone-resources.md)
- [Root module guide](../20-repository/root-level-modules-guide.md)
- [Architecture overview](../10-architecture/architecture-overview.md)
- [Documentation index](../README.md)
