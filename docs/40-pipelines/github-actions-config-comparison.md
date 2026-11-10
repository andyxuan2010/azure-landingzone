# GitHub Actions configuration requirements

Updated: 2026-10-29. This document records names required by the checked-in landing-zone workflows. It does not assert that a secret or variable currently exists in a connected GitHub repository; the previous cross-repository presence matrix was a historical snapshot.

| Configuration | Purpose |
| --- | --- |
| `IS_ORIGIN` | Enable authenticated Terraform and mirror publishing when `true`; Pages publishing is eligible on mirrors. |
| `DEPLOY_DEV`, `DEPLOY_SANDBOX` | Enable the corresponding trusted-event Terraform plan. |
| `ENABLE_GITHUB_APPLY` | Enable apply after successful trusted `main` planning; manual workflow input also supports this. |
| `ENABLE_IAC_SECRET_SCAN` | Security scan runs unless this variable is exactly `false`. |
| `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` | Azure identity/context secrets in each deployment Environment. |
| `ARM_CLIENT_SECRET` | Azure client secret; optional only for Dev with configured OIDC enabled. |
| `ENABLE_AZURE_OIDC` | Dev Environment opt-in for workload identity federation. |
| `INFRACOST_API_KEY` | Optional cost-report secret. |
| `STAGE_REPOSITORY`, `STAGE_REPO_TOKEN` | GitHub stage snapshot target and publishing secret. |
| `ADO_DEV_REPOSITORY`, `ADO_DEV_REPO_PAT` | Azure DevOps Dev target and publishing secret. |
| `PUBLISH_ADO_SANDBOX`, `ADO_SANDBOX_REPOSITORY`, `ADO_SANDBOX_REPO_PAT` | Optional Azure DevOps sandbox publishing. |
| `SWA_PRIMARY_TOKEN` | Dev Environment deployment secret for the primary Static Web App. |

`GH_TF_TEMPLATE_REPO` and `AZURE_ADO_PAT2` are no longer used by the landing-zone GitHub workflow. Public modules resolve from immutable URLs in `main.tf`; obsolete remote secrets can be retired after confirming that no other workflow or consumer needs them.

Use the [pipelines guide](pipelines-guide.md) for trigger, job-dependency, artifact, authentication, and publishing behavior. Follow the [Azure authentication guide](github-actions-azure-authentication.md) before enabling OIDC.
