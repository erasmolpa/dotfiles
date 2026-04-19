# macctl import - adopt inventory from an existing Mac

`macctl import` inspects this machine and **merges** detected packages into files under `inventory/`. It **never** uninstalls anything and **never** deletes lines from `inventory/brew/Brewfile` (new blocks are **appended** only).

## Commands

```sh
macctl import
macctl import --dry-run
macctl import --force
macctl import --only=brew,python
macctl sync --write --pull-inventory
```

- **`--dry-run`**: log what would change; no files written.
- **`--force`**: for list-style inventory files, replace body with **detected-only** (still creates a backup first when not dry-run). Brewfile behavior is unchanged (always append-only for new lines).
- **`--only`**: limit to comma-separated ecosystems: `brew`, `python`, `node`, `golang`, `vim`, `ia`.

## Safety

- Before overwriting or merging, copies go to **`state/import-backups/<UTC-timestamp>/`** mirroring paths under the repo (for example `inventory/brew/casks.txt`).
- **`--force`** still performs that backup when not dry-run.

## Detection strategy (per ecosystem)

| Ecosystem | Source on disk | Written / merged into |
|-----------|----------------|------------------------|
| **brew** | `brew list --cask -1` | `inventory/brew/casks.txt` (one cask per line; header comments preserved). |
| **brew** | `brew tap`, `brew list --formula -1`, `mas list`, `code --list-extensions` | **`inventory/brew/Brewfile`** — only **new** `tap` / `brew` / `mas` / `vscode` lines not already implied by the current Brewfile (formula match uses short name and token basename). |
| **python** | `python3 -m pip freeze` | `inventory/python/requirements.txt` — keeps existing specs; adds freeze lines for new distribution **bases**; skips common bootstrap packages (`pip`, `setuptools`, `wheel`, …). |
| **node** | `npm ls -g --depth=0 --json` via Node | `inventory/node/global-packages.txt`; skips `npm` and `corepack`. |
| **golang** | `brew list --formula -1` filtered by name (`go`, `golang`, `go-*`, …) | `inventory/golang/formulae.txt`. |
| **vim** | `Plug '…'` / `Plug "…"` in `~/.vimrc` or `~/.config/nvim/init.vim` | **`inventory/vim/plugins.txt`** (reference only; `macctl apply` does not consume this file yet). |
| **ia** | Known formula names present in `brew list` | **`inventory/ia/manifest.txt`** — appends `brew_formula:name` only when missing. |
| **ia** | `uv pip freeze` (package names only) | `inventory/ia/uv-packages.txt` merged with existing lines. |

## Example snippets (after import)

**`inventory/brew/casks.txt`** (excerpt):

```text
# Homebrew casks (one token per line). Reconciled vs: brew list --cask
docker
firefox
```

**`inventory/brew/Brewfile`** (appended tail):

```text
# --- macctl import 2026-04-19T12:00:00Z ---
brew "new-tool"
vscode "publisher.extension-id"
```

**`inventory/python/requirements.txt`**:

```text
# Declarative Python packages (macctl module python).
pre-commit>=3.5
requests==2.31.0
```

## Idempotency

Re-running `import` without new installs should add **no** duplicate Brewfile lines (same formula detection) and merges list files with **sort -u**.
