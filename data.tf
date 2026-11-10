# Resolve the optional external vault used for SQL administrator credentials.
data "azurerm_key_vault" "sql_iac" {
  count = trimspace(var.sql_admin_credentials_key_vault_id) == "" && trimspace(var.sql_iac_rg) != "" && trimspace(var.sql_iac_kv) != "" ? 1 : 0

  name                = var.sql_iac_kv
  resource_group_name = var.sql_iac_rg
}
