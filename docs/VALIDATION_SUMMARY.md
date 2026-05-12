copy Repository Validation Summary

This file summarizes which modules have been hardened, validated, and documented during the current pass.

Status:
- appserviceplan: Hardened, validated, docs present (`VALIDATION_REPORT.md`, `MODULE_COMPLETE.md`, `QUICK_REFERENCE.md`).
- rg: Hardened, validated, docs present.
- adf: Hardened, validated, docs present.
- appregistration: README present for module usage and outputs.
- appservice: Hardened, validated, docs present.
- winvm: Hardened, `VALIDATION_REPORT.md` and `MODULE_COMPLETE.md` present. Diagnostics omitted due to provider compatibility.
- sqldb: Hardened, validated, docs present.
- sqlmi_db: Partially hardened (locals/outputs/docs added); variables/main updated — recommend running `terraform validate` in `modules/sqlmi_db` with required inputs to finalize.
- linuxvm: README present for module usage; expanded example/reference docs are still limited.
- automationaccount: Module docs present and updated for explicit private endpoint controls and managed identity role assignments.

Notes & recommended next actions:
- Normalize `azurerm` provider version across repo (pin in root) so diagnostics schema can be applied consistently.
- Run repository CI that executes `terraform init -reconfigure` and `terraform validate` for each module.
- Complete `sqlmi_db` validation by running `terraform validate` in that module and fixing any remaining variable or provider issues.
