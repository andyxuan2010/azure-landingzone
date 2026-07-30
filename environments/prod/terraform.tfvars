# Placeholder production environment file.
# Replace all TODO values before enabling production deployments.

features = {
  enable_fortigate = false
}

subscription_id              = "00000000-0000-0000-0000-000000000000"
prod_subscription_id         = "00000000-0000-0000-0000-000000000000"
identity_subscription_id     = "00000000-0000-0000-0000-000000000000"
management_subscription_id   = "00000000-0000-0000-0000-000000000000"
connectivity_subscription_id = "00000000-0000-0000-0000-000000000000"
security_subscription_id     = "00000000-0000-0000-0000-000000000000"

location            = "eastus"
workload            = "platform"
environment         = "prod"
resource_group_name = "TODO-rg-platform-prod"

# Intentionally minimal placeholder.
# Add the rest of the required production values before enabling plan/apply.
