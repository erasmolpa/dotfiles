# Usage Guide: dotfiles (`~/.dotfiles`)

## Overview

This repo uses **`bin/macctl`** for inventory-driven installs and **`config/`** for files symlinked into `$HOME`.

---

## 1. Installation Steps

1. **Clone the repository:**

   ```sh
   git clone https://github.com/erasmolpa/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run setup:**

   ```sh
   chmod +x install.sh bin/macctl bootstrap/*.sh modules/*.sh
   ./install.sh
   ```

3. **(Optional) Post-setup:**

   ```sh
   ./bootstrap/post-setup.sh
   ```

4. **(Optional) Mackup:**

   ```sh
   mackup restore
   ```

---

## 2. macctl

- `macctl plan` — show what would change
- `macctl apply` — apply missing packages
- `macctl doctor` — validate environment
- `macctl sync` — refresh `state/*.txt` snapshots
- `macctl lint` — run ShellCheck on shell entrypoints and modules (`brew install shellcheck`)

Use `--only=brew,python` and `--dry-run` as needed.

### Import (inventory from this machine)

```sh
./bin/macctl import --dry-run
./bin/macctl import
./bin/macctl import --only=brew,python --force
./bin/macctl sync --pull-inventory --dry-run
```

`import` merges detected packages into `inventory/` (backups under `state/import-backups/`). It does not remove software or delete Brewfile lines. Details: `docs/IMPORT.md`.

---

## 3. Shell (Zsh)

- Config lives under **`config/zsh/`** (helpers, wizards, themes).
- Reload: `source ~/.zshrc`

---

## 4. Troubleshooting

- Confirm the repo is at `~/.dotfiles` and `~/.zshrc` points at `config/zsh/.zshrc`.
- Run `macctl doctor` and `brew doctor`.
- See `README.md` and `docs/MACCTL-ARCHITECTURE.md`.

---

**Automate your Mac. Code with confidence.**
