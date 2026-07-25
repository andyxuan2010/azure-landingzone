# GitHub Actions Config Comparison

Comparison between:

- `CCOE-Azure-Terraform/azure-landingzone`
- `CCOE-Azure-Terraform/azure-template`

Secret values are not readable from GitHub, so this document compares names only.

Legend: `✅` = present, `❌` = missing.

## Repo Variables

| Variable | Applicable environment | landingzone | template |
|---|---|---:|---:|
| `ADO_DEV_REPOSITORY` | dev publish | `✅` | `✅` |
| `ADO_PROD_REPOSITORY` | prod publish | `❌` | `✅` |
| `ADO_SANDBOX_REPOSITORY` | sandbox publish | `✅` | `❌` |
| `DEPLOY_DEV` | dev deploy | `✅` | `❌` |
| `DEPLOY_PROD` | prod deploy | `✅` | `❌` |
| `DEPLOY_SANDBOX` | sandbox deploy | `✅` | `❌` |
| `ENABLE_GITHUB_APPLY` | repo/global | `✅` | `✅` |
| `PUBLISH_ADO_SANDBOX` | sandbox publish | `✅` | `❌` |
| `PUBLISH_ADO_PROD` | prod publish | `❌` | `✅` |
| `STAGE_REPOSITORY` | stage publish | `✅` | `✅` |
| `TF_BACKEND_READY` | repo/global | `❌` | `✅` |

## Repo Secrets

| Secret | Applicable environment | landingzone | template |
|---|---|---:|---:|
| `ADO_DEV_REPO_PAT` | dev publish | `❌` | `❌` |
| `ADO_PROD_REPO_PAT` | prod publish | `❌` | `✅` |
| `ADO_REPO_DEV_PAT` | dev publish | `❌` | `✅` |
| `ADO_REPO_PAT` | legacy ADO publish | `✅` | `✅` |
| `ADO_REPO_URL` | legacy ADO publish | `✅` | `❌` |
| `ADO_SANDBOX_REPO_PAT` | sandbox publish | `✅` | `❌` |
| `AZURE_ADO_PAT` | legacy module/source access | `✅` | `❌` |
| `AZURE_ADO_PAT2` | Terraform module download | `✅` | `❌` |
| `AZURE_CLIENT_ID` | Terraform Azure auth | `❌` | `✅` |
| `AZURE_CLIENT_SECRET` | Terraform Azure auth | `❌` | `✅` |
| `AZURE_DEVOPS_EXT_PAT` | legacy Azure DevOps CLI | `✅` | `❌` |
| `AZURE_MODULE_ACCESS_TOKEN` | legacy module/source access | `✅` | `❌` |
| `AZURE_SUBSCRIPTION_ID` | Terraform Azure auth | `❌` | `✅` |
| `AZURE_TENANT_ID` | Terraform Azure auth | `❌` | `✅` |
| `INFRACOST_API_KEY` | cost report | `✅` | `❌` |
| `STAGE_REPO_TOKEN` | stage publish | `✅` | `✅` |
| `STAGE_REPO_URL` | legacy stage publish | `✅` | `❌` |

## Environment Secrets

| Environment | landingzone | template |
|---|---|---|
| `dev` | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID` | none |
| `sandbox` | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID` | none |
| `prod` | not present | none |
| `demo` | not present | none |

## Key Finding

The current landingzone workflow expects `ADO_DEV_REPO_PAT`, but that secret is not configured in `azure-landingzone` yet.
