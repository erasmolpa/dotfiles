# modules/vim.sh — vim-plug, fzf integration, and :PlugInstall
# shellcheck shell=bash

vim_get_desired() {
  echo "step:plugvim"
  echo "step:fzf"
  echo "step:plugins"
}

vim_get_current() {
  log_progress "vim: checking vim-plug, fzf, and plugin marker..."
  [[ -f "$HOME/.vim/autoload/plug.vim" ]] && echo "step:plugvim"
  if command -v fzf &>/dev/null; then
    local d
    d="$(brew --prefix 2>/dev/null)/opt/fzf/install"
    [[ -f "$d" ]] && echo "step:fzf"
  fi
  # Idempotent marker after a successful PlugInstall (avoids re-running vim on every apply)
  [[ -f "${DOTFILES}/state/vim-plugins.ok" ]] && echo "step:plugins"
}

vim_install() {
  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    case "$line" in
      step:plugvim)
        run_command mkdir -p "$HOME/.vim/autoload"
        if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
          run_command curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        fi
        ;;
      step:fzf)
        if command -v fzf &>/dev/null && [[ -x "$(brew --prefix 2>/dev/null)/opt/fzf/install" ]]; then
          run_command bash -c "\"$(brew --prefix)/opt/fzf/install\" --all --no-bash --no-fish"
        else
          log_warn "fzf not installed; skip fzf keybindings"
        fi
        ;;
      step:plugins)
        if [[ "${MACCTL_DRY_RUN}" -eq 1 ]]; then
          log_info "DRY-RUN: vim +PlugInstall +qall"
        elif vim +PlugInstall +qall; then
          mkdir -p "${DOTFILES}/state"
          : >"${DOTFILES}/state/vim-plugins.ok"
        fi
        ;;
    esac
  done
}

register_module "vim"
