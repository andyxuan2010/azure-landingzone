Template Repo — Modules Guide

Purpose
- Provide repository-level guidance for using, validating, and contributing Terraform modules in this template repository.
- Use [MODULE_USAGE_AND_DEPENDENCIES.md](./MODULE_USAGE_AND_DEPENDENCIES.md) for the current module-by-module dependency map, usage guidance, and example entry points.
- Use [ROOT_LEVEL_MODULES_GUIDE.md](./ROOT_LEVEL_MODULES_GUIDE.md) for root `main.tf` wiring order, dependencies, and example `terraform.tfvars` values.

Module standards applied
- Validation: modules should include strong `variable` validation blocks and local cross-checks where applicable.
- Tagging: modules should merge environment defaults, managed metadata and `var.tags` into `local.merged_tags`.
- Diagnostics: modules may expose `enable_diagnostics` and `log_analytics_workspace`/`workspace_id` inputs and create `azurerm_monitor_diagnostic_setting` when compatible with the provider version. Where provider compatibility is uncertain, diagnostics are documented but not applied automatically.
- Outputs: modules should export `merged_tags` and a diagnostics flag (e.g. `diagnostics_enabled`) in addition to resource-specific outputs.
- Docs: every module should contain `README.md`, `QUICK_REFERENCE.md`, `EXAMPLES.md`, `VALIDATION_REPORT.md`, and `MODULE_COMPLETE.md` when hardened.

How to validate a module locally
1. Change into the module folder:

```powershell
cd "..\modules\<module>"
```
2. Initialize providers:

```powershell
terraform init -reconfigure
```
3. Validate configuration:

```powershell
terraform validate
```
4. (Optional) Run `terraform plan` with required variables and a backend configured.

Repository-level CI recommendations
- Run `terraform validate` for each module during PR CI.
- Use a pinned `azurerm` provider version in root `required_providers` or lockfile to maintain consistent schema for diagnostics.
- If adding diagnostics automation, include a compatibility test matrix for `azurerm` provider versions.

Diagnostics guidance
- When adding `azurerm_monitor_diagnostic_setting`, ensure block names (`log`, `metric` vs `logs`, `metrics`) match the `azurerm` provider version in use.
- Prefer adding diagnostic settings in a module only when `log_analytics_workspace_id` is provided; otherwise document how to add them externally.

Contribution checklist for new modules
- Add `variables.tf` with validations
- Add `locals.tf` with `local.merged_tags`
- Use `local.merged_tags` on all resources
- Add `outputs.tf` exporting `merged_tags` and diagnostics flag
- Add `README.md`, `QUICK_REFERENCE.md`, `EXAMPLES.md`, `VALIDATION_REPORT.md`, `MODULE_COMPLETE.md`
- Add Terraform CI job to run `terraform init` and `terraform validate` on the module

Next steps I can take
- Generate missing module docs automatically for modules lacking them, or
- Add a repo-level GitHub Action workflow that runs `terraform validate` across modules.
