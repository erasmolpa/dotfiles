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

# Scaffold: Terraform AWS module
# Usage: tf-new-aws <module-name>
tf-new-aws() {
  local name="${1:?Usage: tf-new-aws <module-name>}"
  mkdir -p "$name"
  cat > "$name/main.tf" <<'TF'
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
TF
  cat > "$name/variables.tf" <<'TF'
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}
TF
  cat > "$name/outputs.tf" <<'TF'
# Outputs
TF
  echo "✓ Created AWS Terraform module: $name/ (main.tf, variables.tf, outputs.tf)"
}

# Scaffold: Terraform S3 bucket
# Usage: tf-new-s3 <bucket-name>
tf-new-s3() {
  local name="${1:?Usage: tf-new-s3 <bucket-name>}"
  mkdir -p "$name"
  cat > "$name/main.tf" <<'TF'
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"
}
TF
  cat > "$name/variables.tf" <<'TF'
variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}
TF
  echo "✓ Created S3 bucket module: $name/ (main.tf, variables.tf)"
}

# help-all: List all helpers and wizards, or filter by section/technology
help-all() {
  local filter="${1:-all}"
  echo "\n--- HELPERS & WIZARDS: $filter ---"
  case "$filter" in
    all)
      echo "\nHelpers (sre.zsh):"
      grep -E '^([a-zA-Z0-9_-]+)\(\) ' "$DOTFILES/helpers/sre.zsh" | awk -F'(' '{print "  - "$1}'
      echo "\nWizards (wizards.zsh):"
      grep -E '^wiz-[a-zA-Z0-9_-]+\(\) ' "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}'
      echo "\nUse: help-all <section|tool>  (e.g. help-all terraform, help-all aws, help-all wizards, help-all scaffolding, help-all kubernetes, help-all docker)"
      ;;
    helpers)
      echo "\nHelpers (sre.zsh):"
      grep -E '^([a-zA-Z0-9_-]+)\(\) ' "$DOTFILES/helpers/sre.zsh" | awk -F'(' '{print "  - "$1}'
      ;;
    wizards)
      echo "\nWizards (wizards.zsh):"
      grep -E '^wiz-[a-zA-Z0-9_-]+\(\) ' "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}'
      ;;
    scaffolding)
      echo "\nScaffolding helpers (tf-new-|gen-|wiz-tf-|wiz-k8s-):"
      grep -E 'tf-new-|gen-|wiz-tf-|wiz-k8s-' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    terraform)
      echo "\nTerraform helpers/wizards:"
      grep -Ei 'tf-|terraform' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    aws)
      echo "\nAWS helpers/wizards:"
      grep -Ei 'aws-' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    prometheus|prom)
      echo "\nPrometheus helpers/wizards:"
      grep -Ei 'prom|pql' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    loki)
      echo "\nLoki helpers/wizards:"
      grep -Ei 'loki' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    k8s|kubernetes)
      echo "\nKubernetes helpers/wizards:"
      grep -Ei 'k8s|kube|klog|kdn|kexec|kpf|krun|kctx|kns|kpod|kall|ksecret|krollout|krestart|kscale|kyaml|kjson' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    docker)
      echo "\nDocker helpers/wizards:"
      grep -Ei 'docker' "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
    *)
      echo "\nHelpers/wizards matching '$filter':"
      grep -Ei "$filter" "$DOTFILES/helpers/sre.zsh" "$DOTFILES/wizards/wizards.zsh" | awk -F'(' '{print "  - "$1}' | sort | uniq
      ;;
  esac
}

# Scaffold: Prometheus config (prometheus.yml)
# Usage: gen-prom-config <filename>
gen-prom-config() {
  local file="${1:-prometheus.yml}"
  cat > "$file" <<'YAML'
global:
  scrape_interval: 15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
YAML
  echo "✓ Created Prometheus config: $file"
}

