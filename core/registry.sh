# core/registry.sh — module registration (bash)
# shellcheck shell=bash

# -g: survive when this file is sourced from main_load() (function scope in bash).
declare -ag MACCTL_MODULES

# Each module calls this after defining <name>_get_desired, _get_current, _install.
register_module() {
  local name="$1"
  local existing
  for existing in "${MACCTL_MODULES[@]}"; do
    [[ "$existing" == "$name" ]] && return 0
  done
  local fn
  for fn in "${name}_get_desired" "${name}_get_current" "${name}_install"; do
    if ! declare -f "$fn" &>/dev/null; then
      log_error "Module '${name}' is missing required function: ${fn}"
      return 1
    fi
  done
  MACCTL_MODULES+=("$name")
}

list_modules() {
  printf '%s\n' "${MACCTL_MODULES[@]}"
}
