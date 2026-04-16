# mac-book-dotfiles

A complete, automated setup for a modern macOS development environment. This repository contains my personal dotfiles, Homebrew bundle, and scripts to configure tools for development, DevOps, and AI workflows.

---

## Features

- Automated installation of Homebrew, Oh My Zsh, and essential CLI tools
- Homebrew Bundle (`Brewfile`) for managing apps, fonts, and extensions
- Scripts for configuring Python, Go, AI/DevOps tools, and more
- macOS preferences and shell customizations
- Easy backup and restore of app settings with Mackup
- **SRE/Observability helpers and wizards auto-loaded via ZSH_CUSTOM**
- **All helpers in `helpers/`, wizards in `wizards/`, install scripts in `install/`**

---

## Getting Started

### 1. Clone the Repository
```sh
git clone https://github.com/erasmolpa/mac-book-dotfiles.git ~/.dotfiles
cd ~/.dotfiles/repo_dotfiles
```

### 2. Run the Installation Script
```sh
./install/install.sh
```

This script will:
- Install Oh My Zsh (if not present)
- Install Homebrew (if not present)
- Symlink your `.zshrc` and helpers/wizards
- Install all dependencies from the `Brewfile`
- Create project directories
- Clone personal repositories (see `clone.sh`)
- Run configuration scripts for Python, Go, and AI tools

### 3. Post-install Automation

After setup, run:
```sh
./install/post-install.sh
```
This will update all packages, run security/code checks, and provide diagnostics.

### 4. Restore App Preferences (Optional)

If you use Mackup for syncing app settings:
```sh
mackup restore
```

---

## Project Structure

- `helpers/` — SRE, aliases, cheatsheet helpers (auto-loaded)
- `wizards/` — Interactive wizards for SRE/observability
- `install/` — All install scripts (install.sh, post-install.sh, etc.)
- `installation_scripts/` — Language/tool-specific installers (Python, Go, AI, Vim, etc.)
- `docs/` — Documentation and usage guides
- `inventory/` — Tool and config inventory
- `Brewfile` — Homebrew, cask, mas, and VSCode extension list
- `.zshrc`, `.mackup.cfg`, `.macos`, `.pre-commit.yml`, etc. — Dotfiles and preferences
- `themes/` — Custom Zsh themes (e.g. minimal.zsh-theme)
- `scripts/` — Utility scripts (e.g. ssh.sh)

---

## Shell Auto-load

All helpers and wizards in `helpers/` and `wizards/` are auto-loaded in any new terminal via Oh My Zsh and ZSH_CUSTOM. No manual sourcing required.

---

## Usage & Checklist

- See `docs/USAGE.md` for step-by-step usage and troubleshooting.
- See `inventory/TOOLS.md` for a full inventory and checklist for a new Mac.

---

## Troubleshooting & Best Practices

- If a pre-commit hook fails, follow the error message for remediation (e.g., run `black .` or `ruff .` to auto-fix Python formatting).
- Use `brew doctor` and `./install/post-install.sh` for diagnostics.
- For AI/agent tool errors, check that all dependencies are installed and review `ia_config.sh` output.
- Keep your dotfiles synced and backed up with Mackup.

---

## Customization

- **Brewfile**: Add or remove Homebrew formulas, casks, Mac App Store apps, and VSCode extensions
- **.zshrc, helpers/aliases.zsh, helpers/sre.zsh**: Customize your shell, aliases, and SRE helpers
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

**Automate your Mac. Code with confidence.**

## Python Setup: uv & pre-commit

- **uv** es el gestor de paquetes recomendado para Python. Se instala automáticamente durante el setup.
- **pre-commit** se instala y activa automáticamente si hay un repo git y `.pre-commit.yml`.
- Puedes añadir más hooks editando `.pre-commit.yml`.

### Uso manual

- Instala dependencias Python:
  ```sh
  uv pip install -r requirements.txt
  ```
- Ejecuta todos los hooks pre-commit manualmente:
  ```sh
  pre-commit run --all-files
  ```
- Activa los hooks (si no se activaron):
  ```sh
  pre-commit install
  ```

---

## Agent Frameworks & Automated Tool Setup

This repo supports modern agent/AI workflows for Python and Go:

- **Agent Frameworks:** [CrewAI](https://github.com/joaomdmoura/crewAI), [AutoGen](https://github.com/microsoft/autogen), [LangChain](https://github.com/langchain-ai/langchain), [LlamaIndex](https://github.com/jerryjliu/llama_index), [LocalAI](https://github.com/go-skynet/LocalAI), [go-openai](https://github.com/sashabaranov/go-openai)
- **LLM/Inference:** [Ollama](https://ollama.com/), [llama.cpp](https://github.com/ggerganov/llama.cpp)
- **Copilot CLI, Cursor IDE:** AI-enhanced coding

### Automated Agent/AI Tool Setup

To ensure all required tools and frameworks are installed for local Python/Go agent development, run:

```sh
./agent_tools_setup.sh
```

This script will:
- Install/update all core Python agent/AI libraries (crewai, pyautogen, langchain, etc.)
- Install Go agent/AI libraries (LocalAI, go-openai)
- Install Ollama and build llama.cpp if needed
- Ensure CrewAI CLI is available

Run this script anytime to bootstrap or update your local agent/AI environment.

### Example: Starting a Python Agent Project

```sh
./agent_tools_setup.sh
cd ~/Code
python3 -m venv venv
source venv/bin/activate
pip install crewai langchain llama-index openai
# Start building your agent!
```

### Example: Starting a Go Agent Project

```sh
./agent_tools_setup.sh
cd ~/Code
mkdir my-go-agent && cd my-go-agent
go mod init my-go-agent
go get github.com/go-skynet/LocalAI github.com/sashabaranov/go-openai
# Start building your agent!
```

See `installation_scripts/agent_tools_install.sh` for details and customization.

---

## Practical Examples

### Go Agent Project
```sh
go mod init my-go-agent
go get github.com/go-skynet/LocalAI github.com/sashabaranov/go-openai
# Start building your agent!
```

### Vim Setup & Plugins
```sh
./installation_scripts/vim_install.sh
# Edit your ~/.vimrc to add plugins, then re-run the script to auto-install
```

### AI/DevOps Environment
```sh
./installation_scripts/ia_install.sh
# Installs Cursor, VSCode, bun, Python AI libs, etc. Only missing tools are installed.
```

---

## Troubleshooting & Best Practices

- If a pre-commit hook fails, follow the error message for remediation (e.g., run `black .` or `ruff .` to auto-fix Python formatting).
- Use `brew doctor` and `./post-install.sh` to diagnose system issues.
- For AI/agent tool errors, check that all dependencies are installed and review `ia_config.sh` output.
- Keep your dotfiles synced and backed up with Mackup.

---

## Customization

- **Brewfile**: Add or remove Homebrew formulas, casks, Mac App Store apps, and VSCode extensions
- **.zshrc, aliases.zsh, path.zsh**: Customize your shell, aliases, and PATH
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

## License

This project is licensed under the terms of the MIT license. See [LICENSE.md](LICENSE.md) for details.

---

**Automate your Mac. Code with confidence.**
