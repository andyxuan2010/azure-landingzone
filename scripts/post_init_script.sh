#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/localization"
LOG_FILE="${LOG_DIR}/post-init.log"

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"
chmod 0600 "${LOG_FILE}" || true
exec >>"${LOG_FILE}" 2>&1

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >&2
}

apt_is_busy() {
  if command -v fuser >/dev/null 2>&1; then
    fuser /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock >/dev/null 2>&1
    return $?
  fi

  pgrep -x apt >/dev/null 2>&1 || \
  pgrep -x apt-get >/dev/null 2>&1 || \
  pgrep -x dpkg >/dev/null 2>&1 || \
  pgrep -f unattended-upgrade >/dev/null 2>&1
}

wait_for_apt() {
  local waited=0
  local timeout=240
  local interval=5

  while apt_is_busy; do
    if [ "${waited}" -ge "${timeout}" ]; then
      log "Timed out after ${timeout}s waiting for apt/dpkg to become available"
      return 1
    fi

    log "Another apt/dpkg process is running; waiting ${interval}s (${waited}/${timeout}s)"
    sleep "${interval}"
    waited=$((waited + interval))
  done

  log "apt/dpkg is available"
}

apt_update_safe() {
  wait_for_apt
  log "Running apt-get update"
  apt-get update -y
}

apt_install_safe() {
  wait_for_apt
  log "Installing packages: $*"
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}
apt_upgrade_safe() {
  wait_for_apt
  log "Running apt-get upgrade"
  apt-get upgrade -y
}

install_powershell_support() {
  local os_id=""
  local version_id=""
  local repo_package=""
  local repo_package_path=""

  if command -v pwsh >/dev/null 2>&1; then
    log "PowerShell is already installed; skipping package setup"
    return 0
  fi

  if [ ! -r /etc/os-release ]; then
    log "Cannot install PowerShell because /etc/os-release is unavailable"
    return 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  version_id="${VERSION_ID:-}"

  if [ "${os_id}" != "ubuntu" ] || [ -z "${version_id}" ]; then
    log "PowerShell installation is only configured for Ubuntu; detected ID=${os_id:-unknown} VERSION_ID=${version_id:-unknown}"
    return 1
  fi

  repo_package="packages-microsoft-prod.deb"
  repo_package_path="$(mktemp "/tmp/${repo_package}.XXXXXX")"

  log "Installing Microsoft package repository for Ubuntu ${version_id}"
  apt_install_safe ca-certificates curl
  curl -fSL "https://packages.microsoft.com/config/ubuntu/${version_id}/${repo_package}" -o "${repo_package_path}"
  dpkg -i "${repo_package_path}"
  rm -f "${repo_package_path}"

  apt_update_safe
  apt_install_safe powershell
}

expire_root_password_on_first_logon() {
  local root_password_marker=""

  root_password_marker="$(getent shadow root | cut -d: -f2)"

  if [ -z "${root_password_marker}" ] || [ "${root_password_marker}" = "!" ] || [ "${root_password_marker}" = "*" ]; then
    log "Root account does not have an interactive password configured; skipping password expiry"
    return 0
  fi

  log "Expiring root password so it must be changed at first logon"
  chage -d 0 root
}

configure_sshd_authentication() {
  local sshd_drop_in_dir="/etc/ssh/sshd_config.d"
  local sshd_drop_in_file="${sshd_drop_in_dir}/60-ado-auth.conf"
  local ssh_service_name=""

  mkdir -p "${sshd_drop_in_dir}"

  cat > "${sshd_drop_in_file}" <<'EOF'
# Keep both public key and password authentication available.
# OpenSSH server does not support a true server-side "preferred auth order"
# equivalent to the client-side PreferredAuthentications option, so this
# configuration ensures public key auth is enabled while preserving passwords.
PubkeyAuthentication yes
PasswordAuthentication yes
EOF

  if command -v sshd >/dev/null 2>&1; then
    log "Validating sshd configuration"
    sshd -t
  fi

  if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
    ssh_service_name="ssh"
  elif systemctl list-unit-files sshd.service >/dev/null 2>&1; then
    ssh_service_name="sshd"
  else
    log "No ssh service unit was found; skipping ssh service enablement"
    return 0
  fi

  log "Enabling and restarting ${ssh_service_name} service"
  systemctl enable "${ssh_service_name}"
  systemctl restart "${ssh_service_name}"
}

