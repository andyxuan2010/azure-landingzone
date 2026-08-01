#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/terraform-common.sh"
create_temp_tf_data_dir

terraform version
if ! terraform fmt -check -recursive; then
  echo "##vso[task.logissue type=warning]Terraform formatting drift detected. Running terraform fmt -recursive and continuing."
  terraform fmt -recursive || echo "##vso[task.logissue type=warning]terraform fmt -recursive failed; continuing so terraform validate can report any real syntax issues."
fi
terraform init -backend=false -reconfigure -input=false -no-color
timeout 10m terraform validate -no-color
