# Configure the backend for Terraform state management. The first block configures the Azure Resource Manager (azurerm) backend, while the second block configures a local backend for testing purposes. Depending on your environment and requirements, you can choose which backend to use by commenting out the one you don't need.
terraform {
  backend "azurerm" {}
}

# local backend for testing
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }