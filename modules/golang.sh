# modules/golang.sh — Homebrew formulae for the Go toolchain
# shellcheck shell=bash

golang_inventory() { echo "${DOTFILES}/inventory/golang/formulae.txt"; }

golang_get_desired() {
  local inv f
  inv="$(golang_inventory)"
  [[ -f "$inv" ]] || return 0
  while IFS= read -r f || [[ -n "$f" ]]; do
    f="${f//$'\r'/}"
    [[ -z "$f" || "$f" =~ ^[[:space:]]*# ]] && continue
    echo "formula:${f//[[:space:]]/}"
  done <"$inv"
}

golang_get_current() {
  command -v brew &>/dev/null || return 0
  local inv f
  inv="$(golang_inventory)"
  [[ -f "$inv" ]] || return 0
  while IFS= read -r f || [[ -n "$f" ]]; do
    f="${f//$'\r'/}"
    [[ -z "$f" || "$f" =~ ^[[:space:]]*# ]] && continue
    f="${f//[[:space:]]/}"
    brew list --formula "$f" &>/dev/null && echo "formula:${f}"
  done <"$inv"
}

golang_install() {
  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
      formula:*) run_command brew install "${line#formula:}" ;;
    esac
  done
}

register_module "golang"
