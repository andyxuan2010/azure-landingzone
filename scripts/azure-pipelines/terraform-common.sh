#!/usr/bin/env bash

set -euo pipefail

configure_terraform_ci() {
  export TF_IN_AUTOMATION=true
  export TF_INPUT=0
  export CHECKPOINT_DISABLE=true
  export GIT_TERMINAL_PROMPT=0
}

configure_azure_devops_git_auth() {
  local pat="${ADO_RUNNER_PAT:-}"
  local system_token="${SYSTEM_ACCESSTOKEN:-}"
  local auth_header=""
  [[ "${pat}" == \$\(* ]] && pat=""
  [[ "${system_token}" == \$\(* ]] && system_token=""
  if [[ -n "${pat}" ]]; then
    auth_header="AUTHORIZATION: basic $(printf 'azdo:%s' "${pat}" | base64 | tr -d '\n')"
  elif [[ -n "${system_token}" ]]; then
    auth_header="AUTHORIZATION: bearer ${system_token}"
  fi
  if [[ -n "${auth_header}" ]]; then
    # Pass credentials only to this process tree; never persist them on a shared runner.
    local config_index="${GIT_CONFIG_COUNT:-0}"
    export "GIT_CONFIG_KEY_${config_index}=http.https://dev.azure.com/.extraheader"
    export "GIT_CONFIG_VALUE_${config_index}=${auth_header}"
    export GIT_CONFIG_COUNT="$((config_index + 1))"
  fi
}

configure_module_source_for_environment() {
  local environment_name="${ENVIRONMENT:-}"
  case "${environment_name,,}" in
    dev|development)
      unset TF_VAR_module_repository TF_VAR_module_ref
      ;;
  esac
}

create_temp_tf_data_dir() {
  export TF_DATA_DIR
  TF_DATA_DIR="$(mktemp -d)"

  cleanup_tf_data_dir() {
    rm -rf "${TF_DATA_DIR}"
  }

  trap cleanup_tf_data_dir EXIT
}

configure_arm_auth() {
  export ARM_CLIENT_ID="${servicePrincipalId:?servicePrincipalId is required}"
  export ARM_TENANT_ID="${tenantId:?tenantId is required}"
  export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"

  if [[ -n "${servicePrincipalKey:-}" ]]; then
    export ARM_CLIENT_SECRET="${servicePrincipalKey}"
  fi

  if [[ -n "${idToken:-}" ]]; then
    export ARM_USE_OIDC=true
    export ARM_OIDC_TOKEN="${idToken}"
  fi

  if [[ -n "${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID:-}" ]]; then
    export ARM_OIDC_AZURE_SERVICE_CONNECTION_ID="${AZURESUBSCRIPTION_SERVICE_CONNECTION_ID}"
  fi
}

configure_terraform_ci
configure_azure_devops_git_auth
