# GitHub Actions Authentication to Azure for Terraform Deployments

## Purpose

This document assesses the authentication options for deploying the development Azure environment from GitHub Actions. It compares the repository's current service-principal client-secret model with OpenID Connect (OIDC), also called Microsoft Entra workload identity federation.

The assessment reflects the repository state reviewed on July 27, 2026.

## Executive Summary

The current GitHub Actions workflow authenticates Terraform to Azure with a Microsoft Entra service principal and a long-lived client secret. The `plan_dev` and `apply_dev` jobs obtain the following values from the GitHub `dev` Environment:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

This approach works and is straightforward, but the client secret must be stored, protected, rotated, and revoked when exposure is suspected. Microsoft identifies service-principal secret authentication for Azure Login as not recommended, while Microsoft, GitHub, and HashiCorp recommend OIDC/workload identity federation for this use case.

The recommended target is:

> Use GitHub OIDC with a dedicated Microsoft Entra deployment identity, scoped to the GitHub repository and `dev` Environment, while preserving GitHub Environment approval controls and least-privilege Azure RBAC.

OIDC removes the long-lived Azure credential from GitHub. Each authorized job exchanges a short-lived, signed GitHub identity token for an Azure access token. It does not eliminate the deployment identity or its Azure permissions; it changes how that identity proves who it is.

## Current Repository Implementation

The workflow is defined in [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml).

### Azure authentication

Both development jobs use the GitHub Environment named `dev`:

| Job | Authentication inputs | Purpose |
| --- | --- | --- |
| `plan_dev` | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` | Initialize the AzureRM backend and run the Terraform validation and plan |
| `apply_dev` | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` | Initialize the backend and apply the saved Terraform plan |

OIDC support is prepared behind the GitHub `dev` Environment variable `ENABLE_AZURE_OIDC`. Unless that variable is explicitly set to `true`, each job requires `ARM_CLIENT_SECRET` and uses the AzureRM provider and backend's service-principal client-secret authentication path. The switch is disabled by default.

When `ENABLE_AZURE_OIDC=true`, the development jobs:

- receive the job-level `id-token: write` permission;
- set `ARM_USE_OIDC=true` and `ARM_USE_AZUREAD=true`;
- do not inject `ARM_CLIENT_SECRET`;
- validate the client, tenant, and subscription identifiers without requiring a client secret.

Enabling the switch alone is not sufficient: the matching Microsoft Entra federated identity credential and backend/provider RBAC must exist before the first OIDC run.

### Credentials that are not Azure deployment authentication

The following credentials have different trust boundaries and should not be confused with Azure authentication:

| Credential | Purpose | Replaced by Azure OIDC migration? |
| --- | --- | --- |
| `AZURE_ADO_PAT2` | Clones Terraform modules hosted in Azure DevOps | No |
| `STAGE_REPO_TOKEN` | Publishes to the GitHub stage repository | No |
| `ADO_DEV_REPO_PAT` | Publishes to the Azure DevOps development repository | No |
| `ADO_SANDBOX_REPO_PAT` | Publishes to the Azure DevOps sandbox repository | No |
| `${{ github.token }}` | GitHub API/repository operations within the workflow | No |

Moving Azure deployment authentication to OIDC only removes `ARM_CLIENT_SECRET`. The other tokens require separate analysis and lifecycle controls.

## Option 1: Continue Using a Service Principal Client Secret

### How it works

GitHub stores a long-lived password for the Microsoft Entra application. Terraform sends the client ID and secret to Microsoft Entra ID to obtain Azure access tokens. The deployment permissions are determined by Azure RBAC and any Microsoft Graph/application permissions assigned to the service principal.

### Advantages

- Already implemented and operational in both development plan and apply jobs.
- Supported directly by the Terraform AzureRM provider and AzureRM backend.
- Familiar troubleshooting model with relatively few moving parts.
- Can be used from systems that do not support GitHub OIDC.
- Does not require configuring a federated identity credential or matching GitHub token claims.
- Can provide a temporary fallback during an OIDC migration.

