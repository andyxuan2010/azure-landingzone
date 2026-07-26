provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}

provider "azurerm" {
  alias           = "prod"
  subscription_id = var.prod_subscription_id
  tenant_id       = var.prod_tenant_id
  features {}
}

provider "azurerm" {
  alias           = "identity"
  subscription_id = var.identity_subscription_id
  tenant_id       = var.identity_tenant_id
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id
  tenant_id       = var.management_tenant_id
  features {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.connectivity_subscription_id
  tenant_id       = var.connectivity_tenant_id
  features {}
}

provider "azurerm" {
  alias           = "security"
  subscription_id = var.security_subscription_id
  tenant_id       = var.security_tenant_id
  features {}
}
