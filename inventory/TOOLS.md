# Inventory: Tools & Configurations

This file lists the main tools, scripts, and configurations included in this dotfiles repo. Use it to verify your setup or as a checklist for a new Mac.

---

## Core Tools (installed via Brewfile)
- Homebrew
- Oh My Zsh
- jq, yq
- kubectl, stern
- promtool, logcli, amtool
- k6
- terraform
- helm
- awscli
- docker, docker-compose
- python, pipx, uv
- node, npm
- pre-commit
- mackup
- fzf, ripgrep, bat, exa, fd, htop, tmux, neovim, vim
- (see Brewfile for full list)

---

## Helpers & Wizards
- All scripts in `helpers/` (sre.zsh, aliases.zsh, cheatsheet.zsh)
- All scripts in `wizards/` (wizards.zsh)
- Auto-loaded in every terminal session

---

## Install Scripts
- `install/install.sh` — Main setup script
- `install/post-install.sh` — Post-setup update & diagnostics
- `installation_scripts/` — Language/tool-specific installers (Python, Go, AI, Vim, etc.)

---

## Dotfiles
- `.zshrc`, `.mackup.cfg`, `.macos`, `.pre-commit.yml`, `.gitignore`, etc.

---

## Project Directories
- `Code/`, `Herd/`, `Library/` created automatically

---

## Usage
- See `docs/USAGE.md` and `README.md` for full instructions

---

**Checklist for a new Mac:**
- [ ] Clone repo
- [ ] Run install script
- [ ] Run post-install
- [ ] Restore Mackup (optional)
- [ ] Open new terminal and verify helpers/wizards load