### Disadvantages

- Stores a reusable Azure credential in GitHub.
- A copied secret can be used outside GitHub Actions until it expires or is revoked.
- Requires an ownership process for expiry monitoring, rotation, GitHub secret updates, and emergency revocation.
- Rotation can interrupt plans and deployments if Azure and GitHub updates are not coordinated.
- Secret exposure may occur through workflow mistakes, unsafe third-party actions, compromised repository administration, or accidental local handling.
- The credential alone does not bind authentication to a specific repository, branch, environment, or workflow.
- Audit records identify the Azure service principal but do not inherently prove which GitHub repository context was authorized.
- Microsoft classifies service-principal secret authentication for Azure Login as not recommended.

### When it may still be justified

Client-secret authentication can be acceptable as a time-limited exception when federation is unavailable, a dependent tool cannot consume OIDC, or a rollback credential is required during migration. Such an exception should have:

- the shortest practical expiry;
- documented ownership and rotation;
- least-privilege Azure RBAC;
- GitHub Environment protection;
- monitoring for sign-ins and credential expiry;
- a removal date.

## Option 2: Use GitHub OIDC / Workload Identity Federation

### How it works

1. GitHub creates a short-lived OIDC identity token for an authorized workflow job.
2. Microsoft Entra ID validates the token's issuer, audience, and subject against a federated identity credential.
3. Microsoft Entra ID issues a short-lived Azure access token for the configured application or user-assigned managed identity.
4. Terraform uses that access token for the AzureRM backend and provider.

For this repository, the federated credential should be constrained to the GitHub organization, repository, and `dev` Environment. Because the jobs declare `environment: dev`, the expected default GitHub subject is:

```text
repo:<organization>/<repository>:environment:dev
```

The exact organization and repository values must be taken from the target GitHub repository; they should not be guessed during implementation.

### Advantages

- No long-lived Azure client secret is stored in GitHub.
- Azure access tokens are short-lived and issued only when an eligible job runs.
- Trust can be bound to repository metadata, particularly the protected `dev` Environment.
- Eliminates client-secret expiry and rotation outages.
- A stolen historical token has a much smaller useful lifetime than a copied client secret.
- Preserves the existing Microsoft Entra identity and Azure RBAC model; only its credential mechanism changes.
- Supported by the AzureRM backend and Terraform Azure providers.
- Aligns with current guidance from Microsoft, GitHub, and HashiCorp.
- Makes separation by environment practical: each environment can have its own identity, federated credential, RBAC scope, and approval policy.

### Disadvantages and operational considerations

- Initial setup is more involved: a federated credential and exact claim matching are required.
- Incorrect issuer, audience, subject, environment name, or repository name causes authentication failure.
- Renaming or transferring the repository, changing the GitHub Environment name, or changing the selected subject model requires coordinated federation updates.
- The workflow must receive `id-token: write`. This permission allows a job to request a GitHub OIDC token; Azure access is still controlled by the Entra federated credential and Azure RBAC.
- Workflow and environment governance become part of the security boundary. Unauthorized edits to deployment workflows, weak branch protection, or overly broad Environment access can undermine the intended restrictions.
- Third-party actions used in a job with OIDC permission must be pinned and reviewed because the job can request an identity token.
- OIDC does not reduce excessive Azure RBAC. A federated identity with Owner-level access remains overprivileged.
- OIDC does not replace the Azure DevOps PAT currently used for private Terraform module downloads.
- Incident response changes: responders revoke or remove the federated credential, disable the identity, or remove RBAC rather than rotate a password.

## Side-by-Side Decision Matrix

