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
  for _mod in "${MACCTL_MODULES[@]}"; do
    module_selected "$_mod" || continue
    tmp_d=$(mktemp)
    tmp_c=$(mktemp)
    trap 'rm -f "$tmp_d" "$tmp_c"' RETURN
    "${_mod}_get_desired" >"$tmp_d" 2>/dev/null || true
    "${_mod}_get_current" >"$tmp_c" 2>/dev/null || true
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
}

run_apply() {
  export MACCTL_DRY_RUN MACCTL_ONLY
  local _mod tmp_d tmp_c miss
  for _mod in "${MACCTL_MODULES[@]}"; do
    module_selected "$_mod" || continue
    tmp_d=$(mktemp)
    tmp_c=$(mktemp)
    trap 'rm -f "$tmp_d" "$tmp_c"' RETURN
    "${_mod}_get_desired" >"$tmp_d" 2>/dev/null || true
    "${_mod}_get_current" >"$tmp_c" 2>/dev/null || true
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
}
