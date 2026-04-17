# =============================================================================
#  Interactive Wizards & Guided Helpers
# =============================================================================
#  Auto-loaded by oh-my-zsh via ZSH_CUSTOM=$DOTFILES
#
#  Usage:
#    help-wizards       — List all wizards
#    wiz-k8s-deploy     — Kubernetes deployment wizard
#    wiz-k8s-debug      — Kubernetes troubleshooting guide
#    wiz-k8s-expose     — Expose a service
#    wiz-pql            — PromQL query builder
#    wiz-slo            — SLO/SLI calculator & generator
#    wiz-alert          — Prometheus alert rule builder
#    wiz-recording-rule — Prometheus recording rule builder
#    wiz-logql          — LogQL query builder
#    wiz-traceql        — TraceQL query builder
#    wiz-grafana-dash   — Grafana dashboard skeleton
#    wiz-tf-eks         — Terraform EKS module generator
#    wiz-tf-monitoring  — Terraform monitoring stack generator
#    wiz-oncall         — On-call triage checklist
#    wiz-capacity       — Capacity planning helper
#    wiz-cost-audit     — Observability cost audit checklist
# =============================================================================

help-wizards() {
  echo "\n╔══════════════════════════════════════════════════════╗"
  echo   "║              Interactive Wizards                     ║"
  echo   "╚══════════════════════════════════════════════════════╝\n"
  echo "  wiz-k8s-deploy     Kubernetes deployment + service + HPA"
  echo "  wiz-k8s-debug      K8s pod troubleshooting checklist"
  echo "  wiz-k8s-expose     Expose a service (ClusterIP/LB/Ingress)"
  echo "  wiz-pql            PromQL query builder (RED / SLO)"
  echo "  wiz-slo            SLO/SLI calculator & config generator"
  echo "  wiz-alert          Prometheus alert rule builder"
  echo "  wiz-recording-rule Recording rule builder"
  echo "  wiz-logql          LogQL query builder"
  echo "  wiz-traceql        TraceQL query builder"
  echo "  wiz-grafana-dash   Grafana dashboard JSON skeleton"
  echo "  wiz-tf-eks         Terraform EKS cluster module"
  echo "  wiz-tf-monitoring  Terraform monitoring stack (Helm)"
  echo "  wiz-oncall         On-call triage checklist"
  echo "  wiz-capacity       Capacity planning helper"
  echo "  wiz-cost-audit     Observability cost audit"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-k8s-deploy — Interactive K8s Deployment + Service + HPA generator
# ─────────────────────────────────────────────────────────────────────────────
wiz-k8s-deploy() {
  echo "\n=== Kubernetes Deployment Wizard ===\n"
  printf "App name: "; read -r app
  printf "Docker image (e.g. nginx:latest): "; read -r image
  printf "Replicas [2]: "; read -r replicas; replicas="${replicas:-2}"
  printf "Container port [8080]: "; read -r port; port="${port:-8080}"
  printf "Namespace [default]: "; read -r ns; ns="${ns:-default}"
  printf "Add HPA? (y/N): "; read -r hpa
  printf "Add PDB? (y/N): "; read -r pdb

  local dir="${app}-k8s"
  mkdir -p "$dir"

  # Deployment
  cat > "$dir/deployment.yaml" <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${app}
  namespace: ${ns}
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
        prometheus.io/port: "${port}"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: ${app}
          image: ${image}
          ports:
            - containerPort: ${port}
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
              port: ${port}
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: ${port}
            initialDelaySeconds: 15
            periodSeconds: 20
YAML

  # Service
  cat > "$dir/service.yaml" <<YAML
apiVersion: v1
kind: Service
metadata:
  name: ${app}
  namespace: ${ns}
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

  # HPA
  if [[ "$hpa" =~ ^[Yy]$ ]]; then
    printf "Min replicas [2]: "; read -r minr; minr="${minr:-2}"
    printf "Max replicas [10]: "; read -r maxr; maxr="${maxr:-10}"
    printf "CPU target % [70]: "; read -r cpu; cpu="${cpu:-70}"
    cat > "$dir/hpa.yaml" <<YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ${app}
  namespace: ${ns}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${app}
  minReplicas: ${minr}
  maxReplicas: ${maxr}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: ${cpu}
YAML
  fi

  # PDB
  if [[ "$pdb" =~ ^[Yy]$ ]]; then
    cat > "$dir/pdb.yaml" <<YAML
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: ${app}
  namespace: ${ns}
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: ${app}
YAML
  fi

  echo "\n✓ Generated in ./${dir}/"
  ls -1 "$dir/"
  echo "\nApply with: kubectl apply -f ${dir}/ -n ${ns}"
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-k8s-debug — Pod troubleshooting interactive checklist
# ─────────────────────────────────────────────────────────────────────────────
wiz-k8s-debug() {
  echo "\n=== Kubernetes Pod Troubleshooting Wizard ===\n"
  printf "Pod name (or partial): "; read -r pod
  printf "Namespace [default]: "; read -r ns; ns="${ns:-default}"

  echo "\n[1/6] Finding pod..."
  kubectl get pod -n "$ns" | grep "$pod" || echo "  ⚠ Pod not found"

  echo "\n[2/6] Describing pod..."
  kubectl describe pod "$pod" -n "$ns" 2>/dev/null | tail -40

  echo "\n[3/6] Recent events..."
  kubectl get events -n "$ns" --sort-by='.lastTimestamp' | tail -15

  echo "\n[4/6] Container logs (last 50 lines)..."
  kubectl logs "$pod" -n "$ns" --tail=50 2>/dev/null || echo "  ⚠ Could not get logs"

  echo "\n[5/6] Resource usage..."
  kubectl top pod "$pod" -n "$ns" 2>/dev/null || echo "  ⚠ Metrics server not available"

  echo "\n[6/6] Checklist:"
  echo "  □ Image pull errors?  → kubectl describe pod | grep -A5 Events"
  echo "  □ OOMKilled?          → kubectl get pod -o json | jq '.status.containerStatuses[].lastState'"
  echo "  □ CrashLoopBackOff?   → kubectl logs --previous <pod>"
  echo "  □ Pending (no nodes)? → kubectl describe node | grep Conditions"
  echo "  □ Readiness failing?  → check /health endpoint responds correctly"
  echo "  □ Resource limits hit?→ adjust requests/limits in deployment spec"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-k8s-expose — Service exposure wizard
# ─────────────────────────────────────────────────────────────────────────────
wiz-k8s-expose() {
  echo "\n=== Service Exposure Wizard ===\n"
  printf "App/deployment name: "; read -r app
  printf "Namespace [default]: "; read -r ns; ns="${ns:-default}"
  printf "Port: "; read -r port
  echo "Exposure type:"
  echo "  1) ClusterIP (internal only)"
  echo "  2) NodePort (accessible via node IP)"
  echo "  3) LoadBalancer (cloud LB, external IP)"
  echo "  4) Ingress (HTTP/HTTPS routing)"
  printf "Choose [1-4]: "; read -r choice

  case "$choice" in
    1)
      cat <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${app}
  namespace: ${ns}
spec:
  selector:
    app: ${app}
  ports:
    - port: ${port}
      targetPort: ${port}
  type: ClusterIP
YAML
      ;;
    2)
      printf "NodePort [30000-32767]: "; read -r nodeport
      cat <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${app}
  namespace: ${ns}
spec:
  selector:
    app: ${app}
  ports:
    - port: ${port}
      targetPort: ${port}
      nodePort: ${nodeport}
  type: NodePort
YAML
      ;;
    3)
      cat <<YAML

apiVersion: v1
kind: Service
metadata:
  name: ${app}
  namespace: ${ns}
spec:
  selector:
    app: ${app}
  ports:
    - port: 80
      targetPort: ${port}
  type: LoadBalancer
YAML
      ;;
    4)
      printf "Hostname (e.g. api.example.com): "; read -r host
      printf "Path prefix [/]: "; read -r path; path="${path:-/}"
      printf "TLS secret name (blank to skip): "; read -r tlssecret
      local tls_block=""
      if [[ -n "$tlssecret" ]]; then
        tls_block="  tls:\n    - hosts:\n        - ${host}\n      secretName: ${tlssecret}"
      fi
      cat <<YAML

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${app}
  namespace: ${ns}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
