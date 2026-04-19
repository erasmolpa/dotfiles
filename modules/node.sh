# modules/node.sh — global npm packages
# shellcheck shell=bash

node_inv() { echo "${DOTFILES}/inventory/node/global-packages.txt"; }

node_get_desired() {
  local inv line pkg
  inv="$(node_inv)"
  [[ -f "$inv" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    pkg="${line#"${line%%[![:space:]]*}"}"
    pkg="${pkg%"${pkg##*[![:space:]]}"}"
    [[ -n "$pkg" ]] && echo "npm:${pkg}"
  done <"$inv"
}

node_get_current() {
  command -v npm &>/dev/null || return 0
  log_progress "node: checking global npm packages from inventory..."
  local inv line pkg
  inv="$(node_inv)"
  [[ -f "$inv" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    pkg="${line#"${line%%[![:space:]]*}"}"
    pkg="${pkg%"${pkg##*[![:space:]]}"}"
    [[ -z "$pkg" ]] && continue
    npm list -g --depth=0 "$pkg" &>/dev/null && echo "npm:${pkg}"
  done <"$inv"
}

node_install() {
  local line pkg
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
      npm:*)
        pkg="${line#npm:}"
        run_command npm install -g "$pkg"
        ;;
    esac
  done
}

register_module "node"
