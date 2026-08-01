# Repository validation summary

Last validated: 2026-07-29

## Scope

This validation covers the landing-zone root configuration, environment inputs,
GitHub Actions, Azure Pipelines, repository scripts, documentation links, and the
modules consumed from the sibling `azure-template` checkout.

## Results

- `terraform fmt -check -recursive`: passed.
- `terraform init -backend=false`: passed.
- `terraform validate`: passed.
- YAML parsing for GitHub Actions, Azure Pipelines, and templates: passed.
- PowerShell parser validation: passed.
- TFLint: no errors; the remaining warnings are unused compatibility inputs,
  data sources, and locals retained by the root composition.
- Trivy HIGH/CRITICAL scan: no authored landing-zone findings. Three findings
  remain in the separately maintained `azure-template` repository:
  - `keyvault`: network ACL configuration (`AZU-0013`, critical).
  - `storageaccount`: network default action (`AZU-0012`, critical).
  - `linuxvm`: password authentication (`AZU-0039`, high).

The upstream module findings must be remediated and released in
`azure-template`; this repository must not carry an unreviewed local fork of
shared security modules.

## Hardening applied

- Constrained the `azapi` provider to the compatible `2.x` release line.
- Reduced workflow-wide GitHub token access to read-only.
- Pinned third-party GitHub Actions to immutable commit SHAs.
- Added an unconditional static Terraform validation job so pull requests
  cannot appear healthy merely because deployment flags or secrets are absent.
- Kept deployment jobs explicitly scoped for the write and OIDC permissions
  they require.

## GitOps and DevSecOps operating rules

- Changes reach protected environments through pull requests and reviewed,
  reproducible plans.
- Applies consume the exact saved plan artifact; do not re-plan inside apply.
- Production-capable apply jobs must use GitHub/Azure DevOps environment
  approvals and short-lived OIDC credentials where supported.
- Secrets belong in GitHub Environments, Azure DevOps variable groups, or a
  managed secret store—never in `.tfvars`, workflow YAML, logs, or plan text.
- Update pinned action SHAs and provider constraints through reviewed dependency
  pull requests, then rerun format, validation, TFLint, and Trivy.
- Treat changes to `azure-template` as a separate module release with its own
  tests and security review before updating this landing zone.