${tls_block}
  rules:
    - host: ${host}
      http:
        paths:
          - path: ${path}
            pathType: Prefix
            backend:
              service:
                name: ${app}
                port:
                  number: ${port}
YAML
      ;;
  esac
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-pql — Interactive PromQL query builder
# ─────────────────────────────────────────────────────────────────────────────
wiz-pql() {
  echo "\n=== PromQL Query Builder ===\n"
  echo "Query types:"
  echo "  1) Request rate (RPS)"
  echo "  2) Error rate (%)"
  echo "  3) Latency percentile (p50/p95/p99)"
  echo "  4) SLI Availability (30d)"
  echo "  5) SLO Burn rate"
  echo "  6) Container CPU usage"
  echo "  7) Container Memory usage"
  echo "  8) Custom / show examples"
  printf "Choose [1-8]: "; read -r choice

  printf "Service label value (blank for all): "; read -r svc
  local svc_filter=""
  [[ -n "$svc" ]] && svc_filter=', service="'${svc}'"'

  printf "Time window [5m]: "; read -r window; window="${window:-5m}"

  echo "\n─── Generated PromQL ───"
  case "$choice" in
    1)
      echo "sum(rate(http_requests_total{job=~\".+\"${svc_filter}}[${window}])) by (service)"
      ;;
    2)
      echo "sum(rate(http_requests_total{status_code=~\"5..\"${svc_filter}}[${window}])) by (service)"
      echo "/"
      echo "sum(rate(http_requests_total{job=~\".+\"${svc_filter}}[${window}])) by (service) * 100"
      ;;
    3)
      printf "Quantile (50/95/99): "; read -r q; q="${q:-99}"
      echo "histogram_quantile(0.${q}, sum(rate(http_request_duration_seconds_bucket{job=~\".+\"${svc_filter}}[${window}])) by (le, service))"
      ;;
    4)
      echo "1 - ("
      echo "  sum(rate(http_requests_total{status_code=~\"5..\"${svc_filter}}[30d]))"
      echo "  /"
      echo "  sum(rate(http_requests_total{job=~\".+\"${svc_filter}}[30d]))"
      echo ")"
      ;;
    5)
      printf "Error budget (e.g. 0.001 for 99.9% SLO): "; read -r budget; budget="${budget:-0.001}"
      echo "# Fast burn (14.4x budget rate):"
      echo "sum(rate(http_requests_total{status_code=~\"5..\"${svc_filter}}[1h])) by (service)"
      echo "/ sum(rate(http_requests_total{job=~\".+\"${svc_filter}}[1h])) by (service)"
      echo "> (14.4 * ${budget})"
      ;;
    6)
      printf "Container name: "; read -r cname
      echo "sum(rate(container_cpu_usage_seconds_total{container=\"${cname}\"}[${window}])) by (pod, namespace)"
      ;;
    7)
      printf "Container name: "; read -r cname
      echo "sum(container_memory_working_set_bytes{container=\"${cname}\"}) by (pod, namespace)"
      ;;
    8)
      echo "Example queries:"
      echo "  # Request rate by service"
      echo "  sum(rate(http_requests_total[5m])) by (service)"
      echo ""
      echo "  # P99 latency"
      echo "  histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service))"
      echo ""
      echo "  # Pods not ready"
      echo "  kube_pod_status_ready{condition=\"false\"}"
      echo ""
      echo "  # Node CPU"
      echo "  100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
      ;;
  esac
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-slo — SLO/SLI calculator and config generator
# ─────────────────────────────────────────────────────────────────────────────
wiz-slo() {
  echo "\n=== SLO / SLI Wizard ===\n"
  printf "Service name: "; read -r svc
  printf "SLO target % (e.g. 99.9): "; read -r slo; slo="${slo:-99.9}"
  printf "Window in days [30]: "; read -r window; window="${window:-30}"

  local error_budget=$(echo "scale=6; (100 - $slo) / 100" | bc)
  local allowed_downtime_mins=$(echo "scale=2; $window * 24 * 60 * (100 - $slo) / 100" | bc)

  echo "\n─── SLO Calculations ───────────────────────────────────"
  echo "  Service:          $svc"
  echo "  Target:           ${slo}%"
  echo "  Error budget:     ${error_budget} ($(echo "scale=4; $error_budget * 100" | bc)%)"
  echo "  Allowed downtime: ${allowed_downtime_mins} minutes in ${window} days"

  echo "\n─── SLI PromQL (Availability) ──────────────────────────"
  echo "  1 - ("
  echo "    sum(rate(http_requests_total{status_code=~\"5..\",service=\"${svc}\"}[${window}d]))"
  echo "    / sum(rate(http_requests_total{service=\"${svc}\"}[${window}d]))"
  echo "  )"

  echo "\n─── Alert Thresholds ───────────────────────────────────"
  local fast_burn=$(echo "scale=6; 14.4 * $error_budget" | bc)
  local slow_burn=$(echo "scale=6; 6 * $error_budget" | bc)
  echo "  Fast burn (1h window): > $fast_burn (14.4x)"
  echo "  Slow burn (6h window): > $slow_burn (6x)"

  printf "\nGenerate SLO alert file? (y/N): "; read -r gen
  if [[ "$gen" =~ ^[Yy]$ ]]; then
    gen-slo-alerts "$svc" "0.$(printf '%03d' $(echo "scale=0; (100 - $slo) * 10" | bc))"
  fi
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-alert — Prometheus alert rule builder
# ─────────────────────────────────────────────────────────────────────────────
wiz-alert() {
  echo "\n=== Prometheus Alert Rule Builder ===\n"
  printf "Alert name: "; read -r name
  printf "Severity (critical/warning/info) [warning]: "; read -r severity; severity="${severity:-warning}"
  printf "Service: "; read -r svc

  echo "Metric type:"
  echo "  1) High error rate (5xx)"
  echo "  2) High latency (p99)"
  echo "  3) Service down (up == 0)"
  echo "  4) High CPU"
  echo "  5) High memory"
  echo "  6) Custom expression"
  printf "Choose [1-6]: "; read -r mtype

  printf "Threshold value: "; read -r threshold
  printf "Duration (e.g. 5m) [5m]: "; read -r duration; duration="${duration:-5m}"

  local expr=""
  case "$mtype" in
    1) expr="sum(rate(http_requests_total{status_code=~\"5..\",service=\"${svc}\"}[5m])) / sum(rate(http_requests_total{service=\"${svc}\"}[5m])) > ${threshold}" ;;
    2) expr="histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=\"${svc}\"}[5m])) by (le)) > ${threshold}" ;;
    3) expr="up{job=\"${svc}\"} == 0" ;;
    4) expr="sum(rate(container_cpu_usage_seconds_total{container=\"${svc}\"}[5m])) by (pod) > ${threshold}" ;;
    5) expr="sum(container_memory_working_set_bytes{container=\"${svc}\"}) by (pod) > ${threshold}" ;;
    6) printf "PromQL expression: "; read -r expr ;;
  esac

  printf "Runbook URL [https://wiki.internal/runbooks/${name}]: "; read -r runbook
  runbook="${runbook:-https://wiki.internal/runbooks/${name}}"

  echo "\n─── Generated Alert Rule ───"
  cat <<YAML
