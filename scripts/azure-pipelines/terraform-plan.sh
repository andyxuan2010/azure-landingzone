#!/usr/bin/env bash

set -euo pipefail

backend_resource_group_name="${1:?backend resource group name is required}"
backend_storage_account_name="${2:?backend storage account name is required}"
backend_container_name="${3:?backend container name is required}"
backend_key="${4:?backend key is required}"
var_file="${5:?variable file path is required}"
plan_file="${6:?plan file path is required}"
plan_text_file="${7:?plan text file path is required}"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/terraform-common.sh"
configure_module_source_for_environment
configure_arm_auth

mkdir -p "$(dirname "${plan_file}")"
mkdir -p "$(dirname "${plan_text_file}")"

terraform version
terraform init \
  -reconfigure \
  -lockfile=readonly \
  -input=false \
  -no-color \
  -var-file="${var_file}" \
  -backend-config="resource_group_name=${backend_resource_group_name}" \
  -backend-config="storage_account_name=${backend_storage_account_name}" \
  -backend-config="container_name=${backend_container_name}" \
  -backend-config="key=${backend_key}"
terraform plan -input=false -no-color -var-file="${var_file}" -out="${plan_file}"
terraform show -no-color "${plan_file}" > "${plan_text_file}"
summary_text="$(bash "${script_dir}/../terraform-change-summary.sh" "${plan_file}" "Terraform plan summary")"
printf '%s\n' "${summary_text}"

summary_file="$(dirname "${plan_text_file}")/terraform-plan-summary.md"
{
  printf '## Terraform plan summary\n\n'
  printf '```text\n'
  printf '%s\n' "${summary_text}"
  printf '```\n'
} > "${summary_file}"
echo "##vso[task.uploadsummary]${summary_file}"
