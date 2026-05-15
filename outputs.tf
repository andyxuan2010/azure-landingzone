output "sqldb_fqdn" {
  value       = local.feature_flags.enable_sqldb ? try(module.sqldb[0].server_fqdn, null) : null
  description = "FQDN of the Azure SQL Server when the SQL DB module is enabled."
}

output "sqldb_public_endpoint" {
  value       = local.feature_flags.enable_sqldb ? try(module.sqldb[0].public_endpoint, null) : null
  description = "Public SQL endpoint details when the SQL DB module is enabled and public access is configured. public_ip remains null because Azure SQL exposes a public FQDN rather than a dedicated static IP."
}

output "linux_vm_public_ip" {
  value       = local.feature_flags.enable_linux_vm && var.linux_vm_public_network_enabled ? try(module.linux_vm_basic[0].public_ip, null) : null
  description = "Linux VM public IP addresses when the Linux VM module is enabled and public networking is turned on."
}

output "adf_id" {
  value       = local.feature_flags.enable_adf ? try(module.adf_basic[0].id, null) : null
  description = "Azure Data Factory resource ID when the ADF module is enabled."
}

output "adf_name" {
  value       = local.feature_flags.enable_adf ? try(module.adf_basic[0].name, null) : null
  description = "Azure Data Factory name when the ADF module is enabled."
}

output "azure_ai_search_id" {
  value       = local.feature_flags.enable_azure_ai_search ? try(module.azure_ai_search[0].id, null) : null
  description = "Azure AI Search service resource ID when the Azure AI Search module is enabled."
}

output "azure_ai_search_name" {
  value       = local.feature_flags.enable_azure_ai_search ? try(module.azure_ai_search[0].name, null) : null
  description = "Azure AI Search service name when the Azure AI Search module is enabled."
}

output "azure_ai_search_endpoint" {
  value       = local.feature_flags.enable_azure_ai_search ? try(module.azure_ai_search[0].endpoint, null) : null
  description = "Azure AI Search endpoint when the Azure AI Search module is enabled."
}

output "azure_ai_search_private_endpoint_id" {
  value       = local.feature_flags.enable_azure_ai_search ? try(module.azure_ai_search[0].private_endpoint_id, null) : null
  description = "Azure AI Search private endpoint resource ID when private endpoint support is enabled."
}

output "azure_ai_service_id" {
  value       = local.feature_flags.enable_azure_ai_service ? try(module.azure_ai_service[0].id, null) : null
  description = "Azure AI Services account resource ID when the Azure AI Services module is enabled."
}

output "azure_ai_service_name" {
  value       = local.feature_flags.enable_azure_ai_service ? try(module.azure_ai_service[0].name, null) : null
  description = "Azure AI Services account name when the Azure AI Services module is enabled."
}

output "azure_ai_service_endpoint" {
  value       = local.feature_flags.enable_azure_ai_service ? try(module.azure_ai_service[0].endpoint, null) : null
  description = "Azure AI Services endpoint when the Azure AI Services module is enabled."
}

output "azure_ai_service_private_endpoint_id" {
  value       = local.feature_flags.enable_azure_ai_service ? try(module.azure_ai_service[0].private_endpoint_id, null) : null
  description = "Azure AI Services private endpoint resource ID when private endpoint support is enabled."
}

output "openai_id" {
  value       = local.feature_flags.enable_openai ? try(module.openai[0].id, null) : null
  description = "Azure OpenAI account resource ID when the OpenAI module is enabled."
}

output "openai_name" {
  value       = local.feature_flags.enable_openai ? try(module.openai[0].name, null) : null
  description = "Azure OpenAI account name when the OpenAI module is enabled."
}

output "openai_endpoint" {
  value       = local.feature_flags.enable_openai ? try(module.openai[0].endpoint, null) : null
  description = "Azure OpenAI endpoint when the OpenAI module is enabled."
}

output "openai_deployment_ids" {
  value       = local.feature_flags.enable_openai ? try(module.openai[0].deployment_ids, {}) : {}
  description = "Azure OpenAI deployment resource IDs keyed by deployment name when the OpenAI module is enabled."
}

output "openai_private_endpoint_id" {
  value       = local.feature_flags.enable_openai ? try(module.openai[0].private_endpoint_id, null) : null
  description = "Azure OpenAI private endpoint resource ID when private endpoint support is enabled."
}
