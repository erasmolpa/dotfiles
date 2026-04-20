# Inventory (desired state)

Plain-text (and Brewfile) sources for **`macctl`** (`bin/macctl`). The engine lives in **`core/`**; each ecosystem is a **`modules/<name>.sh`** plugin. Load order is **`core/module-order`** (one module basename per line).

See **`docs/MACCTL-ARCHITECTURE.md`** for the full plugin contract and extension steps.

## Layout

| Path | Purpose |
|------|---------|
| `brew/Brewfile` | taps, formulae, `mas`, VS Code extensions |
| `brew/casks.txt` | cask tokens, one per line |
| `python/requirements.txt` | pip lines for the **python** module |
| `node/global-packages.txt` | npm globals for the **node** module |
| `golang/formulae.txt` | extra brew formulae for Go (beyond Brewfile) |
| `ia/manifest.txt` | `tap:`, `brew_formula:`, `brew_cask:` lines |
| `ia/uv-packages.txt` | one package per line for `uv pip install` (uses `--system` unless a venv is active) |
| `vim/steps.txt` | reserved; vim module uses fixed steps + `state/vim-plugins.ok` |

## Commands

Run these from the repository root, or use an absolute path (for example `~/.dotfiles/bin/macctl`). Flags may appear before the subcommand (for example `bin/macctl --only=brew plan`).

```sh
./bin/macctl plan
./bin/macctl apply --dry-run
./bin/macctl apply --only=brew,python
./bin/macctl doctor
./bin/macctl sync
./bin/macctl import --dry-run
./bin/macctl lint
```

`bootstrap/setup.sh` runs `macctl apply` in two phases (brew first, then golang/python/node/vim/ia) after symlinking **`config/`** into `$HOME`.

**Adopting an existing Mac:** run `macctl import --dry-run`, review logs, then `macctl import` (optional `--only=…`, `--force`). Backups land in `state/import-backups/`. See **`docs/IMPORT.md`**.

## Reconciliation

For each registered module, the runner:

1. Runs `<name>_get_desired` → sorted lines
2. Runs `<name>_get_current` → sorted lines in the same canonical format
3. `diff_lists` → missing lines
4. `plan` prints them; `apply` pipes them into `<name>_install`

Idempotent installs are delegated to Homebrew / pip / npm / `uv` / `vim` as appropriate.
