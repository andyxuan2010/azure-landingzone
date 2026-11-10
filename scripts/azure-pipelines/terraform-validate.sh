#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/terraform-common.sh"
create_temp_tf_data_dir
configure_module_source_for_environment

terraform version
terraform fmt -check -recursive -diff
terraform init -backend=false -reconfigure -input=false -lockfile=readonly -no-color -var-file="${TERRAFORM_VAR_FILE:-environments/dev/terraform.tfvars}"
timeout 10m terraform validate -no-color
