#!/usr/bin/env bash

set -euo pipefail

terraform_version="${1:?terraform version is required}"
if [[ ! "${terraform_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Terraform version must be an explicit stable version (for example 1.15.8)." >&2
  exit 1
fi
os="linux"
arch="$(uname -m)"
install_root="${AGENT_TEMPDIRECTORY:-${RUNNER_TEMP:-/tmp}}/terraform-bin"

case "${arch}" in
  x86_64)
    arch="amd64"
    ;;
  aarch64|arm64)
    arch="arm64"
    ;;
  *)
    echo "Unsupported architecture: ${arch}" >&2
    exit 1
    ;;
esac

temp_dir="$(mktemp -d)"
trap 'rm -rf "${temp_dir}"' EXIT

archive="terraform_${terraform_version}_${os}_${arch}.zip"
zip_path="${temp_dir}/${archive}"
download_root="https://releases.hashicorp.com/terraform/${terraform_version}"

mkdir -p "${install_root}"
curl --proto '=https' --tlsv1.2 -fsSL "${download_root}/${archive}" -o "${zip_path}"
curl --proto '=https' --tlsv1.2 -fsSL "${download_root}/terraform_${terraform_version}_SHA256SUMS" -o "${temp_dir}/SHA256SUMS"
awk -v archive="${archive}" '$2 == archive { print; found=1 } END { if (!found) exit 1 }' "${temp_dir}/SHA256SUMS" > "${temp_dir}/archive.sha256"
(cd "${temp_dir}" && sha256sum -c archive.sha256)
unzip -oq "${zip_path}" -d "${temp_dir}"
install -m 0755 "${temp_dir}/terraform" "${install_root}/terraform"

echo "##vso[task.prependpath]${install_root}"

"${install_root}/terraform" version
