# modules/brew.sh — Homebrew, mas, and VS Code extensions
# shellcheck shell=bash

brew_brewfile() { echo "${DOTFILES}/inventory/brew/Brewfile"; }
brew_casks_file() { echo "${DOTFILES}/inventory/brew/casks.txt"; }

brew__parse_taps() {
  local bf="$1"
  [[ -f "$bf" ]] || return 0
  { grep -E '^[[:space:]]*tap[[:space:]]+"' "$bf" || true; } | sed 's/#.*//' | sed -E 's/^[[:space:]]*tap[[:space:]]+"([^"]+)".*/\1/' | grep -v '^$' | sort -u
}

brew__parse_formulae() {
  local bf="$1"
  [[ -f "$bf" ]] || return 0
  { grep -E '^[[:space:]]*brew[[:space:]]+"' "$bf" || true; } | sed 's/#.*//' | sed -E 's/^[[:space:]]*brew[[:space:]]+"([^"]+)".*/\1/' | grep -v '^$' | sort -u
}

brew__parse_mas_ids() {
  local bf="$1"
  [[ -f "$bf" ]] || return 0
  { grep -E '^[[:space:]]*mas[[:space:]]+"' "$bf" || true; } | sed -E 's/.*id:[[:space:]]*([0-9]+).*/\1/' | grep -E '^[0-9]+$' | sort -u
}

brew__parse_vscode() {
  local bf="$1"
  [[ -f "$bf" ]] || return 0
  { grep -E '^[[:space:]]*vscode[[:space:]]+"' "$bf" || true; } | sed 's/#.*//' | sed -E 's/^[[:space:]]*vscode[[:space:]]+"([^"]+)".*/\1/' | grep -v '^$' | tr '[:upper:]' '[:lower:]' | sort -u
}

brew_get_desired() {
  local bf cf tap f id ext
  bf="$(brew_brewfile)"
  while IFS= read -r tap; do
    [[ -n "$tap" ]] && echo "tap:${tap}"
  done < <(brew__parse_taps "$bf")
  while IFS= read -r f; do
    [[ -n "$f" ]] && echo "formula:${f}"
  done < <(brew__parse_formulae "$bf")
  cf="$(brew_casks_file)"
  if [[ -f "$cf" ]]; then
    local line c
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      c="${line//[[:space:]]/}"
      [[ -n "$c" ]] && echo "cask:${c}"
    done <"$cf"
  fi
  while IFS= read -r id; do
    [[ -n "$id" ]] && echo "mas:${id}"
  done < <(brew__parse_mas_ids "$bf")
  while IFS= read -r ext; do
    [[ -n "$ext" ]] && echo "vscode:${ext}"
  done < <(brew__parse_vscode "$bf")
}

brew_get_current() {
  command -v brew &>/dev/null || return 0
  local bf tap f id ext
  bf="$(brew_brewfile)"
  while IFS= read -r tap; do
    [[ -z "$tap" ]] && continue
    brew tap 2>/dev/null | awk '{print $1}' | grep -Fxq "$tap" && echo "tap:${tap}"
  done < <(brew__parse_taps "$bf")
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    brew list --formula "$f" &>/dev/null && echo "formula:${f}"
  done < <(brew__parse_formulae "$bf")
  cf="$(brew_casks_file)"
  if [[ -f "$cf" ]]; then
    local line c
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line//$'\r'/}"
      [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
      c="${line//[[:space:]]/}"
      [[ -z "$c" ]] && continue
      brew list --cask "$c" &>/dev/null && echo "cask:${c}"
    done <"$cf"
  fi
  if command -v mas &>/dev/null; then
    while IFS= read -r id; do
      [[ -z "$id" ]] && continue
      mas list 2>/dev/null | awk '{print $1}' | grep -Fxq "$id" && echo "mas:${id}"
    done < <(brew__parse_mas_ids "$bf")
  fi
  if command -v code &>/dev/null; then
    local installed
    installed="$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
    while IFS= read -r ext; do
      [[ -z "$ext" ]] && continue
      echo "$installed" | grep -Fxq "$ext" && echo "vscode:${ext}"
    done < <(brew__parse_vscode "$bf")
  fi
}

brew_install() {
  local buf
  buf="$(cat)"
  local kind line
  for kind in tap formula cask mas vscode; do
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      case "$line" in
        tap:*)
          run_command brew tap "${line#tap:}"
          ;;
        formula:*)
          run_command brew install "${line#formula:}"
          ;;
        cask:*)
          run_command brew install --cask "${line#cask:}"
          ;;
        mas:*)
          run_command mas install "${line#mas:}"
          ;;
        vscode:*)
          run_command code --install-extension "${line#vscode:}"
          ;;
      esac
    done < <(echo "$buf" | grep "^${kind}:" || true)
  done
}

brew_doctor() {
  command -v brew &>/dev/null || log_warn "brew not found"
  [[ -f "$(brew_brewfile)" ]] || log_warn "missing $(brew_brewfile)"
}

register_module "brew"
