# macctl architecture

## Layers

| Layer | Role |
|-------|------|
| **config/** | Shell, git, macOS preferences (symlinked into `$HOME`). |
| **inventory/** | Desired state: plain-text lists and Brewfile fragments per ecosystem. |
| **modules/** | Plugins: each implements `<name>_get_desired`, `<name>_get_current`, `<name>_install` and calls `register_module "<name>"`. |
| **core/** | Engine: helpers (diff, logging, `run_command`), registry (`register_module`), runner (plan/apply loop), `main.sh` (CLI). |
| **state/** | Optional snapshots (`macctl sync`) and markers (e.g. vim). |

## Extending

1. Add `inventory/<name>/…` files.
2. Add `modules/<name>.sh` implementing the three functions and call `register_module "<name>"` at the end of the file.
3. Append `<name>` as a new line to **`core/module-order`** so `main_load` sources it in the right order (for example after `brew` if your module depends on Homebrew).

Core reconciliation stays generic; discovery is driven only by **`core/module-order`** and `modules/<name>.sh`.

## Commands

- `macctl plan` — show diff (stderr) per module.
- `macctl apply` — install missing lines (stdin to `<name>_install`).
- `macctl apply --dry-run` — log only.
- `macctl apply --only=brew,python` — filter modules.
- `macctl doctor` — sanity checks + optional `<name>_doctor` hooks.
- `macctl sync` — refresh `state/*.txt` and `inventory/_generated/` hints.
- `macctl lint` — run **ShellCheck** on `core/`, `bin/macctl`, `bootstrap/*.sh`, `install.sh`, and `modules/*.sh` (requires `shellcheck` on `PATH`).

## Line format (examples)

- **brew**: `tap:…`, `formula:…`, `cask:…`, `mas:…`, `vscode:…`
- **python**: `pip|base|full-spec`
- **node**: `npm:package`
- **ia**: `tap:…`, `brew_formula:…`, `brew_cask:…`, `uvpip:…`
