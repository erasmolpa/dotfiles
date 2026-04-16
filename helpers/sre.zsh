# =============================================================================
#  SRE / Observability / Cloud-Native — Aliases & Helpers
# =============================================================================
#  Auto-loaded by oh-my-zsh via ZSH_CUSTOM=$DOTFILES
#  Usage: help-sre (shows all commands in this file)
# =============================================================================

# ─────────────────────────────────────────────
#  CONFIGURATION (override in .zshrc.local)
# ─────────────────────────────────────────────

export PROM_URL="${PROM_URL:-http://localhost:9090}"
export LOKI_URL="${LOKI_URL:-http://localhost:3100}"
export TEMPO_URL="${TEMPO_URL:-http://localhost:3200}"
export GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
export ALERTMANAGER_URL="${ALERTMANAGER_URL:-http://localhost:9093}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-1}"

# ...rest of the file with all helpers, aliases, and functions as in the latest .dotfiles version...
