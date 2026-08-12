# Docs Map Of Content

This page is the map of content for everything under `docs/`. Use it as the index for finding the right guide before editing Terraform, pipeline behavior, deployment methods, or operating patterns.

## Start Here

- [../README.md](../README.md): primary repo guide and best starting point for most contributors
- [CURRENT_LANDINGZONE_RESOURCES.md](./CURRENT_LANDINGZONE_RESOURCES.md): resource inventory for what this repo currently provisions
- [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md): what this repo currently wires and provisions from the root landing zone
- [MODULE_USAGE_AND_DEPENDENCIES.md](./MODULE_USAGE_AND_DEPENDENCIES.md): module dependency map and module-by-module usage guidance
- [REPO_MODULES_GUIDE.md](./REPO_MODULES_GUIDE.md): repository-level standards for working with the shared module ecosystem

## Repo And Validation Docs

- [CURRENT_LANDINGZONE_RESOURCES.md](./CURRENT_LANDINGZONE_RESOURCES.md)
  Dedicated inventory of the Azure resources currently provisioned by this landing zone repo.
- [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md)
  Root wiring order, root dependency model, and current provisioned scope in this repo.
- [PIPELINES_GUIDE.md](./PIPELINES_GUIDE.md)
  Analysis of the GitHub Actions and Azure DevOps pipelines, including validation, publishing, and apply behavior.
- [REPO_MODULES_GUIDE.md](./REPO_MODULES_GUIDE.md)
  Module standards, validation expectations, and repo-level guidance for module-oriented work.
- [MODULES_INDEX.md](./MODULES_INDEX.md)
  Index of module docs and validation artifacts from the broader module ecosystem.
- [VALIDATION_SUMMARY.md](./VALIDATION_SUMMARY.md)
  Summary of module hardening and validation status captured during earlier work.
- [TERRAFORM_REFERENCE.md](./TERRAFORM_REFERENCE.md)
  Generated root-module input, output, provider, and requirement reference maintained by `terraform-docs`.

## Deployment And Application Hosting

- [DEPLOYMENT_METHODS.md](./DEPLOYMENT_METHODS.md)
  High-level deployment method guidance across the repo.
- [APP_SERVICE_DEPLOYMENT_METHODS.md](./APP_SERVICE_DEPLOYMENT_METHODS.md)
  App Service deployment patterns and tradeoffs used in this landing zone.
- [APP_SERVICE_AUTHENTICATION.md](./APP_SERVICE_AUTHENTICATION.md)
  Microsoft Entra app registration, Easy Auth, application-managed MSAL, and health endpoint guidance.
- [APP_SERVICE_PLAN_FUNCTION_APP_NOTES.md](./APP_SERVICE_PLAN_FUNCTION_APP_NOTES.md)
  Notes on App Service Plan and Function App interactions.

## Automation And Operations

- [AUTOMATION_ARI.md](./AUTOMATION_ARI.md)
  Architecture and operating notes for the Automation Account and Azure Resource Inventory workload.
- [SHARED-RUNNER-HYGIENE-STANDARD.md](./SHARED-RUNNER-HYGIENE-STANDARD.md)
  Standards for runner hygiene and shared execution environments.
- [GIT-EXTRAHEADER-RUNNER-ISSUE.md](./GIT-EXTRAHEADER-RUNNER-ISSUE.md)
  Specific troubleshooting note for Git authentication behavior on runners.

## Networking And Private Access

- [PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](./PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md)
  Reference pattern for private endpoint subnet and private DNS resolution across shared networking contexts.

## AKS And Identity

- [AKS_AUTHENTICATION_KUBELOGIN.md](./AKS_AUTHENTICATION_KUBELOGIN.md)
  AKS authentication notes, kubeconfig usage, and RBAC expectations for `kubelogin`.

## PDFs And Generated Artifacts

- [VALIDATION_SUMMARY.pdf](./VALIDATION_SUMMARY.pdf)
  PDF form of the validation summary.

## Which Doc Should I Read?

- If you want a fast answer to what this repo provisions today, start with [CURRENT_LANDINGZONE_RESOURCES.md](./CURRENT_LANDINGZONE_RESOURCES.md).
- If you are changing root Terraform wiring, start with [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md).
- If you are changing CI/CD, validation flow, snapshot publishing, or apply behavior, read [PIPELINES_GUIDE.md](./PIPELINES_GUIDE.md).
- If you are enabling or composing shared modules, read [MODULE_USAGE_AND_DEPENDENCIES.md](./MODULE_USAGE_AND_DEPENDENCIES.md).
- If you are working on deployment behavior for web apps, read [APP_SERVICE_DEPLOYMENT_METHODS.md](./APP_SERVICE_DEPLOYMENT_METHODS.md).
- If you are changing App Service authentication or health-check access, read [APP_SERVICE_AUTHENTICATION.md](./APP_SERVICE_AUTHENTICATION.md).
- If you are changing Automation or ARI, read [AUTOMATION_ARI.md](./AUTOMATION_ARI.md).
- If you are debugging networking or private access, read [PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md](./PRIVATE_ENDPOINT_PRIVATE_DNS_LOOKUP_PATTERN.md).
- If you are touching CI, validation, or repo standards, read [REPO_MODULES_GUIDE.md](./REPO_MODULES_GUIDE.md) and [VALIDATION_SUMMARY.md](./VALIDATION_SUMMARY.md).
