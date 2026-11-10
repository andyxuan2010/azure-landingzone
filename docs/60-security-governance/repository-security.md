# Repository security controls

The root composition consumes shared modules at commit `2e0d476c1e80c327162ff59147bff16454e4af3d`. Review upstream changes before replacing every module pin together. Commit `.terraform.lock.hcl`; normal CI initialization uses `-lockfile=readonly`. Run `terraform init -upgrade -backend=false` only for an intentional provider update, then review the lockfile and validate before committing.

## Network boundaries

- `trusted_ingress_ipv4_cidrs` supplies the workload NSG's HTTPS and SSH source ranges. An empty list removes those explicit allow rules. Existing east-west VNet rules and Azure's default NSG rules remain in effect.
- `shared_data_public_network_access_enabled` defaults to `false` for the shared storage account and Key Vault. Both resources enable network controls with default action `Deny`.
- `shared_data_allowed_ipv4_cidrs` supplies approved public client addresses. Empty permits no explicit public client. The upstream trusted Azure service bypass remains enabled; it does not authorize arbitrary Azure workloads.
- Checked-in environment examples enable public endpoints for the single address previously used by the workload NSG. Review and replace this address with approved administrator and runner egress addresses before applying. Storage expects individual addresses rather than `/31` or `/32` ranges.
- Shared storage and Key Vault private endpoints are currently disabled in this root composition. A runner outside the allowlist cannot perform their data-plane operations. GitHub-hosted runner egress is not automatically added. Use approved fixed egress or add private connectivity before rollout.
- Linux VMs default to SSH key authentication. The post-init script disables password, keyboard-interactive, and direct root SSH login. Validate the administrator SSH key and recovery access before deploying this change.
- FortiGate SSH source inputs accept IPv4 addresses or CIDRs and reject the unrestricted `/0` prefix.

These controls require a real environment plan and connectivity verification before apply. Terraform validation alone cannot establish that the runner can reach Azure data-plane endpoints.

## CI and credentials

Pull requests run static Terraform checks and repository quality checks without Azure deployment credentials. Authenticated plan jobs run on trusted non-PR events and depend on static validation. Apply jobs consume their saved plan artifacts. GitHub plan artifacts are retained for one day; treat plans, plan JSON, and state as sensitive material.

GitHub Actions are pinned to commit SHAs. The Azure DevOps Terraform installer verifies the downloaded archive against HashiCorp's published SHA-256 checksum file over HTTPS. This verifies archive integrity; the script does not independently verify the checksum file's release signature.

Azure DevOps module authentication is passed through process-scoped Git configuration rather than written to a runner's global Git configuration. GitHub jobs no longer require the obsolete Azure DevOps module-download PAT or unused sibling template checkout. Runner hygiene logs list authentication key names without printing credential values.

Keep credentials in GitHub Environments, Azure DevOps secret variables, or Key Vault. `.env` variants, Terraform state/plans, Key Vault backup blobs, and desktop metadata are ignored. Before publishing, scan tracked and newly staged content; ignore rules do not remove secrets already committed in history.

## Helpers and generated content

`scripts/copykv.ps1` requires explicit source and target vaults, rejects copying a vault onto itself, supports `-WhatIf`, and fails if any item fails. Key backups remain in the chosen backup folder; restrict access and remove them according to your retention policy.

The documentation builder permits only direct child output directories named `_site` or `_site-<name>` and rejects output links/junctions. Markdown URLs allow only relative links and explicit HTTP(S), mail, or telephone schemes. Generated-page validation checks local link targets.

Static demo sites share framing, content-type, referrer, permissions, and content-security headers. Existing inline scripts and styles require CSP `unsafe-inline`; external images and Google Fonts remain allowed. Removing inline code and narrowing image origins is future hardening, not a claim of strict CSP enforcement.

## Verification

Run `./test.ps1 -InitializeTerraform`, then build and test the documentation portal. Run TFLint and Trivy separately as described in the [code standards](code-standards.md). See the [validation record](../70-validation/validation-summary.md) for the checks actually completed and their limitations.

Provider lockfile guidance: [HashiCorp dependency lockfile](https://developer.hashicorp.com/terraform/language/files/dependency-lock). Workflow pinning guidance: [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use).

Azure network behavior: [Storage firewall rules](https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security) and [Key Vault network security](https://learn.microsoft.com/en-us/azure/key-vault/general/network-security).
