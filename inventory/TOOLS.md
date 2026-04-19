# Inventory: Tools & Configurations

Checklist and map of this dotfiles repo. **`bin/macctl`** applies **`inventory/`** through **`modules/`** + **`core/`**.

---

## Declarative inventory (`inventory/`)
- `inventory/brew/Brewfile` — taps, formulae, `mas`, VS Code extensions
- `inventory/brew/casks.txt` — cask tokens
- `inventory/python/requirements.txt` — pip (module **python**)
- `inventory/node/global-packages.txt` — npm globals (module **node**)
- `inventory/golang/formulae.txt` — extra brew formulae (module **golang**)
- `inventory/ia/manifest.txt` / `uv-packages.txt` — module **ia**
- `state/*.txt` — snapshots (`macctl sync`; gitignored except `.gitkeep`)

---

## Core tools (via Brewfile + macctl)
- Homebrew, Oh My Zsh, jq, yq, kubectl, terraform, docker, python, uv, node, …
- Full list: `inventory/brew/Brewfile` + `casks.txt`

---

## Helpers & wizards
- `config/zsh/helpers/*.zsh` (sre, aliases, cheatsheet, path)
- `config/zsh/wizards/wizards.zsh`
- Loaded from `config/zsh/.zshrc` (`ZSH_CUSTOM=$DOTFILES/config/zsh`)

---

## Control plane
- `bin/macctl` — `plan`, `apply`, `doctor`, `sync`, `import`, `lint` (ShellCheck; install with `brew install shellcheck`)
- `core/module-order` — load order for `modules/<name>.sh`
- `bootstrap/setup.sh` — first-time macOS bootstrap + symlinks + `macctl apply`
- `bootstrap/pyenv-setup.sh` — pyenv / uv / default Python version
- `bootstrap/post-setup.sh` — updates & diagnostics
- `bootstrap/clone-repos.sh` — personal repos

---

## Dotfiles layout
- `config/zsh/.zshrc` → `~/.zshrc`
- `config/git/*` → `~/.gitconfig`, `~/.gitignore_global`
- `config/mac/.macos` → `~/.macos` (symlink; apply manually if desired)
- Repo root: `.mackup.cfg`, `.pre-commit.yml`, `install.sh`

---

## Usage
- `docs/USAGE.md`, `docs/MACCTL-ARCHITECTURE.md`, `README.md`

---

**Checklist for a new Mac:**
- [ ] Clone to `~/.dotfiles`
- [ ] `./install.sh`
- [ ] `./bootstrap/post-setup.sh`
- [ ] Mackup restore (optional)
- [ ] New shell: verify helpers / `macctl doctor`
