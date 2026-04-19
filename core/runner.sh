# core/runner.sh — plan / apply reconciliation loop (bash)
# shellcheck shell=bash

module_selected() {
  local m="$1"
  [[ -z "${MACCTL_ONLY:-}" ]] && return 0
  case ",${MACCTL_ONLY}," in
    *",${m},"*) return 0 ;;
    *) return 1 ;;
  esac
}

run_plan() {
  export MACCTL_DRY_RUN MACCTL_ONLY
  local _mod tmp_d tmp_c miss
  log_info "plan: starting (${#MACCTL_MODULES[@]} module(s); only='${MACCTL_ONLY:-all}')"
  for _mod in "${MACCTL_MODULES[@]}"; do
    module_selected "$_mod" || continue
    log_progress "plan: [${_mod}] reading desired state..."
    tmp_d=$(mktemp)
    tmp_c=$(mktemp)
    trap 'rm -f "$tmp_d" "$tmp_c"' RETURN
    "${_mod}_get_desired" >"$tmp_d" 2>/dev/null || true
    log_progress "plan: [${_mod}] scanning what is installed (may take a while)..."
    "${_mod}_get_current" >"$tmp_c" 2>/dev/null || true
    log_progress "plan: [${_mod}] computing diff..."
    miss=$(diff_lists "$tmp_d" "$tmp_c")
    if [[ -z "$miss" ]]; then
      log_info "plan: module '${_mod}' - nothing to do"
    else
      log_info "plan: module '${_mod}' - would apply:"
      echo "$miss" | sed 's/^/  + /' >&2
    fi
    rm -f "$tmp_d" "$tmp_c"
    trap - RETURN
  done
  log_info "plan: finished all modules"
}

run_apply() {
  export MACCTL_DRY_RUN MACCTL_ONLY
  local _mod tmp_d tmp_c miss
  log_info "apply: starting (${#MACCTL_MODULES[@]} module(s); dry-run=${MACCTL_DRY_RUN}; only='${MACCTL_ONLY:-all}')"
  for _mod in "${MACCTL_MODULES[@]}"; do
    module_selected "$_mod" || continue
    log_progress "apply: [${_mod}] reading desired state..."
    tmp_d=$(mktemp)
    tmp_c=$(mktemp)
    trap 'rm -f "$tmp_d" "$tmp_c"' RETURN
    "${_mod}_get_desired" >"$tmp_d" 2>/dev/null || true
    log_progress "apply: [${_mod}] scanning what is installed..."
    "${_mod}_get_current" >"$tmp_c" 2>/dev/null || true
    log_progress "apply: [${_mod}] computing diff..."
    miss=$(diff_lists "$tmp_d" "$tmp_c")
    if [[ -z "$miss" ]]; then
      log_info "apply: module '${_mod}' - already in sync"
    else
      log_info "apply: module '${_mod}' - installing missing items..."
      echo "$miss" | "${_mod}_install" || return "$?"
    fi
    rm -f "$tmp_d" "$tmp_c"
    trap - RETURN
  done
  log_info "apply: finished all modules"
}