# Scaffold: Prometheus alert rule
# Usage: gen-prom-alert <alert-name>
gen-prom-alert() {
  local name="${1:?Usage: gen-prom-alert <alert-name>}"
  cat <<YAML
- alert: $name
  expr: |
    sum(rate(http_requests_total{status_code=~\"5..\"}[5m])) by (service) /
    sum(rate(http_requests_total[5m])) by (service) > 0.05
  for: 5m
  labels:
    severity: warning
    service: "{{ $labels.service }}"
  annotations:
    summary: "High error rate on {{ $labels.service }}"
    description: "Error rate is {{ $value | humanizePercentage }}"
    runbook_url: "https://wiki.internal/runbooks/$name"
YAML
}

# Scaffold: Loki config (loki-config.yml)
# Usage: gen-loki-config <filename>
gen-loki-config() {
  local file="${1:-loki-config.yml}"
  cat > "$file" <<'YAML'
server:
  http_listen_port: 3100
  grpc_listen_port: 9096
  log_level: info
  chunk_target_size: 1048576
  max_chunk_age: 1h
  table_manager:
    retention_deletes_enabled: true
    retention_period: 168h
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h
storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks
YAML
  echo "✓ Created Loki config: $file"
}

# =============================================================================
#  KUBERNETES HELPERS
# =============================================================================

# Stream pod logs by label selector
# Usage: klog <label=value> [namespace]
klog() {
  local selector="${1:?Usage: klog <label=value> [namespace]}"
  local ns="${2:--A}"
  if [[ "$ns" == "-A" ]]; then
    kubectl logs -l "$selector" --all-namespaces -f --tail=100 --max-log-requests=10
  else
    kubectl logs -l "$selector" -n "$ns" -f --tail=100 --max-log-requests=10
  fi
}

# Describe + events for a pod (one-stop debug)
# Usage: kpod-debug <pod-name> [namespace]
kpod-debug() {
  local pod="${1:?Usage: kpod-debug <pod-name> [namespace]}"
  local ns="${2:-default}"
  echo "=== DESCRIBE ==="
  kubectl describe pod "$pod" -n "$ns"
  echo "\n=== EVENTS ==="
  kubectl get events -n "$ns" --field-selector "involvedObject.name=$pod" --sort-by='.lastTimestamp'
}

# Get pod resource usage
# Usage: ktop-ns [namespace]
ktop-ns() {
  local ns="${1:-default}"
  kubectl top pods -n "$ns" --sort-by=cpu
}

# Scale a deployment
# Usage: kscale <deploy> <replicas> [namespace]
kscale() {
  local deploy="${1:?Usage: kscale <deploy> <replicas> [namespace]}"
  local replicas="${2:?Usage: kscale <deploy> <replicas>}"
  local ns="${3:-default}"
  kubectl scale deploy "$deploy" --replicas="$replicas" -n "$ns"
}

# Get secret decoded value
# Usage: ksecret <secret-name> <key> [namespace]
ksecret() {
  local name="${1:?Usage: ksecret <secret-name> <key> [namespace]}"
  local key="${2:?}"
  local ns="${3:-default}"
  kubectl get secret "$name" -n "$ns" -o jsonpath="{.data.$key}" | base64 --decode && echo
}

# List all resources in a namespace
# Usage: kall [namespace]
kall() {
  local ns="${1:-default}"
  kubectl get all -n "$ns"
}

# Quick exec into running container
# Usage: ksh <pod-name> [namespace] [shell]
ksh() {
  local pod="${1:?Usage: ksh <pod-name> [namespace] [shell]}"
  local ns="${2:-default}"
  local shell="${3:-sh}"
  kubectl exec -it "$pod" -n "$ns" -- "$shell"
}

# Get YAML manifest for a resource
# Usage: kyaml <resource-type> <name> [namespace]
kyaml() {
  local type="${1:?Usage: kyaml <type> <name> [namespace]}"
  local name="${2:?}"
  local ns="${3:-default}"
  kubectl get "$type" "$name" -n "$ns" -o yaml
}

# Port-forward with retry
# Usage: kpf-svc <service> <local-port>:<remote-port> [namespace]
kpf-svc() {
  local svc="${1:?Usage: kpf-svc <service> <local:remote> [namespace]}"
  local ports="${2:?}"
  local ns="${3:-default}"
  kubectl port-forward "svc/$svc" "$ports" -n "$ns"
}

# Quick rollout status for all deployments
# Usage: krollout-all [namespace]
krollout-all() {
  local ns="${1:--A}"
  if [[ "$ns" == "-A" ]]; then
    kubectl get deploy -A | tail -n +2 | while read -r namespace name _; do
      echo "→ $namespace/$name"
      kubectl rollout status deploy/"$name" -n "$namespace" 2>&1 | tail -1
    done
  else
    kubectl rollout status deploy -n "$ns"
  fi
}

# =============================================================================
#  AWS HELPERS
# =============================================================================

# Switch AWS profile
# Usage: aws-profile <profile-name>
aws-profile() {
  local profile="${1:?Usage: aws-profile <profile-name>}"
  export AWS_PROFILE="$profile"
  echo "✓ AWS_PROFILE set to: $profile"
  aws sts get-caller-identity
}

# Update kubeconfig for EKS cluster
# Usage: aws-eks-login <cluster-name> [region]
aws-eks-login() {
  local cluster="${1:?Usage: aws-eks-login <cluster-name> [region]}"
  local region="${2:-${AWS_DEFAULT_REGION:-eu-west-1}}"
  aws eks update-kubeconfig --name "$cluster" --region "$region"
  echo "✓ kubeconfig updated for: $cluster ($region)"
}

# List EKS clusters with node groups
# Usage: aws-eks-info [region]
aws-eks-info() {
  local region="${1:-${AWS_DEFAULT_REGION:-eu-west-1}}"
  echo "=== EKS Clusters in $region ==="
  aws eks list-clusters --region "$region" --query 'clusters[]' --output table
}

# Tail CloudWatch log group
# Usage: aws-logs <log-group> [minutes-ago]
aws-logs() {
  local group="${1:?Usage: aws-logs <log-group> [minutes-ago]}"
  local mins="${2:-30}"
  local start_time=$(( $(date +%s) - mins * 60 ))000
  aws logs filter-log-events \
    --log-group-name "$group" \
    --start-time "$start_time" \
    --query 'events[*].message' \
    --output text
}

# Get EC2 instances in a human-readable table
aws-ec2-list() {
  aws ec2 describe-instances \
    --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress]' \
    --output table
}

# List ECR repositories
aws-ecr-list() {
  aws ecr describe-repositories --query 'repositories[*].[repositoryName,repositoryUri]' --output table
}

# =============================================================================
#  PROMETHEUS HELPERS
# =============================================================================

# Instant PromQL query
# Usage: prom-query '<expr>'
prom-query() {
  local expr="${1:?Usage: prom-query '<promql-expression>'}"
  curl -sG "${PROM_URL}/api/v1/query" \
    --data-urlencode "query=$expr" \
    | jq '.data.result[]'
}

# Range PromQL query (last N minutes)
# Usage: prom-range '<expr>' [minutes]
prom-range() {
  local expr="${1:?Usage: prom-range '<expr>' [minutes]}"
  local mins="${2:-60}"
  local end=$(date +%s)
  local start=$(( end - mins * 60 ))
  curl -sG "${PROM_URL}/api/v1/query_range" \
    --data-urlencode "query=$expr" \
    --data-urlencode "start=$start" \
    --data-urlencode "end=$end" \
    --data-urlencode "step=60" \
    | jq '.data.result[]'
}

# List active Prometheus targets
prom-targets() {
  curl -sG "${PROM_URL}/api/v1/targets" | jq '.data.activeTargets[] | {job: .labels.job, instance: .labels.instance, health: .health}'
}

# List firing alerts
prom-alerts() {
  curl -sG "${PROM_URL}/api/v1/alerts" | jq '.data.alerts[] | select(.state=="firing")'
}

# Check Prometheus config and rules
prom-check() {
  echo "=== Config ==="
  promtool check config prometheus.yml
  echo "\n=== Rules ==="
  find . -name "*.yml" -o -name "*.yaml" | xargs -I{} promtool check rules {} 2>/dev/null
}

# =============================================================================
#  LOKI / LOGCLI HELPERS
# =============================================================================

# Tail logs with LogQL
# Usage: loki-tail '{app="my-app"}'
loki-tail() {
  local query="${1:?Usage: loki-tail '{label=\"value\"}'}"
  logcli query --addr="${LOKI_URL}" --tail "$query"
}

# Instant LogQL query (last N minutes)
# Usage: loki-query '{app="api"}' [minutes]
loki-query() {
  local query="${1:?Usage: loki-query '{label=\"value\"}' [minutes]}"
  local mins="${2:-30}"
  local since="${mins}m"
  logcli query --addr="${LOKI_URL}" --since="$since" "$query"
}

# List Loki labels
loki-labels() {
  logcli labels --addr="${LOKI_URL}"
}

# List label values
# Usage: loki-label-values <label>
loki-label-values() {
  local label="${1:?Usage: loki-label-values <label>}"
  logcli labels --addr="${LOKI_URL}" "$label"
}

# =============================================================================
#  SCAFFOLDING — KUBERNETES MANIFESTS
# =============================================================================

# Scaffold: Kubernetes Deployment
# Usage: gen-k8s-deploy <app-name> [image] [replicas]
gen-k8s-deploy() {
  local app="${1:?Usage: gen-k8s-deploy <app-name> [image] [replicas]}"
  local image="${2:-nginx:latest}"
  local replicas="${3:-2}"
  local file="${app}-deploy.yaml"
  cat > "$file" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${app}
  labels:
    app: ${app}
spec:
  replicas: ${replicas}
  selector:
    matchLabels:
      app: ${app}
  template:
    metadata:
      labels:
        app: ${app}
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: ${app}
          image: ${image}
          ports:
            - containerPort: 8080
          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
YAML
  echo "✓ Created: $file"
}

# Scaffold: Kubernetes Service
# Usage: gen-k8s-svc <app-name> [port]
gen-k8s-svc() {
  local app="${1:?Usage: gen-k8s-svc <app-name> [port]}"
  local port="${2:-8080}"
  local file="${app}-svc.yaml"
  cat > "$file" <<YAML
apiVersion: v1
kind: Service
metadata:
  name: ${app}
  labels:
    app: ${app}
spec:
  selector:
    app: ${app}
  ports:
    - name: http
      port: 80
      targetPort: ${port}
  type: ClusterIP
YAML
  echo "✓ Created: $file"
}

# Scaffold: HorizontalPodAutoscaler
# Usage: gen-k8s-hpa <app-name> [min] [max] [cpu-target%]
gen-k8s-hpa() {
  local app="${1:?Usage: gen-k8s-hpa <app-name> [min] [max] [cpu-target%]}"
  local min="${2:-2}"
  local max="${3:-10}"
  local cpu="${4:-70}"
  local file="${app}-hpa.yaml"
  cat > "$file" <<YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${app}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${app}
  minReplicas: ${min}
  maxReplicas: ${max}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: ${cpu}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
YAML
  echo "✓ Created: $file"
}

# Scaffold: PodDisruptionBudget
# Usage: gen-k8s-pdb <app-name> [min-available]
gen-k8s-pdb() {
  local app="${1:?Usage: gen-k8s-pdb <app-name> [min-available]}"
  local min="${2:-1}"
  local file="${app}-pdb.yaml"
  cat > "$file" <<YAML
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${app}
spec:
  minAvailable: ${min}
  selector:
    matchLabels:
      app: ${app}
YAML
  echo "✓ Created: $file"
}

# =============================================================================
#  SCAFFOLDING — OBSERVABILITY
# =============================================================================

# Scaffold: Grafana Alloy config
# Usage: gen-alloy-config [filename]
gen-alloy-config() {
  local file="${1:-config.alloy}"
  cat > "$file" <<'ALLOY'
// Grafana Alloy — Unified telemetry collector config

// ── Prometheus scrape ──────────────────────────────────────────────────────
prometheus.scrape "default" {
  targets = prometheus.exporter.self.default.targets
  forward_to = [prometheus.remote_write.mimir.receiver]
  scrape_interval = "15s"
}

prometheus.exporter.self "default" {}

prometheus.remote_write "mimir" {
  endpoint {
    url = "http://mimir:9009/api/v1/push"
  }
}

// ── OTLP receiver (traces + metrics from OpenTelemetry SDK) ───────────────
otelcol.receiver.otlp "default" {
  grpc { endpoint = "0.0.0.0:4317" }
  http { endpoint = "0.0.0.0:4318" }
  output {
    traces  = [otelcol.exporter.otlp.tempo.input]
    metrics = [otelcol.exporter.prometheus.default.input]
  }
}

otelcol.exporter.otlp "tempo" {
  client {
    endpoint = "http://tempo:4317"
    tls { insecure = true }
  }
}

otelcol.exporter.prometheus "default" {
  forward_to = [prometheus.remote_write.mimir.receiver]
}

// ── Loki log collection (Docker service discovery) ────────────────────────
discovery.docker "containers" {
  host = "unix:///var/run/docker.sock"
}

loki.source.docker "default" {
  host    = "unix:///var/run/docker.sock"
  targets = discovery.docker.containers.targets
  labels  = { job = "docker" }
  forward_to = [loki.write.local.receiver]
}

loki.write "local" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
ALLOY
  echo "✓ Created Alloy config: $file"
}

# Scaffold: Prometheus recording rules for RED metrics
# Usage: gen-recording-rules [app-name]
gen-recording-rules() {
  local app="${1:-myservice}"
  local file="${app}-recording-rules.yml"
  cat > "$file" <<YAML
groups:
  - name: ${app}_red_metrics
    interval: 30s
    rules:
      - record: job:http_requests:rate5m
        expr: sum(rate(http_requests_total[5m])) by (job, service)

      - record: job:http_errors:rate5m
        expr: sum(rate(http_requests_total{status_code=~"5.."}[5m])) by (job, service)

      - record: job:http_error_ratio:rate5m
        expr: |
          job:http_errors:rate5m / job:http_requests:rate5m

      - record: job:http_request_duration_p99:rate5m
        expr: |
          histogram_quantile(0.99,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (job, service, le)
          )

      - record: job:http_request_duration_p95:rate5m
        expr: |
          histogram_quantile(0.95,
            sum(rate(http_request_duration_seconds_bucket[5m])) by (job, service, le)
          )
YAML
  echo "✓ Created recording rules: $file"
}

# Scaffold: SLO alert rules (burn rate)
# Usage: gen-slo-alerts <service-name> [target-ratio]
gen-slo-alerts() {
  local svc="${1:?Usage: gen-slo-alerts <service-name> [target-ratio (e.g. 0.999)]}"
  local target="${2:-0.999}"
  local error_budget=$(echo "1 - $target" | bc -l)
  local file="${svc}-slo-alerts.yml"
  cat > "$file" <<YAML
groups:
  - name: slo_${svc}
    rules:
      # Fast burn: 2% of error budget consumed in 1 hour
      - alert: SLO_FastBurn_${svc}
        expr: |
          (
            job:http_error_ratio:rate5m{service="${svc}"} > (14.4 * ${error_budget})
          ) and (
            job:http_error_ratio:rate5m{service="${svc}"} > (14.4 * ${error_budget})
          )
        for: 2m
        labels:
          severity: critical
          service: "${svc}"
          slo: "availability"
        annotations:
          summary: "Fast burn: SLO error budget burning too fast for ${svc}"
          description: "Error rate {{ \$value | humanizePercentage }} exceeds fast-burn threshold"
          runbook_url: "https://wiki.internal/runbooks/slo-${svc}"

      # Slow burn: 5% of error budget consumed in 6 hours
      - alert: SLO_SlowBurn_${svc}
        expr: |
          job:http_error_ratio:rate5m{service="${svc}"} > (6 * ${error_budget})
        for: 15m
        labels:
          severity: warning
          service: "${svc}"
          slo: "availability"
        annotations:
          summary: "Slow burn: SLO error budget draining for ${svc}"
          description: "Sustained error rate {{ \$value | humanizePercentage }}"
YAML
  echo "✓ Created SLO alerts: $file"
}

# Scaffold: Tempo config
# Usage: gen-tempo-config [filename]
gen-tempo-config() {
  local file="${1:-tempo.yml}"
  cat > "$file" <<'YAML'
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

ingester:
  max_block_duration: 5m

storage:
  trace:
    backend: local
    local:
      path: /var/tempo/traces
    wal:
      path: /var/tempo/wal

metrics_generator:
  registry:
    external_labels:
      source: tempo
  storage:
    path: /var/tempo/generator/wal
    remote_write:
      - url: http://prometheus:9090/api/v1/write
        send_exemplars: true

overrides:
  metrics_generator_processors:
    - service-graphs
    - span-metrics
YAML
  echo "✓ Created Tempo config: $file"
}

# =============================================================================
#  HELP
# =============================================================================

# Display all functions in this file grouped by section
help-sre() {
  echo "\n╔══════════════════════════════════════════════════════╗"
  echo   "║         SRE / Observability Helpers (sre.zsh)        ║"
  echo   "╚══════════════════════════════════════════════════════╝\n"
  echo "── Terraform ──────────────────────────────────────────"
  echo "  tf-new-aws <name>           Scaffold AWS Terraform module"
  echo "  tf-new-s3 <name>            Scaffold S3 bucket module"
  echo ""
  echo "── Kubernetes ─────────────────────────────────────────"
  echo "  klog <selector> [ns]        Stream pod logs by label"
  echo "  kpod-debug <pod> [ns]       Describe pod + events"
  echo "  ktop-ns [ns]                Top pods sorted by CPU"
  echo "  kscale <deploy> <n> [ns]    Scale deployment"
  echo "  ksecret <name> <key> [ns]   Decode secret value"
  echo "  kall [ns]                   Get all resources in namespace"
  echo "  ksh <pod> [ns] [shell]      Exec into container"
  echo "  kyaml <type> <name> [ns]    Get resource YAML"
  echo "  kpf-svc <svc> <ports> [ns]  Port-forward a service"
  echo "  krollout-all [ns]           Rollout status all deploys"
  echo ""
  echo "── AWS ────────────────────────────────────────────────"
  echo "  aws-profile <name>          Switch AWS_PROFILE"
  echo "  aws-eks-login <cluster>     Update kubeconfig for EKS"
  echo "  aws-eks-info [region]       List EKS clusters"
  echo "  aws-logs <group> [mins]     Tail CloudWatch log group"
  echo "  aws-ec2-list                List EC2 instances"
  echo "  aws-ecr-list                List ECR repositories"
  echo ""
  echo "── Prometheus ─────────────────────────────────────────"
  echo "  prom-query '<expr>'         Instant PromQL query"
  echo "  prom-range '<expr>' [mins]  Range PromQL query"
  echo "  prom-targets                List active scrape targets"
  echo "  prom-alerts                 Show firing alerts"
  echo "  prom-check                  Validate config + rules"
  echo ""
  echo "── Loki ───────────────────────────────────────────────"
  echo "  loki-tail '{selector}'      Tail logs (LogQL)"
  echo "  loki-query '{selector}' [m] Query logs (last N mins)"
  echo "  loki-labels                 List Loki labels"
  echo "  loki-label-values <label>   List label values"
  echo ""
  echo "── Scaffolding — K8s ──────────────────────────────────"
  echo "  gen-k8s-deploy <app>        Kubernetes Deployment YAML"
  echo "  gen-k8s-svc <app>           Kubernetes Service YAML"
  echo "  gen-k8s-hpa <app>           HorizontalPodAutoscaler YAML"
  echo "  gen-k8s-pdb <app>           PodDisruptionBudget YAML"
  echo ""
  echo "── Scaffolding — Observability ────────────────────────"
  echo "  gen-prom-config [file]      Prometheus prometheus.yml"
  echo "  gen-prom-alert <name>       Prometheus alert rule"
  echo "  gen-recording-rules [app]   RED metrics recording rules"
  echo "  gen-slo-alerts <svc>        SLO burn-rate alert rules"
  echo "  gen-loki-config [file]      Loki loki-config.yml"
  echo "  gen-tempo-config [file]     Tempo tempo.yml"
  echo "  gen-alloy-config [file]     Grafana Alloy config.alloy"
  echo ""
  echo "Run: help-all [terraform|aws|k8s|prometheus|loki|docker|wizards]"
  echo ""
}