| Criterion | Client secret | GitHub OIDC |
| --- | --- | --- |
| Long-lived Azure credential in GitHub | Yes | No |
| Token lifetime | Secret is reusable until expiry/revocation; resulting access tokens are short-lived | Federated assertion and resulting access tokens are short-lived |
| Rotation burden | Required | No Azure secret rotation |
| Repository/environment binding | Not inherent | Enforced through federated token claims |
| Initial setup complexity | Low | Moderate |
| Ongoing operational burden | Moderate | Low after setup |
| Impact of credential disclosure | Potential use from outside GitHub until expiry/revocation | Limited by short lifetime and federated claim validation |
| Terraform backend support | Yes | Yes |
| Terraform provider support | Yes | Yes |
| Microsoft recommendation | Not recommended for Azure Login | Recommended |
| Best fit for this deployment | Temporary compatibility/fallback | Strategic target |

## Risk Analysis

Authentication is only one layer of deployment security. With either method, the deployment identity can do everything granted through Azure RBAC and directory permissions.

### Principal risks in the current model

1. **Reusable credential theft:** `ARM_CLIENT_SECRET` can potentially be replayed outside the expected workflow.
2. **Rotation failure:** expiry or an incomplete update can stop `terraform init`, plan, and apply.
3. **Broad identity scope:** if the same service principal is shared across environments, compromise affects more than development.
4. **Workflow supply-chain exposure:** an action or script running in the job can access job credentials.
5. **Excess privileges:** broad subscription roles increase the impact of either credential type.

### Risks that remain after OIDC migration

1. **Compromised deployment workflow:** malicious workflow code can request a token during an authorized run.
2. **Weak Environment controls:** insufficient reviewers or permissive deployment branches can authorize unintended deployments.
3. **Overprivileged identity:** federation limits who can authenticate, not what the identity can do after authentication.
4. **Unpinned actions:** mutable third-party action tags can introduce unexpected code into a privileged job.
5. **State access:** the identity still requires appropriate access to the Terraform state container, and state must remain protected as sensitive data.

## Recommendation

Adopt GitHub OIDC for development deployments, then extend the same pattern to sandbox and production using separate identities and federated credentials.

The recommended design is:

- one Microsoft Entra deployment identity per Azure environment;
- one federated credential bound to the corresponding GitHub Environment;
- GitHub Environment required reviewers and deployment-branch restrictions;
- least-privilege Azure RBAC at the narrowest workable scopes;
- separate backend data-plane access, typically `Storage Blob Data Contributor` on the relevant Terraform state container or storage scope;
- no `ARM_CLIENT_SECRET` after migration validation;
- job-level `id-token: write` where practical, instead of granting it globally;
- reviewed and commit-SHA-pinned third-party actions in token-enabled jobs;
- Azure sign-in and activity-log monitoring for the deployment identity.

Using the existing `dev` Environment in the federated subject is preferable to branch-only federation. It retains environment approval and policy as a deliberate deployment boundary and supports both the plan and apply jobs that already reference that Environment.

## Prepared Workflow Configuration

The Terraform-native approach is prepared to use GitHub's OIDC request variables directly:

```yaml
plan_dev:
  environment: dev
  permissions:
    contents: read
    pull-requests: write
    id-token: write
  env:
    ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
    ARM_CLIENT_SECRET: ${{ vars.ENABLE_AZURE_OIDC != 'true' && secrets.ARM_CLIENT_SECRET || '' }}
    ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
    ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
    ARM_USE_OIDC: ${{ vars.ENABLE_AZURE_OIDC == 'true' }}
    ARM_USE_AZUREAD: ${{ vars.ENABLE_AZURE_OIDC == 'true' }}
```

The equivalent configuration is present on `apply_dev`. Both credential-validation steps require `ARM_CLIENT_SECRET` only while OIDC is disabled.

The client ID, tenant ID, and subscription ID are identifiers rather than passwords. They remain GitHub Environment secrets in the prepared configuration, but may later be moved to protected Environment variables. `ARM_USE_AZUREAD=true` directs the backend to use Microsoft Entra ID for Azure Storage data-plane access; backend RBAC must be verified before cutover.