install_azure_cli_support() {
  local os_id=""
  local version_id=""
  local repo_package=""
  local repo_package_path=""

  if command -v az >/dev/null 2>&1; then
    log "Azure CLI is already installed; skipping package setup"
    return 0
  fi

  if [ ! -r /etc/os-release ]; then
    log "Cannot install Azure CLI because /etc/os-release is unavailable"
    return 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  version_id="${VERSION_ID:-}"

  if [ "${os_id}" != "ubuntu" ] || [ -z "${version_id}" ]; then
    log "Azure CLI installation is only configured for Ubuntu; detected ID=${os_id:-unknown} VERSION_ID=${version_id:-unknown}"
    return 1
  fi

  repo_package="packages-microsoft-prod.deb"
  repo_package_path="$(mktemp "/tmp/${repo_package}.XXXXXX")"

  log "Installing Microsoft package repository for Azure CLI on Ubuntu ${version_id}"
  apt_install_safe ca-certificates curl
  curl -fSL "https://packages.microsoft.com/config/ubuntu/${version_id}/${repo_package}" -o "${repo_package_path}"
  dpkg -i "${repo_package_path}"
  rm -f "${repo_package_path}"

  apt_update_safe
  apt_install_safe azure-cli
}

resolve_agent_version() {
  local latest_tag=""

  if [ -n "${AGENT_VERSION:-}" ]; then
    printf '%s' "${AGENT_VERSION}"
    return 0
  fi

  latest_tag="$(curl -fsSL "https://api.github.com/repos/microsoft/azure-pipelines-agent/releases/latest" | jq -r '.tag_name')"
  latest_tag="${latest_tag#v}"

  if [ -z "${latest_tag}" ] || [ "${latest_tag}" = "null" ]; then
    log "Unable to determine latest Azure DevOps agent version from GitHub releases"
    return 1
  fi

  log "Resolved latest Azure DevOps agent version ${latest_tag}"
  printf '%s' "${latest_tag}"
}

get_key_vault_token() {
  local response
  local access_token

  response="$(curl -fsSL -H Metadata:true --noproxy "*" \
    "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net")"
  access_token="$(printf '%s' "${response}" | jq -r '.access_token')"

  if [ -z "${access_token}" ] || [ "${access_token}" = "null" ]; then
    log "Unable to acquire managed identity token for Key Vault"
    return 1
  fi

  printf '%s' "${access_token}"
}

get_key_vault_secret() {
  local vault_name="$1"
  local secret_name="$2"
  local access_token="$3"
  local response
  local secret_value

  response="$(curl -fsSL \
    -H "Authorization: Bearer ${access_token}" \
    "https://${vault_name}.vault.azure.net/secrets/${secret_name}?api-version=7.4")"
  secret_value="$(printf '%s' "${response}" | jq -r '.value')"

  if [ -z "${secret_value}" ] || [ "${secret_value}" = "null" ]; then
    log "Secret ${secret_name} in Key Vault ${vault_name} was empty or unreadable"
    return 1
  fi

  printf '%s' "${secret_value}"
}

get_key_vault_secret_with_az() {
  local vault_name="$1"
  local secret_name="$2"
  local secret_value=""

  if ! command -v az >/dev/null 2>&1; then
    log "Azure CLI is unavailable; cannot fetch ${secret_name} from Key Vault ${vault_name} with az"
    return 1
  fi

  log "Authenticating Azure CLI with managed identity"
  az login --identity --allow-no-subscriptions --only-show-errors >/dev/null

  log "Retrieving ${secret_name} from Key Vault ${vault_name} with Azure CLI"
  secret_value="$(az keyvault secret show \
    --name "${secret_name}" \
    --vault-name "${vault_name}" \
    --query value \
    --output tsv \
    --only-show-errors)"

  if [ -z "${secret_value}" ] || [ "${secret_value}" = "null" ]; then
    log "Secret ${secret_name} in Key Vault ${vault_name} was empty or unreadable through Azure CLI"
    az account clear >/dev/null 2>&1 || true
    return 1
  fi

  # Limit managed identity usage to the Key Vault read, then clear the CLI context.
  az account clear >/dev/null 2>&1 || true
  printf '%s' "${secret_value}"
}

