# modules/python.sh — pip packages from inventory/python/requirements.txt
# shellcheck shell=bash

python_req() { echo "${DOTFILES}/inventory/python/requirements.txt"; }

python__base_name() {
  local spec="$1"
  spec="${spec%%#*}"
  spec="${spec#"${spec%%[![:space:]]*}"}"
  spec="${spec%"${spec##*[![:space:]]}"}"
  [[ -z "$spec" ]] && return 1
  spec="${spec%%[*}"
  echo "$spec" | sed -E 's/^([a-zA-Z0-9_.+-]+).*/\1/' | tr '[:upper:]' '[:lower:]'
}

python_get_desired() {
  local req line spec b
  req="$(python_req)"
  [[ -f "$req" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    spec="${line#"${line%%[![:space:]]*}"}"
    spec="${spec%"${spec##*[![:space:]]}"}"
    [[ "$spec" =~ ^git\+|^https?:// ]] && continue
    b="$(python__base_name "$spec")" || continue
    echo "pip|${b}|${spec}"
  done <"$req"
}

python_get_current() {
  command -v python3 &>/dev/null || return 0
  python3 -m pip --version &>/dev/null || return 0
  local req line spec b
  req="$(python_req)"
  [[ -f "$req" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//$'\r'/}"
    [[ -z "${line//[[:space:]]/}" || "$line" =~ ^[[:space:]]*# ]] && continue
    spec="${line#"${line%%[![:space:]]*}"}"
    spec="${spec%"${spec##*[![:space:]]}"}"
    [[ "$spec" =~ ^git\+|^https?:// ]] && continue
    b="$(python__base_name "$spec")" || continue
    python3 -m pip show "$b" &>/dev/null && echo "pip|${b}|${spec}"
  done <"$req"
}

python_install() {
  local line spec
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
      pip\|*)
        spec="${line#pip|}"
        spec="${spec#*|}"
        run_command python3 -m pip install "$spec"
        ;;
    esac
  done
}

register_module "python"
