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