resolve_ado_pat() {
  local kv_access_token=""
  local az_secret_name=""
  local az_vault_name=""

  if [ -n "${ADO_PAT:-}" ]; then
    printf '%s' "${ADO_PAT}"
    return 0
  fi

  az_secret_name="${ADO_PAT_SECRET_NAME:-AZURE-DEVOPS-PAT}"
  az_vault_name="${ADO_PAT_KEY_VAULT_NAME:-${IAC_KEY_VAULT_NAME:-kvplatformeusdev}}"

  if ADO_PAT="$(get_key_vault_secret_with_az "${az_vault_name}" "${az_secret_name}" 2>/dev/null)"; then
    log "Retrieved Azure DevOps runner PAT from Key Vault ${az_vault_name} secret ${az_secret_name} using Azure CLI"
    printf '%s' "${ADO_PAT}"
    return 0
  fi

  log "Azure CLI managed-identity lookup did not return ${az_secret_name} from Key Vault ${az_vault_name}; falling back to direct REST lookups"
  kv_access_token="$(get_key_vault_token)"

  if ADO_PAT="$(get_key_vault_secret "${az_vault_name}" "${az_secret_name}" "${kv_access_token}" 2>/dev/null)"; then
    log "Retrieved Azure DevOps runner PAT from Key Vault ${az_vault_name} secret ${az_secret_name} using direct Key Vault REST"
    printf '%s' "${ADO_PAT}"
    return 0
  fi

  log "Unable to retrieve Azure DevOps runner PAT from Key Vault ${az_vault_name} secret ${az_secret_name}"
  return 1
}

validate_ado_pat() {
  local ado_url="$1"
  local ado_pat="$2"

  log "Validating Azure DevOps PAT against ${ado_url}"
  curl -fsS -u ":${ado_pat}" \
    "${ado_url}/_apis/connectionData?api-version=7.1-preview.1" \
    >/dev/null
}

ensure_runner_user() {
  if id -u "${ADO_RUNNER_USER}" >/dev/null 2>&1; then
    log "Runner user ${ADO_RUNNER_USER} already exists"
    return 0
  fi

  log "Creating runner user ${ADO_RUNNER_USER}"
  useradd --create-home --shell /bin/bash "${ADO_RUNNER_USER}"
}

ensure_runner_directories() {
  mkdir -p "${RUNNER_BASE_DIR}" "${AGENT_DIR}" "${ADO_WORK_DIR}"
  chown -R "${ADO_RUNNER_USER}:${ADO_RUNNER_USER}" "${RUNNER_BASE_DIR}"
  chmod 0755 "${RUNNER_BASE_DIR}"
}

ensure_runner_count_is_valid() {
  if ! [[ "${ADO_RUNNER_COUNT}" =~ ^[0-9]+$ ]] || [ "${ADO_RUNNER_COUNT}" -lt 1 ]; then
    log "ADO_RUNNER_COUNT must be a positive integer; received '${ADO_RUNNER_COUNT}'"
    return 1
  fi
}

install_agent_package() {
  ensure_runner_directories

  if [ -x "${AGENT_DIR}/config.sh" ]; then
    log "Azure DevOps agent files already exist in ${AGENT_DIR}; skipping download"
    chown -R "${ADO_RUNNER_USER}:${ADO_RUNNER_USER}" "${RUNNER_BASE_DIR}"
    return 0
  fi

  cd "${AGENT_DIR}"

  log "Downloading Azure DevOps agent ${AGENT_VERSION}"
  curl -fSL "${AGENT_DOWNLOAD_BASE}/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz" -o agent.tar.gz
  tar -xzf agent.tar.gz
  rm -f agent.tar.gz

  if [ -x "${AGENT_DIR}/bin/installdependencies.sh" ]; then
    log "Installing Azure DevOps agent runtime dependencies"
    "${AGENT_DIR}/bin/installdependencies.sh"
  fi

  chown -R "${ADO_RUNNER_USER}:${ADO_RUNNER_USER}" "${AGENT_DIR}" "${ADO_WORK_DIR}"
}

