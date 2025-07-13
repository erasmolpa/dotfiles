# mac-book-dotfiles

A complete, automated setup for a modern macOS development environment. This repository contains my personal dotfiles, Homebrew bundle, and scripts to configure tools for development, DevOps, and AI workflows.

---

## Features

- Automated installation of Homebrew, Oh My Zsh, and essential CLI tools
- Homebrew Bundle (`Brewfile`) for managing apps, fonts, and extensions
- Scripts for configuring Python, Go, AI/DevOps tools, and more
- macOS preferences and shell customizations
- Easy backup and restore of app settings with Mackup

---

## Getting Started

### 1. Clone the Repository

```sh
git clone https://github.com/erasmolpa/mac-book-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run the Installation Script

```sh
./install.sh
```

This script will:
- Install Oh My Zsh (if not present)
- Install Homebrew (if not present)
- Symlink your `.zshrc` and `.mackup.cfg`
- Install all dependencies from the `Brewfile`
- Create project directories
- Clone personal repositories (see `clone.sh`)
- Run configuration scripts for Python, Go, and AI tools

### 3. Run Post-install Automation

After setup, run:

```sh
./post-install.sh
```

This will update all packages, run security/code checks, and provide diagnostics.

### 3. Restore App Preferences (Optional)

If you use Mackup for syncing app settings:

```sh
mackup restore
```

---

## Project Structure

- `Brewfile` — Homebrew, cask, mas, and VSCode extension list
- `install.sh` — Main setup script
- `pre_install.sh` — Bootstrap script for clean installs
- `post_install.sh` — Post-setup update, diagnostics, and security automation
- `.pre-commit.yml` — Automated code quality, formatting, and security checks
- `installation_scripts/agent_tools_install.sh` — Ensures all agent/AI tools are ready for Python/Go projects

- `clone.sh` — Clones personal repositories
- `installation_scripts/python_install.sh`, `installation_scripts/golang_install.sh`, `installation_scripts/ia_install.sh` — Language/tool install scripts
- `.zshrc`, `.macos`, `.mackup.cfg`, etc. — Dotfiles and preferences

---

## Editor & Vim Setup

To ensure Vim is ready with plugins and fuzzy search:

- Run the following after your main install:

  ```sh
  ./installation_scripts/vim_install.sh
  ```
- This will:
  - Install vim-plug (if missing) for plugin management
  - Run the fzf install script for keybindings and completion
  - Automatically install all plugins defined in your `.vimrc`.

---

## Backing Up Python Packages & Git Repo Initialization

- After running `post_install.sh`, a `requirements.txt` is generated with all installed pip packages. Use this to restore your Python environment on new machines:

  ```sh
  pip install -r requirements.txt
  ```

- The first run of `install.sh` will initialize a git repository in your dotfiles folder (if not already present), add a basic `.gitignore` (ignoring sensitive files), and commit your configuration. This ensures your setup is versioned and portable.

---

---

## Automated Code Quality & Security

This repo uses [pre-commit](https://pre-commit.com/) to enforce best practices and catch issues before they reach your main branch. Hooks include:
- **Security & Sensitive Data:** git-secrets, detect-secrets, bandit, detect-private-key
- **Python:** ruff, black, flake8
- **JS/TS:** eslint, prettier
- **Shell:** shellcheck, shfmt
- **Markdown/YAML:** markdownlint, yamllint
- **Terraform:** checkov, tfsec
- **Docker:** hadolint

To run all checks manually:

```sh
pre-commit run --all-files
```

---

## Post-install Automation

After setup, run:

```sh
./post-install.sh
```

This script updates all major package managers (Homebrew, pipx, npm), runs security/code checks, and provides diagnostics.

---

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
