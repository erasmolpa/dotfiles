# =============================================================================
#  Aliases — General + SRE/CloudOps/Observability
# =============================================================================

# ── Shell shortcuts ──────────────────────────────────────────────────────────
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="source $HOME/.zshrc"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="/opt/homebrew/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias la="ls -lah"
alias shrug="echo '¯\\_(ツ)_/¯' | pbcopy"

# ── Navigation ───────────────────────────────────────────────────────────────
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias projects="cd $HOME/Code"
alias sites="cd $HOME/Herd"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias md='mkdir -p'

# ── Clipboard ────────────────────────────────────────────────────────────────
alias cb='pbcopy'
alias cbp='pbpaste'

# ── Quick config edits ───────────────────────────────────────────────────────
alias zshrc='${EDITOR:-code} ~/.zshrc'
alias aliases='${EDITOR:-code} $DOTFILES/config/zsh/helpers/aliases.zsh'
alias sre='${EDITOR:-code} $DOTFILES/config/zsh/helpers/sre.zsh'

# ── intellij ─────────────────────────────────────────────────────────────────
alias intellij='open -a "/Applications/IntelliJ IDEA Community Edition.app" "$(pwd)"'

# ── Git ──────────────────────────────────────────────────────────────────────
alias gst="git status"
alias gb="git branch"
alias gc="git checkout"
alias gcb="git checkout -b"
alias gl="git log --oneline --decorate --color"
alias gll="git log --graph --oneline --decorate --all --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force-with-lease"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"
alias compile="commit 'compile'"
alias version="commit 'version'"

# ── JS / Node ────────────────────────────────────────────────────────────────
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias watch="npm run watch"

# ── Docker ───────────────────────────────────────────────────────────────────
alias d="docker"
alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcl="docker compose logs -f"
alias dcr="docker compose restart"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dpsa="docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dstop="docker stop \$(docker ps -q)"
alias dclean="docker system prune -af --volumes"
alias dimg="docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'"
alias dlogs="docker logs -f"
alias dexec="docker exec -it"

# ── Kubernetes ───────────────────────────────────────────────────────────────
alias k="kubectl"
alias kctx="kubectx"
alias kns="kubens"
alias kgp="kubectl get pods"
alias kgpa="kubectl get pods -A"
alias kgpw="kubectl get pods -w"
alias kgs="kubectl get svc"
alias kgsa="kubectl get svc -A"
alias kgd="kubectl get deploy"
alias kgda="kubectl get deploy -A"
alias kgn="kubectl get nodes"
alias kgno="kubectl get nodes -o wide"
alias kgcm="kubectl get configmap"
alias kgsec="kubectl get secret"
alias kging="kubectl get ingress -A"
alias kghpa="kubectl get hpa -A"
alias kgpdb="kubectl get pdb -A"
alias kgcrd="kubectl get crd"
alias kgns="kubectl get namespaces"
alias kga="kubectl get all -A"
alias kdp="kubectl describe pod"
alias kdd="kubectl describe deploy"
alias kds="kubectl describe svc"
alias kdn="kubectl describe node"
alias kdcm="kubectl describe configmap"
alias kdelp="kubectl delete pod"
alias kdeld="kubectl delete deploy"
alias kaf="kubectl apply -f"
alias kdf="kubectl delete -f"
alias klogs="kubectl logs -f"
alias klogsall="kubectl logs -f --all-containers"
alias kexec="kubectl exec -it"
alias kpf="kubectl port-forward"
alias krollout="kubectl rollout status"
alias krestart="kubectl rollout restart deploy"
alias ktop="kubectl top pods -A"
alias ktopm="kubectl top nodes"
alias kevents="kubectl get events -A --sort-by='.lastTimestamp'"
alias krun="kubectl run tmp-debug --image=busybox --rm -it --restart=Never -- sh"

# ── Helm ─────────────────────────────────────────────────────────────────────
alias h="helm"
alias hls="helm list -A"
alias hup="helm upgrade --install"
alias hdry="helm upgrade --install --dry-run"
alias hval="helm show values"
alias hrep="helm repo update"
alias hlint="helm lint"
alias hpkg="helm package"
alias hdep="helm dependency update"
alias hstatus="helm status"

# ── Terraform ────────────────────────────────────────────────────────────────
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias tfda="terraform destroy -auto-approve"
alias tffmt="terraform fmt -recursive"
alias tfval="terraform validate"
alias tfout="terraform output"
alias tfstate="terraform state list"
alias tfshow="terraform show"
alias tfws="terraform workspace"
alias tfwsl="terraform workspace list"
alias tfwss="terraform workspace select"
alias tginit="terragrunt init"
alias tgplan="terragrunt plan"
alias tgapply="terragrunt apply"

# ── AWS ──────────────────────────────────────────────────────────────────────
alias awswho="aws sts get-caller-identity"
alias awsregion="aws configure get region"
alias awsprofile="echo \$AWS_PROFILE"
alias eksList="aws eks list-clusters"
alias s3ls="aws s3 ls"
alias s3mb="aws s3 mb"
alias ec2ls="aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"

# ── Observability CLI ────────────────────────────────────────────────────────
alias prom-open="open \${GRAFANA_URL:-http://localhost:3000}"
alias prom-ui="open \${PROM_URL:-http://localhost:9090}"
alias loki-ui="open \${LOKI_URL:-http://localhost:3100}"
alias tempo-ui="open \${TEMPO_URL:-http://localhost:3200}"
alias alertmgr="open \${ALERTMANAGER_URL:-http://localhost:9093}"
alias alloy-ui="open http://localhost:12345"
alias cadvisor="open http://localhost:8082"
alias check-prom="promtool check config prometheus.yml"
alias check-rules="promtool check rules"
alias check-alert="promtool check rules alerting_rules.yml"

# ── k9s / Stern ──────────────────────────────────────────────────────────────
alias k9="k9s"
alias k9n="k9s --namespace"
alias stern="stern"
alias logs="stern . --tail=100"

# ── Load testing ─────────────────────────────────────────────────────────────
alias k6run="k6 run"
alias k6cloud="k6 cloud"

# ── Misc utilities ───────────────────────────────────────────────────────────
alias j="jq"
alias y="yq"
alias ports="lsof -i -P -n | grep LISTEN"
alias myip="curl -s https://ipinfo.io/ip && echo"
alias weather="curl -s wttr.in"
alias clock="date '+%Y-%m-%d %H:%M:%S %Z'"
alias epoch="date +%s"
alias sizeof="du -sh"
alias treedir="find . -type d | sed -e 's/[^-][^\/]*\// |/g' -e 's/|\([^ ]\)/|-\1/'"
