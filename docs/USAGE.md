# Usage Guide: mac-book-dotfiles

## Overview
This guide explains how to use the helpers, wizards, and install scripts in this dotfiles repo for a clean, automated setup on a new Mac.

---

## 1. Installation Steps

1. **Clone the repository:**
   ```sh
   git clone https://github.com/erasmolpa/mac-book-dotfiles.git ~/.dotfiles
   cd ~/.dotfiles/repo_dotfiles
   ```
2. **Run the main install script:**
   ```sh
   ./install/install.sh
   ```
3. **(Optional) Run post-install automation:**
   ```sh
   ./install/post-install.sh
   ```
4. **(Optional) Restore app settings with Mackup:**
   ```sh
   mackup restore
   ```

---

## 2. Helpers & Wizards

- All scripts in `helpers/` and `wizards/` are auto-loaded in every new terminal session via Oh My Zsh and ZSH_CUSTOM.
- No manual sourcing is needed.
- Use `help-sre` or `help-wizards` in your terminal to see available commands and wizards.

---

## 3. Customization

- Add your own helpers to `helpers/` or wizards to `wizards/`.
- Edit `.zshrc` or any helper script and reload your shell:
  ```sh
  source ~/.zshrc
  ```

---

## 4. Troubleshooting

- If a tool or helper does not load, check that the symlinks in `~/.oh-my-zsh/custom/` point to the correct folders.
- Run `brew doctor` and `./install/post-install.sh` for diagnostics.
- For more help, see the main `README.md`.

---

**Automate your Mac. Code with confidence.**