An `azure/login` step is useful when later steps run Azure CLI or Azure PowerShell commands. For Terraform alone, current HashiCorp documentation states that the AzureRM backend and providers can use GitHub's OIDC request environment variables directly. The implementation should select one clear pattern and test both backend and provider authentication.

## Migration Plan

### 1. Inventory and scope

- Identify the current development service principal and all of its Azure RBAC and Microsoft Graph/application permissions.
- Confirm whether it is shared with sandbox, production, Azure DevOps, or non-GitHub automation.
- Identify the exact GitHub organization, repository, and Environment names.
- Verify the backend's data-plane authorization model and current role assignments.

### 2. Create the federated trust

- Prefer a dedicated development deployment identity.
- Assign only the roles required by the landing-zone deployment.
- Add a federated identity credential with:
  - issuer: `https://token.actions.githubusercontent.com`
  - audience: `api://AzureADTokenExchange`
  - subject: `repo:<organization>/<repository>:environment:dev`
- Retain GitHub Environment approvals and restrict deployment branches.

### 3. Update the workflow

- Confirm `id-token: write` on `plan_dev` and `apply_dev`.
- Set `ENABLE_AZURE_OIDC=true` in the protected GitHub `dev` Environment.
- Confirm that this makes `ARM_USE_OIDC=true` and `ARM_USE_AZUREAD=true`.
- Retain the client, tenant, and subscription identifiers.
- Confirm that the workflow no longer injects or requires `ARM_CLIENT_SECRET`.
- Do not alter `AZURE_ADO_PAT2` as part of this change.

### 4. Validate safely

- Test `terraform init` against the development backend.
- Run `terraform validate` and a development plan.
- Confirm the plan is generated by the intended Azure identity.
- Perform an approved, low-risk development apply.
- Review Microsoft Entra sign-in logs and Azure Activity Logs.
- Confirm that a nonmatching branch/repository/environment cannot obtain Azure access.

### 5. Remove the old credential

- Delete `ARM_CLIENT_SECRET` from the GitHub `dev` Environment after successful validation.
- Remove or revoke the application password if no other workload uses it.
- Document the federation, owner, RBAC assignments, and emergency revocation process.
- Repeat the migration independently for other environments.

## Rollback Strategy

During a short migration window, retain the existing client secret without using it in the updated workflow. If OIDC fails:

1. revert the workflow authentication configuration;
2. restore the `ARM_CLIENT_SECRET` reference;
3. diagnose the issuer, subject, audience, permissions, and backend RBAC;
4. reschedule secret removal.

The fallback should be time-boxed. Permanently retaining an unused application password preserves the original risk.

## Acceptance Criteria

The migration is complete when:

- development plan and apply jobs succeed without `ARM_CLIENT_SECRET`;
- the AzureRM backend and all Azure-related Terraform providers authenticate through OIDC;
- the federated subject is restricted to the intended repository and `dev` Environment;
- the deployment identity has documented least-privilege roles;
- GitHub Environment approval and branch restrictions are enabled as required;
- Azure sign-in and activity logs show the expected identity;
- the old client secret is removed from GitHub and revoked in Microsoft Entra ID when no longer used;
- PAT-based module and repository access is tracked separately.

## References

- [Microsoft Learn: Use GitHub Actions to connect to Azure](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [Microsoft Learn: Use Azure Login with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [Microsoft Learn: GitHub Actions workload identity federation with Terraform](https://learn.microsoft.com/en-us/samples/azure-samples/github-terraform-oidc-ci-cd/github-terraform-oidc-ci-cd/)
- [GitHub Docs: Configuring OpenID Connect in Azure](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [GitHub Docs: OpenID Connect](https://docs.github.com/en/actions/concepts/security/openid-connect)
- [HashiCorp: AzureRM backend authentication](https://developer.hashicorp.com/terraform/language/backend/azurerm)
- [HashiCorp: Azure provider service-principal OIDC guidance](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_oidc)
