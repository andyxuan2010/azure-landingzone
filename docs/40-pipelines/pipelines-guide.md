# Pipelines guide

Updated: 2026-10-29. This guide describes the checked-in workflow behavior. Repository variables, secrets, environment approvals, and Azure RBAC must be verified in the target systems.

## GitHub Actions

[Terraform workflow](../../.github/workflows/terraform.yml) runs on pushes and pull requests for `main`, manual dispatch, and `stage-snapshot` repository dispatch. Documentation-only pull requests are excluded by its path filters; the separate repository quality workflow still checks documentation.

`static-validation` runs independently of `IS_ORIGIN`, deployment flags, and Azure credentials. It checks formatting, initializes without a backend using the committed provider lockfile, validates the root composition, and runs Trivy for HIGH/CRITICAL misconfiguration and secret findings. `ENABLE_IAC_SECRET_SCAN=false` explicitly skips the Trivy step and should require a documented exception.

`terraform-gate` enables authenticated execution and publishing only when `IS_ORIGIN=true`. `validation-precheck` checks deployment flags and optional publishing/cost inputs. `plan_dev` and `plan_sandbox` require successful static validation, the origin gate, their deployment flag, and a non-pull-request event. PR-controlled Terraform is never run with deployment environment credentials.

The root fetches public upstream modules pinned in `main.tf`. GitHub jobs no longer clone an unused sibling template repository or require the old `GH_TF_TEMPLATE_REPO` / `AZURE_ADO_PAT2` module-download settings.

| Input | Scope and behavior |
| --- | --- |
| `IS_ORIGIN` | Repository variable; `true` enables authenticated Terraform and publishing jobs. |
| `DEPLOY_DEV`, `DEPLOY_SANDBOX` | Repository variables enabling the respective trusted-event plan jobs. |
| `ENABLE_GITHUB_APPLY` | Repository variable enabling apply; manual dispatch can also request apply through its boolean input. |
| `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` | Target GitHub Environment secrets for Azure authentication. |
| `ARM_CLIENT_SECRET` | Environment secret for client-secret authentication; Dev omits it when `ENABLE_AZURE_OIDC=true`. Sandbox still requires it. |
| `ENABLE_AZURE_OIDC` | Dev Environment variable opting into OIDC after federation and RBAC are configured. |
| `INFRACOST_API_KEY` | Optional cost-report secret used by trusted plan jobs. |
| `STAGE_REPOSITORY`, `STAGE_REPO_TOKEN` | Stage snapshot target and publishing credential. |
| `ADO_DEV_REPOSITORY`, `ADO_DEV_REPO_PAT` | Azure DevOps Dev mirror target and publishing credential. |
| `PUBLISH_ADO_SANDBOX`, `ADO_SANDBOX_REPOSITORY`, `ADO_SANDBOX_REPO_PAT` | Optional sandbox mirror controls. |

`apply_dev` and `apply_sandbox` run only for successful trusted `main` plans with apply enabled. Each downloads and applies its exact saved binary plan. Plans are retained as GitHub artifacts for one day and may contain secrets. The workflows do not establish that external environment approvals have been configured.

Trusted plan runs optionally generate Infracost reports and upload the JSON/text report artifacts. Authenticated plans and cost reporting do not run on PR events, and the jobs have no pull-request write permission.

Tag creation follows a successful Dev apply. Stage snapshot publishing requires a successful Dev plan and successful or skipped tag creation; Azure DevOps publishing follows a successful apply for the corresponding environment. Stage snapshots exclude `static-web-apps/`. Mirror jobs intentionally replace branch history with source snapshots, so their target variables and tokens require careful scoping.

## Azure DevOps

[azure-pipelines.yml](../../azure-pipelines.yml) triggers on `main`; PR triggering is disabled in this YAML. The `ADO_AGENT_ENABLED=true` variable enables the pipeline stages. Shared variable groups supply the runner pool/image, `ENVIRONMENT`, `TERRAFORM_VERSION`, `AZURE_SERVICE_CONNECTION`, and apply controls.

The Validate stage installs the requested stable Terraform release through the [verified installer](../../scripts/azure-pipelines/install-terraform.sh), fails on formatting drift, initializes without the backend, and validates. Keep `TERRAFORM_VERSION` aligned with [`.terraform-version`](../../.terraform-version).

The Plan stage reads `environments/<environment>/backend.hcl`, uses the matching variable file, authenticates through the Azure service connection, saves a plan, and publishes the binary plan and readable summary. The backend files contain only state-storage coordinates; the Azure CLI task exports `ARM_SUBSCRIPTION_ID` and `ARM_TENANT_ID` from the selected service connection for Terraform's AzureRM backend. Apply uses the saved plan when `ENABLE_ADO_APPLY=true`. `useEnvironmentApprovals` selects an Azure DevOps deployment job with environment approvals; its default is `false`, so administrators must opt into the approved execution path.

Azure DevOps still checks out its configured template repository for compatibility with existing consumers. The root module sources themselves are pinned GitHub URLs. Shared module-download authentication is process-scoped; runner hygiene prints only Git authentication key names, never header values.

## Documentation and demo delivery

[Repository quality](../../.github/workflows/repository-quality.yml) runs script syntax, security regression, Markdown-link, static-site, and generated-doc checks on pushes and PRs without cloud credentials.

[Pages](../../.github/workflows/pages.yml) builds the documentation portal and publishes public mirror repositories when the origin gate is false and the ref is `main`. The gate messages now describe that behavior accurately. Pages write and OIDC permissions are scoped to the deployment job.

[Static Web Apps](../../.github/workflows/static-web-apps.yml) validates all checked-in demo HTML and response-header configuration, then uploads `static-web-apps/north-peak-cloud` to the single Dev target on `main`. Deployment requires the Dev Environment secret `SWA_PRIMARY_TOKEN`.

## Local checks and rollout

Run `./test.ps1 -InitializeTerraform`, build/test the documentation portal, and run the documented lint/security scans before publishing. See [code standards](../60-security-governance/code-standards.md) and the [validation record](../70-validation/validation-summary.md).

The shared storage and Key Vault now enforce deny-by-default public ACLs. Before an authenticated plan/apply, verify the approved runner egress allowlist and SSH recovery access as described in [repository security controls](../60-security-governance/repository-security.md). No live Azure deployment was performed during the repository rescan.
