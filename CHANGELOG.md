# Change log

## 2026-10-29 — Repository rescan and hardening

- Reviewed the root Terraform composition, three environment configurations, GitHub Actions, Azure DevOps pipeline/helpers, PowerShell and Bash utilities, documentation portal, and static demo content.
- Pinned shared modules to upstream commit `2e0d476c1e80c327162ff59147bff16454e4af3d`, bounded Terraform/provider compatibility, committed provider locking, aligned the tested CLI version, and corrected the Terraform documentation generator's output path.
- Replaced hard-coded workload ingress addresses with validated environment allowlists. Enabled deny-by-default network ACLs for shared storage and Key Vault. Disabled Linux password/root SSH login in the bootstrap defaults and rejected unrestricted FortiGate SSH source CIDRs.
- Required static validation before credentialed Terraform plans, excluded pull request events from authenticated plans, shortened saved-plan retention, pinned the Static Web Apps actions, and added credential-free repository quality checks.
- Added Terraform installer checksum verification, process-scoped Azure DevOps Git authentication, fail-closed formatting checks, explicit Key Vault copy targets, review mode, partial-failure reporting, and removal of credential values from runner hygiene logs.
- Restricted documentation output cleanup, filtered unsafe Markdown URL schemes, validated generated local links, repaired stale documentation references, and replaced the obsolete local module test entry point.
- Standardized source encoding/line endings and demo-site response headers; added script, documentation, static-site, and security regression checks.
- Preserved the existing one-site Dev deployment changes and reviewed the additional local demo/reference sites. Source content is retained; reference archives and desktop metadata remain local.
- Updated contributor, pipeline, deployment, security, resource, and generated Terraform documentation. Validation evidence and rollout limits are recorded in [the validation summary](docs/70-validation/validation-summary.md).

No Terraform apply or Azure resource modification was performed during this review. The new data-plane allowlists and SSH settings require connectivity and administrator-access verification before deployment. README, architecture, Terraform-reference, and validation-summary PDF snapshots were regenerated from their maintained Markdown sources.
