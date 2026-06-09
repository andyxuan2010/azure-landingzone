#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log/localization"
LOG_FILE="${LOG_DIR}/localization-redhat.log"

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"
chmod 0600 "${LOG_FILE}" || true
exec >>"${LOG_FILE}" 2>&1

export PS4='[$(date -u "+%Y-%m-%dT%H:%M:%SZ")] [TRACE] '
set -x

log() {
  printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*"
}

pkg_is_busy() {
  if command -v fuser >/dev/null 2>&1; then
    fuser /var/lib/rpm/.rpm.lock /var/cache/dnf/metadata_lock.pid /var/run/yum.pid >/dev/null 2>&1
    return $?
  fi

  pgrep -x dnf >/dev/null 2>&1 || \
  pgrep -x yum >/dev/null 2>&1 || \
  pgrep -x rpm >/dev/null 2>&1 || \
  pgrep -f packagekit >/dev/null 2>&1
}

wait_for_pkg_manager() {
  local waited=0
  local timeout=240
  local interval=5

  while pkg_is_busy; do
    if [ "${waited}" -ge "${timeout}" ]; then
      log "Timed out after ${timeout}s waiting for the package manager to become available"
      return 1
    fi

    log "Another package manager process is running; waiting ${interval}s (${waited}/${timeout}s)"
    sleep "${interval}"
    waited=$((waited + interval))
  done

  log "Package manager is available"
}

pkg_update_safe() {
  wait_for_pkg_manager

  if command -v dnf >/dev/null 2>&1; then
    log "Running dnf makecache"
    dnf makecache -y
    return 0
  fi

  if command -v yum >/dev/null 2>&1; then
    log "Running yum makecache"
    yum makecache -y
    return 0
  fi

  log "Neither dnf nor yum is available"
  return 1
}

pkg_upgrade_safe() {
  wait_for_pkg_manager

  if command -v dnf >/dev/null 2>&1; then
    log "Running dnf upgrade"
    dnf upgrade -y
    return 0
  fi

  if command -v yum >/dev/null 2>&1; then
    log "Running yum update"
    yum update -y
    return 0
  fi

  log "Neither dnf nor yum is available"
  return 1
}
apt_upgrade_safe() {
  wait_for_apt
  log "Running apt-get upgrade"
  apt-get upgrade -y
}

pkg_install_safe() {
  wait_for_pkg_manager

  if command -v dnf >/dev/null 2>&1; then
    log "Installing packages with dnf: $*"
    dnf install -y "$@"
    return 0
  fi

  if command -v yum >/dev/null 2>&1; then
    log "Installing packages with yum: $*"
    yum install -y "$@"
    return 0
  fi

  log "Neither dnf nor yum is available"
  return 1
}

echo "===== Red Hat localization start ====="
date -u

export DEBIAN_FRONTEND=noninteractive

if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
  pkg_update_safe
  pkg_upgrade_safe
  #pkg_install_safe ca-certificates curl jq unzip
fi

timedatectl set-timezone America/Toronto || true

mkdir -p /opt/localization /opt/bootstrap
cat >/etc/motd <<'EOF'
This VM was configured by the Linux VM localization extension.
EOF

echo "Red Hat localization baseline completed" >/opt/localization/redhat-baseline.txt

echo "===== Red Hat localization complete ====="
date -u
