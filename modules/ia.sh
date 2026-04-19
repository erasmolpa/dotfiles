# modules/ia.sh — AI and DevOps extras (brew tap/formula/cask plus uv pip)
# shellcheck shell=bash

ia_manifest() { echo "${DOTFILES}/inventory/ia/manifest.txt"; }
ia_uvpkgs() { echo "${DOTFILES}/inventory/ia/uv-packages.txt"; }

ia_get_desired() {
  local f line k v
  f="$(ia_manifest)"
  if [[ -f "$f" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" == *:* ]] || continue
      k="${line%%:*}"
      v="${line#*:}"
      v="${v//[[:space:]]/}"
      [[ -n "$v" ]] || continue
      case "$k" in
        tap | brew_formula | brew_cask)
          echo "${k}:${v}"
          ;;
      esac
    done <"$f"
  fi
  f="$(ia_uvpkgs)"
  if [[ -f "$f" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
      echo "uvpip:${line//[[:space:]]/}"
    done <"$f"
  fi
}

ia__cask_installed() {
  local c="$1"
  brew list --cask "$c" &>/dev/null && return 0
  case "$c" in
    cursor) [[ -d "/Applications/Cursor.app" ]] ;;
    visual-studio-code) [[ -d "/Applications/Visual Studio Code.app" ]] ;;
    *) return 1 ;;
  esac
}

ia__uv_installed() {
  local p="$1"
  command -v uv &>/dev/null || return 1
  uv pip show "$p" &>/dev/null
}

ia_get_current() {
  command -v brew &>/dev/null || return 0
  local f line k v
  f="$(ia_manifest)"
  if [[ -f "$f" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
      [[ "$line" == *:* ]] || continue
      k="${line%%:*}"
      v="${line#*:}"
      v="${v//[[:space:]]/}"
      [[ -n "$v" ]] || continue
      case "$k" in
        tap)
          brew tap 2>/dev/null | awk '{print $1}' | grep -Fxq "$v" && echo "tap:${v}"
          ;;
        brew_formula)
          brew list --formula "$v" &>/dev/null && echo "brew_formula:${v}"
          ;;
        brew_cask)
          ia__cask_installed "$v" && echo "brew_cask:${v}"
          ;;
      esac
    done <"$f"
  fi
  f="$(ia_uvpkgs)"
  if [[ -f "$f" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
      p="${line//[[:space:]]/}"
      ia__uv_installed "$p" && echo "uvpip:${p}"
    done <"$f"
  fi
}

ia_install() {
  local line k v
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    k="${line%%:*}"
    v="${line#*:}"
    case "$k" in
      tap) run_command brew tap "$v" ;;
      brew_formula) run_command brew install "$v" ;;
      brew_cask) run_command brew install --cask "$v" ;;
      uvpip)
        if command -v uv &>/dev/null; then
          run_command uv pip install "$v"
        else
          log_warn "uv not found; skipping uvpip:${v}"
        fi
        ;;
    esac
  done
}

ia_doctor() {
  command -v uv &>/dev/null || log_warn "ia: uv not installed (brew module should provide it)"
}

register_module "ia"