- alert: ${name}
  expr: |
    ${expr}
  for: ${duration}
  labels:
    severity: ${severity}
    service: "${svc}"
  annotations:
    summary: "${name} on ${svc}"
    description: "Value {{ \$value | humanize }} exceeded threshold for ${svc}"
    runbook_url: "${runbook}"
YAML
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-recording-rule — Prometheus recording rule builder
# ─────────────────────────────────────────────────────────────────────────────
wiz-recording-rule() {
  echo "\n=== Prometheus Recording Rule Builder ===\n"
  printf "Group name: "; read -r group
  printf "Rule name (e.g. job:http_requests:rate5m): "; read -r rulename
  printf "PromQL expression: "; read -r expr
  printf "Interval [30s]: "; read -r interval; interval="${interval:-30s}"

  echo "\n─── Generated Recording Rule ───"
  cat <<YAML
groups:
  - name: ${group}
    interval: ${interval}
    rules:
      - record: ${rulename}
        expr: |
          ${expr}
YAML
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-logql — LogQL query builder
# ─────────────────────────────────────────────────────────────────────────────
wiz-logql() {
  echo "\n=== LogQL Query Builder ===\n"
  printf "App label value: "; read -r app
  printf "Namespace: "; read -r ns
  printf "Log level filter (error/warn/info/blank): "; read -r level

  local selector="{namespace=\"${ns}\",app=\"${app}\"}"
  local filter=""
  [[ -n "$level" ]] && filter=" |= \"${level}\""

  echo "\n── Query types ────────────────────────────────────────"
  echo "  1) Stream logs (tail)"
  echo "  2) Count errors per minute"
  echo "  3) Parse JSON and filter field"
  echo "  4) Rate of log lines"
  printf "Choose [1-4]: "; read -r qtype

  echo "\n─── Generated LogQL ───"
  case "$qtype" in
    1)
      echo "${selector}${filter}"
      echo "\nCommand: logcli query --addr=${LOKI_URL} --tail '${selector}${filter}'"
      ;;
    2)
      echo "sum(rate(${selector} |= \"error\" [1m])) by (app)"
      ;;
    3)
      printf "JSON field to filter: "; read -r field
      printf "Field value: "; read -r fieldval
      echo "${selector} | json | ${field}=\"${fieldval}\""
      ;;
    4)
      printf "Window [5m]: "; read -r win; win="${win:-5m}"
      echo "sum(rate(${selector}${filter} [${win}])) by (app)"
      ;;
  esac
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-traceql — TraceQL query builder
# ─────────────────────────────────────────────────────────────────────────────
wiz-traceql() {
  echo "\n=== TraceQL Query Builder ===\n"
  echo "Query types:"
  echo "  1) Find traces by service"
  echo "  2) Find slow traces (duration > threshold)"
  echo "  3) Find error traces"
  echo "  4) Find traces by span attribute"
  echo "  5) Find traces from HTTP path"
  printf "Choose [1-5]: "; read -r qtype

  echo "\n─── Generated TraceQL ───"
  case "$qtype" in
    1)
      printf "Service name: "; read -r svc
      echo "{ .service.name = \"${svc}\" }"
      ;;
    2)
      printf "Service name: "; read -r svc
      printf "Duration threshold (e.g. 500ms, 2s): "; read -r dur
      echo "{ .service.name = \"${svc}\" && duration > ${dur} }"
      ;;
    3)
      printf "Service name: "; read -r svc
      echo "{ .service.name = \"${svc}\" && status = error }"
      ;;
    4)
      printf "Attribute key (e.g. http.status_code): "; read -r key
      printf "Attribute value: "; read -r val
      echo "{ .${key} = \"${val}\" }"
      ;;
    5)
      printf "HTTP path pattern (e.g. /api/users): "; read -r path
      echo "{ .http.route = \"${path}\" }"
      echo "# Or with regex:"
      echo "{ .http.url =~ \".*${path}.*\" }"
      ;;
  esac
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-grafana-dash — Grafana dashboard JSON skeleton
# ─────────────────────────────────────────────────────────────────────────────
wiz-grafana-dash() {
  echo "\n=== Grafana Dashboard Skeleton ===\n"
  printf "Dashboard title: "; read -r title
  printf "Service name: "; read -r svc
  printf "Output file [dashboard.json]: "; read -r outfile; outfile="${outfile:-dashboard.json}"

  cat > "$outfile" <<JSON
{
  "__inputs": [],
  "__requires": [],
  "annotations": { "list": [] },
  "description": "RED metrics for ${svc}",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 1,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": { "type": "prometheus", "uid": "\${datasource}" },
      "gridPos": { "h": 8, "w": 8, "x": 0, "y": 0 },
      "id": 1,
      "title": "Request Rate",
      "type": "timeseries",
      "targets": [{
        "expr": "sum(rate(http_requests_total{service=\"${svc}\"}[\$__rate_interval])) by (service)",
        "legendFormat": "{{service}}"
      }]
    },
    {
      "datasource": { "type": "prometheus", "uid": "\${datasource}" },
      "gridPos": { "h": 8, "w": 8, "x": 8, "y": 0 },
      "id": 2,
      "title": "Error Rate",
      "type": "timeseries",
      "targets": [{
        "expr": "sum(rate(http_requests_total{service=\"${svc}\",status_code=~\"5..\"}[\$__rate_interval])) by (service) / sum(rate(http_requests_total{service=\"${svc}\"}[\$__rate_interval])) by (service)",
        "legendFormat": "{{service}} error%"
      }]
    },
    {
      "datasource": { "type": "prometheus", "uid": "\${datasource}" },
      "gridPos": { "h": 8, "w": 8, "x": 16, "y": 0 },
      "id": 3,
      "title": "P99 Latency",
      "type": "timeseries",
      "targets": [{
        "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=\"${svc}\"}[\$__rate_interval])) by (le, service))",
        "legendFormat": "p99 {{service}}"
      }]
    }
  ],
  "schemaVersion": 38,
  "tags": ["${svc}", "sre", "red"],
  "templating": {
    "list": [
      {
        "current": {},
        "hide": 0,
        "includeAll": false,
        "label": "Datasource",
        "name": "datasource",
        "options": [],
        "query": "prometheus",
        "refresh": 1,
        "type": "datasource"
      }
    ]
  },
  "time": { "from": "now-1h", "to": "now" },
  "timepicker": {},
  "timezone": "browser",
  "title": "${title}",
  "uid": "$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 10 2>/dev/null || echo 'dashboard01')",
  "version": 1
}
JSON
  echo "✓ Created: $outfile"
  echo "  Import via Grafana UI → Dashboards → Import → Upload JSON"
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-tf-eks — Terraform EKS module generator
# ─────────────────────────────────────────────────────────────────────────────
wiz-tf-eks() {
  echo "\n=== Terraform EKS Module Wizard ===\n"
  printf "Module directory name [eks-cluster]: "; read -r dir; dir="${dir:-eks-cluster}"
  printf "Cluster name: "; read -r cluster
  printf "AWS region [eu-west-1]: "; read -r region; region="${region:-eu-west-1}"
  printf "Kubernetes version [1.30]: "; read -r k8s_ver; k8s_ver="${k8s_ver:-1.30}"
  printf "Node instance type [t3.medium]: "; read -r instance; instance="${instance:-t3.medium}"
  printf "Min nodes [2]: "; read -r min_nodes; min_nodes="${min_nodes:-2}"
  printf "Max nodes [5]: "; read -r max_nodes; max_nodes="${max_nodes:-5}"

  mkdir -p "$dir"

  cat > "$dir/main.tf" <<TF
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state"
    key    = "eks/${cluster}/terraform.tfstate"
    region = "${region}"
  }
}

provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    main = {
      instance_types = [var.node_instance_type]
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.min_size
    }
  }

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "\${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["\${var.region}a", "\${var.region}b", "\${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}
TF

  cat > "$dir/variables.tf" <<TF
variable "region" {
  description = "AWS region"
  type        = string
  default     = "${region}"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "${cluster}"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "${k8s_ver}"
}

variable "node_instance_type" {
  description = "EC2 instance type for nodes"
  type        = string
  default     = "${instance}"
}

variable "min_size" {
  type    = number
  default = ${min_nodes}
}

variable "max_size" {
  type    = number
  default = ${max_nodes}
}
TF

  cat > "$dir/outputs.tf" <<TF
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${region} --name ${cluster}"
}
TF

  echo "\n✓ Created Terraform EKS module in ./${dir}/"
  ls -1 "$dir/"
  echo "\nNext: cd ${dir} && terraform init && terraform plan"
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-tf-monitoring — Terraform monitoring stack via Helm
# ─────────────────────────────────────────────────────────────────────────────
wiz-tf-monitoring() {
  echo "\n=== Terraform Monitoring Stack Wizard ===\n"
  printf "Module directory [monitoring-stack]: "; read -r dir; dir="${dir:-monitoring-stack}"
  printf "Namespace [monitoring]: "; read -r ns; ns="${ns:-monitoring}"
  printf "Include Grafana? (Y/n): "; read -r grafana; grafana="${grafana:-Y}"
  printf "Include Loki? (Y/n): "; read -r loki; loki="${loki:-Y}"
  printf "Include Tempo? (Y/n): "; read -r tempo; tempo="${tempo:-Y}"

  mkdir -p "$dir"

  cat > "$dir/main.tf" <<TF
terraform {
  required_version = ">= 1.5"
  required_providers {
    helm       = { source = "hashicorp/helm",       version = "~> 2.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
resource "helm_release" "kube_prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "58.0.0"

  values = [file("\${path.module}/values/prometheus.yaml")]
  wait   = true
  timeout = 600
}
TF

  mkdir -p "$dir/values"
  cat > "$dir/values/prometheus.yaml" <<YAML
prometheus:
  prometheusSpec:
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

grafana:
  enabled: true
  adminPassword: changeme
  sidecar:
    datasources:
      enabled: true

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
YAML

  cat > "$dir/variables.tf" <<TF
variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "${ns}"
}
TF

  echo "\n✓ Created monitoring Terraform module in ./${dir}/"
  ls -1 "$dir/"
  echo "\nNext: cd ${dir} && terraform init && terraform plan"
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-oncall — On-call triage checklist
# ─────────────────────────────────────────────────────────────────────────────
wiz-oncall() {
  echo "\n╔══════════════════════════════════════════════════════╗"
  echo   "║            On-Call Triage Checklist                  ║"
  echo   "╚══════════════════════════════════════════════════════╝\n"
  printf "Alert name / incident: "; read -r alert
  printf "Affected service: "; read -r svc
  printf "Severity (critical/warning): "; read -r sev; sev="${sev:-warning}"

  echo "\n[1] ACKNOWLEDGE"
  echo "  □ Ack the alert in PagerDuty/Alertmanager"
  echo "  □ Post in incident channel: 'Investigating $alert for $svc'"

  echo "\n[2] TRIAGE — Check the 4 golden signals"
  echo "  □ Latency:    histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{service=\"${svc}\"}[5m])) by (le))"
  echo "  □ Error rate: sum(rate(http_requests_total{service=\"${svc}\",status_code=~\"5..\"}[5m])) / sum(rate(http_requests_total{service=\"${svc}\"}[5m]))"
  echo "  □ Traffic:    sum(rate(http_requests_total{service=\"${svc}\"}[5m]))"
  echo "  □ Saturation: sum(container_memory_working_set_bytes{container=\"${svc}\"}) by (pod)"

  echo "\n[3] KUBERNETES CHECKS"
  echo "  □ kubectl get pods -A | grep -v Running | grep -v Completed"
  echo "  □ kubectl top nodes"
  echo "  □ kubectl get events -A --sort-by=.lastTimestamp | tail -20"

  echo "\n[4] LOGS"
  echo "  □ logcli query '{service=\"${svc}\"} |= \"error\"' --since=30m"
  echo "  □ stern ${svc} --tail=100 --since=30m"

  echo "\n[5] TRACES"
  echo "  □ Tempo: { .service.name = \"${svc}\" && status = error }"
  echo "  □ Check span duration > 2s"

  echo "\n[6] ESCALATE?"
  if [[ "$sev" == "critical" ]]; then
    echo "  ⚠ CRITICAL: If not resolved in 15 min → escalate to on-call lead"
  else
    echo "  ℹ Warning: Monitor, set 1h timer to re-evaluate"
  fi

  echo "\n[7] RESOLUTION"
  echo "  □ Document root cause"
  echo "  □ Write post-mortem (if critical)"
  echo "  □ Create follow-up tickets for systemic fixes"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-capacity — Capacity planning helper
# ─────────────────────────────────────────────────────────────────────────────
wiz-capacity() {
  echo "\n=== Capacity Planning Helper ===\n"
  printf "Service name: "; read -r svc
  printf "Current RPS: "; read -r rps
  printf "Expected RPS growth factor (e.g. 2.0 for 2x): "; read -r growth; growth="${growth:-1.5}"
  printf "Current CPU per pod (millicores): "; read -r cpu_per_pod
  printf "Current memory per pod (MB): "; read -r mem_per_pod
  printf "Current replicas: "; read -r replicas

  local new_rps=$(echo "scale=0; $rps * $growth / 1" | bc 2>/dev/null || echo "?")
  local new_replicas=$(echo "scale=0; $replicas * $growth / 1" | bc 2>/dev/null || echo "?")
  local new_cpu=$(echo "scale=0; $cpu_per_pod * $new_replicas / 1" | bc 2>/dev/null || echo "?")
  local new_mem=$(echo "scale=0; $mem_per_pod * $new_replicas / 1" | bc 2>/dev/null || echo "?")

  echo "\n─── Capacity Projection ─────────────────────────────"
  echo "  Current: ${rps} RPS / ${replicas} pods / ${cpu_per_pod}m CPU / ${mem_per_pod}MB mem each"
  echo "  At ${growth}x growth:"
  echo "    Expected RPS:     ${new_rps}"
  echo "    Recommended pods: ${new_replicas}"
  echo "    Total CPU:        ${new_cpu}m"
  echo "    Total memory:     ${new_mem}MB"

  echo "\n─── PromQL for capacity analysis ────────────────────"
  echo "  # Peak RPS last 7 days"
  echo "  max_over_time(sum(rate(http_requests_total{service=\"${svc}\"}[5m]))[7d:5m])"
  echo ""
  echo "  # CPU saturation trend"
  echo "  avg(rate(container_cpu_usage_seconds_total{container=\"${svc}\"}[5m])) by (pod)"
  echo ""
  echo "  # Memory trend"
  echo "  avg(container_memory_working_set_bytes{container=\"${svc}\"}) by (pod)"
  echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
#  wiz-cost-audit — Observability cost audit checklist
# ─────────────────────────────────────────────────────────────────────────────
wiz-cost-audit() {
  echo "\n╔══════════════════════════════════════════════════════╗"
  echo   "║         Observability Cost Audit Checklist           ║"
  echo   "╚══════════════════════════════════════════════════════╝\n"

  echo "── METRICS COSTS ──────────────────────────────────────"
  echo "  □ Check cardinality: high-cardinality labels inflate storage"
  echo "    PromQL: topk(10, count by (__name__)({__name__=~\".+\"}))"
  echo "  □ Review unused metrics: drop in scrape config with metric_relabel_configs"
  echo "  □ Use recording rules to pre-aggregate expensive queries"
  echo "  □ Review retention policy: is 15d enough for your SLO window?"
  echo "  □ Consider Mimir for cost-effective long-term storage (S3 backend)"
  echo ""

  echo "── LOGS COSTS ─────────────────────────────────────────"
  echo "  □ Drop DEBUG logs in production (pipeline_stages: drop)"
  echo "  □ Use structured metadata instead of high-cardinality labels"
  echo "  □ Review retention: distinguish hot (7d) vs warm (30d) vs cold (1y)"
  echo "  □ Implement log sampling for high-volume, low-value logs"
  echo "  □ Check total log volume: sum(rate(loki_distributor_bytes_received_total[1h]))"
  echo ""

  echo "── TRACES COSTS ───────────────────────────────────────"
  echo "  □ Use head-based sampling for predictable cost (probabilistic 10-20%)"
  echo "  □ Use tail-based sampling to keep 100% errors/slow traces"
  echo "  □ Drop health-check / ping spans (filteringprocessor in Alloy)"
  echo "  □ Review trace storage retention (7-14d is usually enough)"
  echo ""

  echo "── DATADOG COSTS ──────────────────────────────────────"
  echo "  □ Audit custom metrics: DD custom metrics > 100 cost extra"
  echo "  □ Review APM sampling rates per service"
  echo "  □ Use log exclusion filters for verbose services"
  echo "  □ Verify indexed log volume vs retention tier"
  echo "  □ Check synthetic monitor locations and frequency"
  echo "  □ Review DBM and NPM add-on usage"
  echo ""

  echo "── GENERAL ────────────────────────────────────────────"
  echo "  □ Set up cost monitoring alerts (budget thresholds)"
  echo "  □ Tag all resources with team/env/service for cost attribution"
  echo "  □ Review S3 storage costs for Mimir/Loki/Tempo backends"
  echo "  □ Enable compression (Snappy/LZ4) on all storage backends"
  echo ""
}
