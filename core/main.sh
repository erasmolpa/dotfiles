#!/usr/bin/env bash
# core/main.sh — macctl command dispatcher
# shellcheck shell=bash
# Repo root: parent of this directory (…/core/main.sh → DOTFILES).
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES
set -euo pipefail

MACCTL_DRY_RUN=0
MACCTL_ONLY=""

parse_flags() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) MACCTL_DRY_RUN=1 ;;
      --only=*) MACCTL_ONLY="${1#--only=}" ;;
      *)
        log_warn "ignoring unknown flag: $1"
        ;;
    esac
    shift
  done
}

print_help() {
  cat >&2 <<'EOF'
macctl — dotfiles control plane (core/ + modules/)

Usage:
  macctl plan [--only=brew,golang,python,node,vim,ia]
  macctl apply [--dry-run] [--only=brew,...]
  macctl doctor
  macctl sync [--write]
  macctl lint

Module load order is defined in core/module-order (one name per line; loads modules/<name>.sh).

Environment:
  DOTFILES   Repository root (default: directory containing core/main.sh)
EOF
}

run_doctor() {
  log_info "doctor: DOTFILES=$DOTFILES"
  [[ -d "$DOTFILES" ]] || { log_error "DOTFILES is not a directory"; return 1; }
  [[ -x "$DOTFILES/bin/macctl" ]] || log_warn "bin/macctl is not executable"
  command -v brew &>/dev/null || log_warn "Homebrew (brew) is not on PATH"
  [[ -d "$HOME/.oh-my-zsh" ]] || log_warn "Oh My Zsh is not installed at ~/.oh-my-zsh"
  [[ -f "$DOTFILES/config/zsh/.zshrc" ]] || log_warn "Missing config/zsh/.zshrc"
  [[ -d "$DOTFILES/inventory/brew" ]] || log_warn "Missing inventory/brew"
  local m
  for m in ${MACCTL_MODULES[@]+"${MACCTL_MODULES[@]}"}; do
    if declare -f "${m}_doctor" &>/dev/null; then
      "${m}_doctor" || true
    fi
  done
  log_info "doctor: finished checks"
}

run_sync() {
  local write=0
  local a
  for a in "$@"; do [[ "$a" == "--write" ]] && write=1; done
  local sd="$DOTFILES/state"
  mkdir -p "$sd"
  if [[ "$write" -eq 1 ]]; then
    log_info "sync --write: refreshing state/*.txt from the live system"
  else
    log_info "sync: writing state/*.txt (snapshots for audit)"
  fi
  if command -v brew &>/dev/null; then
    {
      echo "### brew formulae ($(date -u +%Y-%m-%dT%H:%MZ))"
      brew list --formula -1 2>/dev/null | sort -u || true
      echo ""
      echo "### brew casks"
      brew list --cask -1 2>/dev/null | sort -u || true
    } >"$sd/brew-installed.txt"
  fi
  if command -v python3 &>/dev/null && python3 -m pip --version &>/dev/null; then
    python3 -m pip freeze 2>/dev/null | sort -u >"$sd/python-installed.txt" || true
  fi
  if command -v npm &>/dev/null; then
    npm list -g --depth=0 2>/dev/null >"$sd/node-installed.txt" || true
  fi
  mkdir -p "$DOTFILES/inventory/_generated"
  cp -f "$sd/brew-installed.txt" "$DOTFILES/inventory/_generated/brew-installed.snapshot.txt" 2>/dev/null || true
  log_info "sync: snapshots updated under state/ and inventory/_generated/"
}

main_load() {
  # shellcheck source=core/helpers.sh
  source "$DOTFILES/core/helpers.sh"
  # shellcheck source=core/registry.sh
  source "$DOTFILES/core/registry.sh"
  # shellcheck source=core/runner.sh
  source "$DOTFILES/core/runner.sh"

  MACCTL_MODULES=()
  local name path line
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    name="${line//[[:space:]]/}"
    path="$DOTFILES/modules/${name}.sh"
    if [[ ! -f "$path" ]]; then
      log_warn "module-order lists '${name}' but missing file: $path"
      continue
    fi
    # shellcheck source=/dev/null
    source "$path"
  done <"$DOTFILES/core/module-order"
}

cmd="${1:-help}"
shift || true

case "$cmd" in
  plan)
    main_load
    parse_flags "$@"
    run_plan
    ;;
  apply)
    main_load
    parse_flags "$@"
    run_apply
    ;;
  doctor)
    main_load
    run_doctor
    ;;
  sync)
    main_load
    run_sync "$@"
    ;;
  lint)
    # Only helpers needed for logging
    # shellcheck source=core/helpers.sh
    source "$DOTFILES/core/helpers.sh"
    run_shellcheck
    ;;
  help | -h | --help)
    print_help
    ;;
  *)
    printf '%s\n' "[macctl] ERROR: unknown command: $cmd" >&2
    print_help
    exit 1
    ;;
esac
