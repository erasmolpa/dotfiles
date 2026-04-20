# modules/vscode.sh — Cursor / VSCode global settings symlink
# shellcheck shell=bash
#
# Manages:  ~/Library/Application Support/Cursor/User/settings.json
# Source:   $DOTFILES/inventory/vscode/settings.json
#
# Desired state: one token "step:cursor-settings" when inventory source exists.
# Current state: same token emitted only when the live file is already a
#                symlink pointing at the inventory source.

vscode__src() { echo "${DOTFILES}/inventory/vscode/settings.json"; }
vscode__dst() { echo "${HOME}/Library/Application Support/Cursor/User/settings.json"; }

vscode_get_desired() {
  local src
  src="$(vscode__src)"
  [[ -f "$src" ]] && echo "step:cursor-settings"
}

vscode_get_current() {
  local src dst
  src="$(vscode__src)"
  dst="$(vscode__dst)"
  log_progress "vscode: checking Cursor settings symlink..."
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    echo "step:cursor-settings"
  fi
}

vscode_install() {
  local src dst backup line
  src="$(vscode__src)"
  dst="$(vscode__dst)"

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
      step:cursor-settings)
        if [[ "${MACCTL_DRY_RUN}" -eq 1 ]]; then
          log_info "DRY-RUN: would symlink Cursor settings → $src"
          continue
        fi

        # Ensure destination directory exists (path has spaces — avoid run_command)
        local dst_dir
        dst_dir="$(dirname "$dst")"
        if [[ ! -d "$dst_dir" ]]; then
          log_info "running: mkdir -p \"$dst_dir\""
          mkdir -p "$dst_dir" || { log_error "mkdir failed: $dst_dir"; return 1; }
        fi

        # Back up existing file (regular file or wrong symlink)
        if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then
          backup="${dst}.backup-$(date +%Y%m%d-%H%M%S)"
          log_info "vscode: backing up existing settings → $backup"
          mv "$dst" "$backup" || { log_error "backup failed"; return 1; }
        fi

        # Create symlink (path has spaces — avoid run_command)
        log_info "running: ln -sf \"$src\" \"$dst\""
        ln -sf "$src" "$dst" || { log_error "ln failed"; return 1; }
        log_info "vscode: Cursor settings symlinked → $src"
        ;;
    esac
  done
}

register_module "vscode"
