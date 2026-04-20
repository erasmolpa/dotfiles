# =============================================================================
#  Deel Observability Repo — Local development shortcuts
# =============================================================================
#  Repo: ~/Code/github/deel
#  Stack: FastAPI × 2, Alloy, Prometheus, Loki, Tempo, Grafana, k6
#
#  Run `help-deel` to see all commands.
# =============================================================================

export DEEL_REPO="${DEEL_REPO:-$HOME/Code/github/deel}"

# ── Navigation ────────────────────────────────────────────────────────────────

# cd to the deel repo
deel() { cd "$DEEL_REPO" || return 1; }

# cd to observability configs
deel-obs() { cd "$DEEL_REPO/observability" || return 1; }

# cd to alloy config
deel-alloy() { cd "$DEEL_REPO/observability/alloy" || return 1; }

# Open the repo in Cursor
deel-edit() { cursor "$DEEL_REPO"; }

# ── Docker Compose stack ──────────────────────────────────────────────────────

# Start both servers (builds first)
deel-up() {
  echo "→ Starting deel stack..."
  make -C "$DEEL_REPO" up
}

# Stop both servers
deel-down() {
  echo "→ Stopping deel stack..."
  make -C "$DEEL_REPO" down
}

# Rebuild and restart without cache
deel-rebuild() {
  echo "→ Rebuilding deel stack..."
  make -C "$DEEL_REPO" down
  make -C "$DEEL_REPO" build
  make -C "$DEEL_REPO" up
}

# Health-check all services
deel-check() {
  echo "→ Checking deel services..."
  make -C "$DEEL_REPO" check
}

# Full reset (removes volumes)
deel-clean() {
  echo "⚠  This will remove all containers and volumes. Continue? [y/N]"
  read -r confirm
  [[ "$confirm" =~ ^[Yy]$ ]] && make -C "$DEEL_REPO" clean
}

# ── Logs ──────────────────────────────────────────────────────────────────────

# Tail API logs
deel-logs-api() {
  make -C "$DEEL_REPO" logs-api
}

# Tail worker logs
deel-logs-worker() {
  make -C "$DEEL_REPO" logs-worker
}

# Tail any service by name (uses docker compose directly)
# Usage: deel-logs <service>
deel-logs() {
  local svc="${1:?Usage: deel-logs <api|worker|alloy|prometheus|loki|tempo|grafana>}"
  local compose_file
  case "$svc" in
    api|worker)
      compose_file="$DEEL_REPO/docker-compose.app.yml"
      ;;
    *)
      compose_file="$DEEL_REPO/docker-compose.observability.yml"
      ;;
  esac
  docker compose -f "$compose_file" logs -f "$svc"
}

# ── Load testing ──────────────────────────────────────────────────────────────

# Run k6 load test
deel-load() {
  echo "→ Running k6 load test..."
  make -C "$DEEL_REPO" load
}

# ── Open UIs ──────────────────────────────────────────────────────────────────

# Open all UIs at once
deel-open() {
  echo "→ Opening Grafana, Prometheus, Alloy UI..."
  open "http://localhost:3000"   # Grafana
  sleep 0.3
  open "http://localhost:9090"   # Prometheus
  sleep 0.3
  open "http://localhost:12345"  # Alloy debug UI
}

# Open individual UIs
alias deel-grafana="open http://localhost:3000"
alias deel-prometheus="open http://localhost:9090"
alias deel-loki="open http://localhost:3100"
alias deel-tempo="open http://localhost:3200"
alias deel-alloy-ui="open http://localhost:12345"

# ── Alloy config helpers ──────────────────────────────────────────────────────

# Validate the local Alloy config
deel-alloy-validate() {
  alloy-validate "$DEEL_REPO/observability/alloy/config.alloy"
}

# Format the local Alloy config in-place
deel-alloy-fmt() {
  alloy-fmt "$DEEL_REPO/observability/alloy/config.alloy"
}

# Open the Alloy config in editor
deel-alloy-edit() {
  cursor "$DEEL_REPO/observability/alloy/config.alloy"
}

# ── Prometheus helpers ────────────────────────────────────────────────────────

# Validate the local prometheus.yml
deel-prom-validate() {
  local f="$DEEL_REPO/observability/prometheus/prometheus.yml"
  echo "→ Checking $f ..."
  promtool check config "$f" && echo "✓ prometheus.yml is valid"
}

# Validate the local alert rules
deel-prom-rules() {
  local f="$DEEL_REPO/observability/prometheus/rules/alerts.yml"
  echo "→ Checking $f ..."
  promtool check rules "$f" && echo "✓ alerts.yml is valid"
}

# ── Status overview ───────────────────────────────────────────────────────────

# Quick status of all containers in the deel stack
deel-status() {
  echo "\n── App stack ────────────────────────────────────────────"
  docker compose -f "$DEEL_REPO/docker-compose.app.yml" ps 2>/dev/null || echo "  (not running)"
  echo "\n── Observability stack ──────────────────────────────────"
  docker compose -f "$DEEL_REPO/docker-compose.observability.yml" ps 2>/dev/null || echo "  (not running)"
  echo ""
}

# ── Help ──────────────────────────────────────────────────────────────────────

help-deel() {
  echo "\n╔══════════════════════════════════════════════════════╗"
  echo   "║          Deel Repo — Local Dev Shortcuts             ║"
  echo   "╚══════════════════════════════════════════════════════╝\n"
  echo "── Navigation ─────────────────────────────────────────"
  echo "  deel                        cd ~/Code/github/deel"
  echo "  deel-obs                    cd .../observability"
  echo "  deel-alloy                  cd .../observability/alloy"
  echo "  deel-edit                   Open repo in Cursor"
  echo ""
  echo "── Stack ──────────────────────────────────────────────"
  echo "  deel-up                     Build + start both stacks"
  echo "  deel-down                   Stop both stacks"
  echo "  deel-rebuild                Full rebuild from scratch"
  echo "  deel-clean                  Remove containers + volumes"
  echo "  deel-status                 Show running containers"
  echo "  deel-check                  Health-check all services"
  echo ""
  echo "── Logs ───────────────────────────────────────────────"
  echo "  deel-logs <service>         Tail any service logs"
  echo "  deel-logs-api               Tail API logs"
  echo "  deel-logs-worker            Tail worker logs"
  echo ""
  echo "── Open UIs ───────────────────────────────────────────"
  echo "  deel-open                   Open Grafana+Prometheus+Alloy"
  echo "  deel-grafana                http://localhost:3000"
  echo "  deel-prometheus             http://localhost:9090"
  echo "  deel-loki                   http://localhost:3100"
  echo "  deel-tempo                  http://localhost:3200"
  echo "  deel-alloy-ui               http://localhost:12345"
  echo ""
  echo "── Alloy ──────────────────────────────────────────────"
  echo "  deel-alloy-validate         Validate config.alloy"
  echo "  deel-alloy-fmt              Format config.alloy in-place"
  echo "  deel-alloy-edit             Open config.alloy in Cursor"
  echo ""
  echo "── Prometheus ─────────────────────────────────────────"
  echo "  deel-prom-validate          promtool check prometheus.yml"
  echo "  deel-prom-rules             promtool check alerts.yml"
  echo ""
  echo "── Load testing ───────────────────────────────────────"
  echo "  deel-load                   Run k6 load test"
  echo ""
}
