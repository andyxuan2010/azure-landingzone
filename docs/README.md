# Docs Map Of Content

This page is the map of content for everything under `docs/`. Use it as the index for finding the right guide before editing Terraform, pipeline behavior, deployment methods, or operating patterns.

## Start Here

- [../README.md](../README.md): primary repo guide and best starting point for most contributors
- [current-landingzone-resources.md](80-reference/current-landingzone-resources.md): resource inventory for what this repo currently provisions
- [root-level-modules-guide.md](20-repository/root-level-modules-guide.md): what this repo currently wires and provisions from the root landing zone
- [module-usage-and-dependencies.md](20-repository/module-usage-and-dependencies.md): module dependency map and module-by-module usage guidance
- [repository-modules-guide.md](20-repository/repository-modules-guide.md): repository-level standards for working with the shared module ecosystem

## Repo And Validation Docs

- [current-landingzone-resources.md](80-reference/current-landingzone-resources.md)
  Dedicated inventory of the Azure resources currently provisioned by this landing zone repo.
- [root-level-modules-guide.md](20-repository/root-level-modules-guide.md)
  Root wiring order, root dependency model, and current provisioned scope in this repo.
- [pipelines-guide.md](40-pipelines/pipelines-guide.md)
  Analysis of the GitHub Actions and Azure DevOps pipelines, including validation, publishing, and apply behavior.
- [repository-modules-guide.md](20-repository/repository-modules-guide.md)
  Module standards, validation expectations, and repo-level guidance for module-oriented work.
- [modules-index.md](20-repository/modules-index.md)
  Index of module docs and validation artifacts from the broader module ecosystem.
- [validation-summary.md](70-validation/validation-summary.md)
  Summary of module hardening and validation status captured during earlier work.
- [terraform-reference.md](80-reference/terraform-reference.md)
  Generated root-module input, output, provider, and requirement reference maintained by `terraform-docs`.

## Deployment And Application Hosting

- [deployment-methods.md](30-deployment/deployment-methods.md)
  High-level deployment method guidance across the repo.
- [static-web-app-deployment.md](30-deployment/static-web-app-deployment.md)
  Deployment methods, token handling, CI/CD examples, and verification for the Dev Free Static Web App.
- [app-service-deployment-methods.md](30-deployment/app-service-deployment-methods.md)
  App Service deployment patterns and tradeoffs used in this landing zone.
- [app-service-authentication.md](30-deployment/app-service-authentication.md)
  Microsoft Entra app registration, Easy Auth, application-managed MSAL, and health endpoint guidance.
- [app-service-plan-function-app-notes.md](30-deployment/app-service-plan-function-app-notes.md)
  Notes on App Service Plan and Function App interactions.

## Automation And Operations

- [automation-ari.md](50-operations/automation-ari.md)
  Architecture and operating notes for the Automation Account and Azure Resource Inventory workload.
- [shared-runner-hygiene.md](40-pipelines/shared-runner-hygiene.md)
  Standards for runner hygiene and shared execution environments.
- [git-extraheader-runner-issue.md](40-pipelines/git-extraheader-runner-issue.md)
  Specific troubleshooting note for Git authentication behavior on runners.

## Networking And Private Access

- [private-endpoint-private-dns.md](10-architecture/private-endpoint-private-dns.md)
  Reference pattern for private endpoint subnet and private DNS resolution across shared networking contexts.

## AKS And Identity

- [aks-authentication-kubelogin.md](30-deployment/aks-authentication-kubelogin.md)
  AKS authentication notes, kubeconfig usage, and RBAC expectations for `kubelogin`.

## PDFs And Generated Artifacts

- [VALIDATION_SUMMARY.pdf](./VALIDATION_SUMMARY.pdf)
  PDF form of the validation summary.

## Which Doc Should I Read?

- If you want a fast answer to what this repo provisions today, start with [current-landingzone-resources.md](80-reference/current-landingzone-resources.md).
- If you are changing root Terraform wiring, start with [root-level-modules-guide.md](20-repository/root-level-modules-guide.md).
- If you are changing CI/CD, validation flow, snapshot publishing, or apply behavior, read [pipelines-guide.md](40-pipelines/pipelines-guide.md).
- If you are enabling or composing shared modules, read [module-usage-and-dependencies.md](20-repository/module-usage-and-dependencies.md).
- If you are working on deployment behavior for web apps, read [app-service-deployment-methods.md](30-deployment/app-service-deployment-methods.md).
- If you are changing App Service authentication or health-check access, read [app-service-authentication.md](30-deployment/app-service-authentication.md).
- If you are changing Automation or ARI, read [automation-ari.md](50-operations/automation-ari.md).
- If you are debugging networking or private access, read [private-endpoint-private-dns.md](10-architecture/private-endpoint-private-dns.md).
- If you are touching CI, validation, or repo standards, read [repository-modules-guide.md](20-repository/repository-modules-guide.md) and [validation-summary.md](70-validation/validation-summary.md).

## Current maintenance and security record

- [Repository security controls](60-security-governance/repository-security.md): dependency, network, credential, script, and content controls with rollout requirements.
- [Code standards](60-security-governance/code-standards.md): supported tools, source normalization, and local checks.
- [Change log](../CHANGELOG.md): dated record of repository changes.
- [Validation summary](70-validation/validation-summary.md): executed checks, findings, and limits.
