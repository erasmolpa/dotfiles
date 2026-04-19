# Pyenv / uv PATH (sourced from .zshrc). Installed versions: see bootstrap/pyenv-setup.sh
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
