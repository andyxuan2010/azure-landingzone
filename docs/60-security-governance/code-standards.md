# Code standards

This repository composes Azure landing-zone modules. Shared module implementations and module harnesses belong in the upstream template repository.

## Terraform

- Use Terraform `>= 1.9, < 2.0`; the tested CLI is pinned in `.terraform-version` and GitHub Actions. Keep Azure DevOps `TERRAFORM_VERSION` aligned with that file.
- Declare provider sources and compatible major-version constraints in `versions.tf`. Commit the root `.terraform.lock.hcl` and review intentional upgrades.
- Pin remote module sources to an immutable commit. Update the module pins together, then validate the root against that exact revision.
- Use `snake_case` Terraform identifiers, explicit input types, useful descriptions, and validation for security-sensitive or constrained inputs. Mark secrets sensitive and provide them through secret stores.
- Keep composition in `main.tf`, provider configuration in `providers.tf`, shared inputs in `variables.tf`, network security inputs in `security-inputs.tf`, derived values in `locals.tf`, and outputs in `outputs.tf`.
- Prefer module outputs to hard-coded resource IDs. Preserve resource addresses when reorganizing code; use reviewed moved blocks for necessary address changes.
- Root code owns enterprise tag normalization. Pass plan-known tags using the [tagging contract](tagging-contract.md).
- Run `terraform fmt -check -recursive -diff`. CI fails on formatting drift and must not silently rewrite it.
- Use the environment-specific Azure backend file. Plans and state are sensitive; never commit them or backend credentials.

## Scripts and pipelines

Use strict error handling (`set -euo pipefail` or PowerShell terminating errors), check native exit codes, and propagate failures. Avoid command tracing around credentials. Scripts that write to Azure should require explicit targets and support a review mode where practical.

Use UTF-8 source files, LF line endings, and a final newline, as specified by `.editorconfig` and `.gitattributes`. Keep executable Bash scripts compatible with Linux runners. Do not store runner credentials in persistent global Git configuration.

Pin GitHub Actions by full commit SHA, minimize token permissions, and keep authenticated Terraform execution out of pull request jobs. Static validation must run without deployment flags or Azure credentials. Environment approvals and OIDC are configured by repository and platform administrators; source code cannot verify those external settings.

## Local validation

Use PowerShell 7, Node.js, Terraform, and Git for the repository checks. TFLint, Trivy, and terraform-docs are separate tools; PDF exports additionally require Python and ReportLab.

```powershell
./test.ps1 -InitializeTerraform
./scripts/Build-DocsSite.ps1
./scripts/Test-DocsSite.ps1
terraform-docs --config .terraform-docs.yml .
tflint --init
tflint --format=compact --minimum-failure-severity=error
trivy config --misconfig-scanners terraform --severity HIGH,CRITICAL --exit-code 1 --tf-vars environments/dev/terraform.tfvars .
```

`./test.ps1 -SkipTerraform` runs only script syntax, Markdown links, and static-site checks. The previous module-directory test harness has been replaced because this repository has no local `modules/` directory. Use the upstream repository for module tests.

Regenerate the [Terraform reference](../80-reference/terraform-reference.md) after changing inputs, outputs, or provider constraints. Keep the docs map, deployment instructions, security controls, validation record, and [change log](../../CHANGELOG.md) consistent with the code. Run `python scripts/Export-DocsPdf.py` with ReportLab installed to refresh maintained PDF snapshots under `output/pdf/`, then copy them to their existing repository paths. The validation record identifies which PDFs were refreshed.

See [repository security controls](repository-security.md) for network rollout requirements, credential handling, script behavior, and remaining limitations.