configure_agent() {
  if [ -f "${AGENT_DIR}/.agent" ]; then
    log "Azure DevOps agent is already configured; skipping registration"
    return 0
  fi

  log "Configuring Azure DevOps agent ${ADO_AGENT_NAME} in pool ${ADO_POOL}"
  runuser -u "${ADO_RUNNER_USER}" -- env \
    AGENT_ALLOW_RUNASROOT=0 \
    AGENT_DIR="${AGENT_DIR}" \
    ADO_AGENT_NAME="${ADO_AGENT_NAME}" \
    ADO_URL="${ADO_URL}" \
    ADO_PAT_VALUE="${ADO_PAT_VALUE}" \
    ADO_POOL="${ADO_POOL}" \
    ADO_WORK_DIR="${ADO_WORK_DIR}" \
    bash -lc 'cd "$AGENT_DIR" && ./config.sh --unattended --agent "$ADO_AGENT_NAME" --url "$ADO_URL" --auth pat --token "$ADO_PAT_VALUE" --pool "$ADO_POOL" --work "$ADO_WORK_DIR" --replace --acceptTeeEula'
}

install_and_start_service() {
  local service_name=""

  cd "${AGENT_DIR}"

  if [ -f "${AGENT_DIR}/.service" ]; then
    service_name="$(cat "${AGENT_DIR}/.service")"
    log "Azure DevOps service ${service_name} already installed"
  else
    log "Installing Azure DevOps service for ${ADO_RUNNER_USER}"
    ./svc.sh install "${ADO_RUNNER_USER}"
    service_name="$(cat "${AGENT_DIR}/.service")"
  fi

  log "Enabling and starting ${service_name}"
  systemctl enable "${service_name}"
  systemctl restart "${service_name}"
}

install_ado_runner() {
  ADO_URL="${ADO_URL:-https://dev.azure.com/CCOE-Azure}"
  ADO_POOL="${ADO_POOL:-IaCRunner}"
  ADO_AGENT_NAME_PREFIX="${ADO_AGENT_NAME_PREFIX:-${ADO_AGENT_NAME:-$(hostname)}}"
  ADO_RUNNER_COUNT="${ADO_RUNNER_COUNT:-1}"
  ADO_RUNNER_USER="${ADO_RUNNER_USER:-ado}"
  AGENT_DOWNLOAD_BASE="${AGENT_DOWNLOAD_BASE:-https://download.agent.dev.azure.com/agent}"
  RUNNER_BASE_DIR="${RUNNER_BASE_DIR:-/opt/ado-runner}"
  AGENT_ROOT_DIR="${AGENT_ROOT_DIR:-${RUNNER_BASE_DIR}/agents}"
  WORK_ROOT_DIR="${WORK_ROOT_DIR:-${RUNNER_BASE_DIR}/work}"
  IAC_KEY_VAULT_NAME="${IAC_KEY_VAULT_NAME:-}"
  ADO_PAT_KEY_VAULT_NAME="${ADO_PAT_KEY_VAULT_NAME:-${IAC_KEY_VAULT_NAME:-kvplatformeusdev}}"
  ADO_PAT_SECRET_NAME="${ADO_PAT_SECRET_NAME:-AZURE-DEVOPS-PAT}"

  log "Installing ADO runner prerequisites"
  apt_install_safe ca-certificates curl jq libicu74
  install_azure_cli_support
  install_powershell_support

  ensure_runner_user
  ensure_runner_count_is_valid
  AGENT_VERSION="$(resolve_agent_version)"
  ADO_PAT_VALUE="$(resolve_ado_pat)"
  validate_ado_pat "${ADO_URL}" "${ADO_PAT_VALUE}"

  local runner_index=""
  for runner_index in $(seq 1 "${ADO_RUNNER_COUNT}"); do
    ADO_AGENT_NAME="${ADO_AGENT_NAME_PREFIX}-${runner_index}"
    AGENT_DIR="${AGENT_ROOT_DIR}/${ADO_AGENT_NAME}"
    ADO_WORK_DIR="${WORK_ROOT_DIR}/${ADO_AGENT_NAME}"

    log "Preparing Azure DevOps agent ${ADO_AGENT_NAME} (${runner_index}/${ADO_RUNNER_COUNT})"
    ensure_runner_directories
    install_agent_package
    configure_agent
    install_and_start_service
  done
}

trap 'rc=$?; log "ERROR: script failed at line ${LINENO} with exit code ${rc}"; exit ${rc}' ERR

log "custom post-init script started"
mkdir -p /opt/bootstrap
touch /opt/bootstrap/post-init-ran
cat /etc/os-release

install_ado_runner
configure_sshd_authentication
expire_root_password_on_first_logon

apt_update_safe
apt_upgrade_safe


timedatectl set-timezone America/Toronto || true
