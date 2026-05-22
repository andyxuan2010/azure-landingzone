# Current Landing Zone Resources

This document describes the resources currently provisioned by this landing zone repo based on the root Terraform wiring in `main.tf` and the features enabled in the checked-in `terraform.tfvars`.

It is intended to answer one practical question quickly:

- what does this repo actually create today?

For root wiring order, dependency flow, and the broader module context, also see [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md).

## Summary

The current repo provisions a shared Azure landing zone focused on:

- management group and subscription bootstrap
- shared foundation resources
- hub/spoke networking
- App Service hosting
- Automation Account and Azure Resource Inventory
- Linux runner or jumpbox resources

## Governance And Subscription Bootstrap

The current root configuration provisions:

- a platform management group
- a landing zone management group
- a sandboxes management group
- child management groups under the platform group for:
  `connectivity`, `identity`, `security`, and `management`
- subscription vending and management group association for the subscriptions defined in `hierarchy_subscriptions`

These resources are controlled primarily by:

- `enable_management_group`
- `mg_platform_children`
- `mg_landingzone_children`
- `enable_subscription_bootstrap`
- `hierarchy_subscriptions`

## Shared Foundation Resources

The current root configuration provisions:

- one shared resource group
- one Log Analytics workspace
- one shared storage account
- one shared Key Vault

It also applies supporting configuration for the shared foundation:

- blob service settings on the storage account for versioning, soft delete, change feed, and restore policy
- optional Key Vault secrets for Linux VM admin override values when those root inputs are populated

## Network Resources

The current root configuration provisions:

- one hub virtual network
- one spoke virtual network
- bidirectional VNet peering between hub and spoke
- one Network Security Group for spoke workloads
- subnet-to-NSG associations for selected spoke subnets
- private DNS zones listed in `private_dns_zone_names`

### Current subnet layout

The spoke VNet is wired with these subnets:

- `snet-app`
- `snet-private-endpoints`
- `snet-databricks-public`
- `snet-databricks-private`
- `snet-aks`
- `snet-jumpbox`
- `snet-sqlmi`

The hub VNet currently includes:

- `AzureFirewallSubnet`

### Notes

- The firewall module block exists in `main.tf` but is currently commented out, so Azure Firewall is not provisioned by this repo today.
- The checked-in `terraform.tfvars` currently enables `privatelink.azurewebsites.net` in `private_dns_zone_names`.

## App Platform Resources

The current root configuration provisions App Service resources from the `app_services` map.

For each enabled app entry, the repo provisions:

- one App Service Plan
- one App Service
- one Entra app registration when `enable_app_registration_for_appservice = true`

The checked-in `terraform.tfvars` currently enables these app entries:

- `dotnet`
- `node`
- `python`

### Current App Service behavior

The checked-in root inputs currently configure:

- public network access enabled for App Service
- optional App Service private endpoints enabled
- App Service auth wiring enabled through app registrations

## Automation And ARI Resources

The current root configuration provisions:

- one Azure Automation Account per enabled entry in `automation_accounts`
- RBAC assignments from the Automation Account managed identity to shared storage and Key Vault
- shared storage containers for:
  `localization`, `scripts`, and `terraform`
- one ARI output container per enabled ARI workload
- one Automation runtime environment per enabled ARI workload
- one runtime package resource per configured ARI package
- one Automation runbook per enabled ARI workload
- one Automation schedule and one Automation job schedule per enabled ARI workload when scheduling is enabled

The checked-in `terraform.tfvars` currently enables:

- the `default` Automation Account
- the `default` ARI workload
- the ARI daily schedule

### Notes

- The monitor alert resources for ARI are still present in `main.tf` as commented blocks and are not currently provisioned.

## Linux Runner Or Jumpbox Resources

The current root configuration provisions Linux VM resources when `enable_linux_vm = true`.

With the checked-in `terraform.tfvars`, this repo currently provisions:

- one Linux VM deployment through the `linuxvm` module
- shared localization script content when upload is enabled
- App Service `Website Contributor` role assignments from the Linux VM managed identity to each enabled App Service

This wiring supports the shared runner or jumpbox pattern used by the landing zone.

## Resources Not Currently Provisioned

The broader template ecosystem includes additional module patterns, but they are not currently active as root provisioned resources in this repo.

Examples include:

- `acr`
- `adf`
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

## Where To Look In Code

- [`main.tf`](../main.tf): root resource and module wiring
- [`variables.tf`](../variables.tf): root inputs that control resource creation
- [`terraform.tfvars`](../terraform.tfvars): checked-in example values and currently enabled features
- [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md): root dependency order and broader guide
