# core/helpers.sh — shared logging, list diff, command execution (bash)
# shellcheck shell=bash

: "${MACCTL_DRY_RUN:=0}"

log_info() { printf '%b\n' "[macctl] $*" >&2; }
log_warn() { printf '%b\n' "[macctl] WARN: $*" >&2; }
log_error() { printf '%b\n' "[macctl] ERROR: $*" >&2; }

# Lines present in file A but not in file B (desired minus current).
diff_lists() {
  local a="$1" b="$2"
  local ta tb
  ta=$(mktemp)
  tb=$(mktemp)
  if [[ -f "$a" ]]; then sort -u "$a" >"$ta"; else : >"$ta"; fi
  if [[ -f "$b" ]]; then sort -u "$b" >"$tb"; else : >"$tb"; fi
  comm -23 "$ta" "$tb"
  rm -f "$ta" "$tb"
}

run_command() {
  if [[ "${MACCTL_DRY_RUN}" -eq 1 ]]; then
    log_info "DRY-RUN: $*"
    return 0
  fi
  if ! eval "$@"; then
    log_error "Command failed: $*"
    return 1
  fi
}

# Static analysis for shell scripts (requires shellcheck on PATH).
run_shellcheck() {
  if ! command -v shellcheck &>/dev/null; then
    log_error "shellcheck not found; install with: brew install shellcheck"
    return 1
  fi
  local f status=0
  for f in \
    "$DOTFILES/install.sh" \
    "$DOTFILES/bin/macctl" \
    "$DOTFILES/core/helpers.sh" \
    "$DOTFILES/core/registry.sh" \
    "$DOTFILES/core/runner.sh" \
    "$DOTFILES/core/main.sh" \
    "$DOTFILES/bootstrap/pre-install.sh" \
    "$DOTFILES/bootstrap/setup.sh" \
    "$DOTFILES/bootstrap/post-setup.sh" \
    "$DOTFILES/bootstrap/clone-repos.sh" \
    "$DOTFILES/bootstrap/pyenv-setup.sh" \
    "$DOTFILES/scripts/ssh.sh"; do
    [[ -f "$f" ]] || continue
    shellcheck -x "$f" || status=1
  done
  for f in "$DOTFILES/modules"/*.sh; do
    [[ -f "$f" ]] || continue
    shellcheck -x "$f" || status=1
  done
  if [[ "$status" -eq 0 ]]; then
    log_info "lint: shellcheck passed"
  else
    log_error "lint: shellcheck reported issues"
  fi
  return "$status"
}
