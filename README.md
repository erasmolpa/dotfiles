# dotfiles (`~/.dotfiles`)

A complete, automated setup for a modern macOS development environment. This repository contains my personal dotfiles, Homebrew bundle, and scripts to configure tools for development, DevOps, and AI workflows.

---

## Features

- Automated installation of Homebrew, Oh My Zsh, and essential CLI tools
- Homebrew Bundle (`Brewfile`) for managing apps, fonts, and extensions
- Scripts for configuring Python, Go, AI/DevOps tools, and more
- macOS preferences and shell customizations
- Easy backup and restore of app settings with Mackup
- **SRE and observability helpers and wizards** loaded from `.zshrc` when `DOTFILES` is set (canonical path: `$HOME/.dotfiles`)
- **`bin/macctl`** — single CLI (`plan`, `apply`, `doctor`, `sync`, `lint`) over `core/` plus `modules/` plugins
- **Layout:** `config/` for dotfiles, `inventory/` for desired state, `state/` for snapshots and markers

---

## Getting Started

### 1. Clone the repository (canonical location)

```sh
git clone https://github.com/erasmolpa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

`config/zsh/.zshrc` expects `DOTFILES=$HOME/.dotfiles`. Keep the repo there so paths and symlinks stay consistent.

### 2. No Homebrew or no git yet (optional)

If you do not have the repo on disk but you have a copy of `bootstrap/pre-install.sh` (for example on a USB stick), run it from that copy: it installs Homebrew if missing, installs `git`, and clones this repository into `~/.dotfiles`. If you already used `git clone` in step 1, skip this block.

```sh
bash bootstrap/pre-install.sh
cd ~/.dotfiles && ./bootstrap/setup.sh
```

### 3. Main setup (Oh My Zsh, Homebrew, Brewfile, toolchains)

```sh
cd ~/.dotfiles
chmod +x install.sh bin/macctl bootstrap/*.sh modules/*.sh
./install.sh
```

What `bootstrap/setup.sh` does (it is invoked by `./install.sh`):

- Installs Oh My Zsh and Homebrew if they are missing
- Symlinks `config/zsh/.zshrc`, `config/git/*`, `config/mac/.macos`, `.mackup.cfg`, and related files into `$HOME`
- Runs `bin/macctl apply --only=brew`, then `bootstrap/pyenv-setup.sh` when present, then `macctl apply --only=golang,python,node,vim,ia`
- Creates work directories (`Work/mine`, `Code`, `Herd`, and so on)
- Runs `bootstrap/clone-repos.sh` for optional personal repositories

After setup, run `bin/macctl plan` to review diffs; see `docs/MACCTL-ARCHITECTURE.md`.

### 4. Post-setup (updates and diagnostics)

```sh
./bootstrap/post-setup.sh
```

Updates Homebrew, pipx, and global npm packages, runs optional checks (pre-commit, trivy, `brew doctor`), and refreshes `state/python-installed.txt` when Python pip is available.

### 5. Restore App Preferences (Optional)

If you use Mackup for syncing app settings:
```sh
mackup restore
```

---

## Project layout

| Path | Contents |
|------|----------|
| `bin/macctl` | CLI: `plan`, `apply`, `doctor`, `sync`, `lint` |
| `core/` | `helpers.sh`, `registry.sh`, `runner.sh`, `main.sh`, `module-order` — reconciliation engine |
| `modules/` | Plugins: `brew.sh`, `golang.sh`, `python.sh`, `node.sh`, `vim.sh`, `ia.sh` (each exposes `_get_desired`, `_get_current`, `_install`) |
| `config/zsh/` | `.zshrc`, `helpers/`, `wizards/`, `themes/`, `pyenv.zsh` |
| `config/git/` | `.gitconfig`, `.gitignore_global` |
| `config/mac/` | `.macos`, `.bash_profile` (when used) |
| `inventory/` | `brew/`, `python/`, `node/`, `golang/`, `ia/`, `vim/` — desired state |
| `bootstrap/` | `setup.sh`, `pre-install.sh`, `post-setup.sh`, `clone-repos.sh`, `pyenv-setup.sh` |
| `scripts/` | Small utilities (for example `ssh.sh`) |
| `bin/` | `macctl` and `.gitkeep` for extra binaries you add |
| `state/` | Snapshots and markers (`macctl sync`; typically gitignored) |
| Repo root | `Brewfile` → `inventory/brew/Brewfile`, `.mackup.cfg`, `.pre-commit.yml`, `install.sh` |

---

## Shell auto-load

`config/zsh/helpers/*.zsh` and `config/zsh/wizards/*.zsh` are loaded from `.zshrc` with `ZSH_CUSTOM=$DOTFILES/config/zsh` (themes under `config/zsh/themes/`).

---

## Usage & Checklist

- See `docs/USAGE.md` for step-by-step usage and troubleshooting.
- See `inventory/TOOLS.md` for a full inventory and checklist for a new Mac.

---

## Troubleshooting & Best Practices

- If a pre-commit hook fails, follow the error message for remediation (e.g., run `black .` or `ruff .` to auto-fix Python formatting).
- Use `brew doctor`, `./bin/macctl doctor`, `./bin/macctl lint`, and `./bootstrap/post-setup.sh` for diagnostics.
- For AI/agent tool errors, check that all dependencies are installed and review `ia_config.sh` output.
- Keep your dotfiles synced and backed up with Mackup.

---

## Customization

- **Brewfile**: Add or remove Homebrew formulas, casks, Mac App Store apps, and VSCode extensions
- **`config/zsh/.zshrc`**, **`config/zsh/helpers/aliases.zsh`**, **`config/zsh/helpers/sre.zsh`**: shell, aliases, SRE helpers
- **.macos**: macOS system preferences (run manually if needed)

---

## Backing Up Settings

To backup your app settings with Mackup:
```sh
brew install mackup
mackup backup
```
Settings are synced to iCloud by default. See [Mackup documentation](https://github.com/lra/mackup) for more options.

---

## Python setup: uv and pre-commit

- **uv** is the recommended Python packaging tool for this setup; it is installed when `bootstrap/pyenv-setup.sh` runs (Homebrew).
- **pre-commit** is installed and hooks are registered when a git repo and `.pre-commit.yml` are present.
- Add or change hooks by editing `.pre-commit.yml`.

### Manual use

- Install Python dependencies from inventory:
  ```sh
  ./bin/macctl apply --only=python
  ```
- Run all pre-commit hooks manually:
  ```sh
  pre-commit run --all-files
  ```
- Install git hooks if they are not active yet:
  ```sh
  pre-commit install
  ```

---

## Agent Frameworks & Automated Tool Setup

This repo supports modern agent/AI workflows for Python and Go:

- **Agent Frameworks:** [CrewAI](https://github.com/joaomdmoura/crewAI), [AutoGen](https://github.com/microsoft/autogen), [LangChain](https://github.com/langchain-ai/langchain), [LlamaIndex](https://github.com/jerryjliu/llama_index), [LocalAI](https://github.com/go-skynet/LocalAI), [go-openai](https://github.com/sashabaranov/go-openai)
- **LLM/Inference:** [Ollama](https://ollama.com/), [llama.cpp](https://github.com/ggerganov/llama.cpp)
- **Copilot CLI, Cursor IDE:** AI-enhanced coding

### Automated Agent / AI tool setup

Use the **`ia`** module (inventory under `inventory/ia/`) via macctl:

```sh
./bin/macctl plan --only=ia
./bin/macctl apply --only=ia
```

Edit `inventory/ia/manifest.txt` and `inventory/ia/uv-packages.txt` to add or remove tools. Heavy one-offs (e.g. building `llama.cpp`) are intentionally not in the default manifest; run them manually when needed.

### Example: Python agent venv

```sh
./bin/macctl apply --only=python,ia
cd ~/Code
python3 -m venv venv
source venv/bin/activate
pip install crewai langchain llama-index openai
```

### Example: Go agent module

```sh
cd ~/Code
mkdir my-go-agent && cd my-go-agent
go mod init my-go-agent
go get github.com/go-skynet/LocalAI github.com/sashabaranov/go-openai
```

---

## Practical Examples

### Go Agent Project
```sh
go mod init my-go-agent
go get github.com/go-skynet/LocalAI github.com/sashabaranov/go-openai
# Start building your agent!
```

### Vim setup & plugins
```sh
./bin/macctl apply --only=vim
# Edit your ~/.vimrc to add plugins; remove state/vim-plugins.ok to force :PlugInstall again
```

### AI / DevOps extras
```sh
./bin/macctl apply --only=ia
```

---

## License

This project is licensed under the terms of the MIT license. See [LICENSE.md](LICENSE.md) for details.

---

**Automate your Mac. Code with confidence.**
