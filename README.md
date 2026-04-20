# Dotfiles for macOS — one control plane for your machine

Turn a fresh Mac (or an existing one) into a **repeatable, documented environment**: shell, Homebrew stack, language toolchains, and optional AI/DevOps extras — driven by plain-text **inventory**, not one-off scripts you forget to re-run.

**Who this is for:** developers and platform engineers who want a **single workflow** to install, reconcile, and audit tooling — similar in spirit to infrastructure-as-code, applied to a laptop.

---

## What you get

| Outcome | How |
|--------|-----|
| **Predictable installs** | Desired packages live in `inventory/` (Brewfile, lists, manifests). |
| **See before you change** | `macctl plan` shows what is missing vs inventory; `apply` installs only the gap. |
| **Safe adoption of an existing Mac** | `macctl import` merges what is already installed into inventory (with backups); nothing is uninstalled. |
| **Health checks** | `macctl doctor`, `macctl lint` (ShellCheck), and optional `bootstrap/post-setup.sh`. |
| **Shell + SRE ergonomics** | Zsh config, helpers, and guided wizards under `config/zsh/`. |

**`macctl`** is the product surface: one binary-style entrypoint (`bin/macctl`) that loads a small engine (`core/`) and plugins (`modules/`). You do not need to remember which script installs what.

---

## macctl at a glance

```text
plan          Diff inventory vs this Mac (stderr); use --only=brew,python,... to scope
apply         Install missing items; --dry-run logs commands without running them
import        Merge detected installs into inventory; --dry-run to preview; backups under state/import-backups/
sync          Refresh state snapshots; add --pull-inventory to run import after snapshots
doctor        Quick sanity checks (paths, brew, optional module hooks)
lint          Run ShellCheck on shell entrypoints (requires shellcheck on PATH)
```

Flags can appear **before or after** the subcommand (for example `macctl --only=brew plan`). Run from the repo root or call `~/.dotfiles/bin/macctl` with an absolute path.

Architecture and extension points: `docs/MACCTL-ARCHITECTURE.md` · Import behavior: `docs/IMPORT.md` · Day-two usage: `docs/USAGE.md`.

---

## User journeys

### A. New Mac (greenfield)

1. Clone to the canonical path (`.zshrc` expects `DOTFILES=$HOME/.dotfiles`):

   ```sh
   git clone https://github.com/erasmo-dominguez-stuff/macctl ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run setup (installs Homebrew / Oh My Zsh if needed, symlinks `config/` into `$HOME`, runs phased `macctl apply`):

   ```sh
   chmod +x install.sh bin/macctl bootstrap/*.sh modules/*.sh
   ./install.sh
   ```

3. Open a new shell, then optionally `./bootstrap/post-setup.sh` and `mackup restore` if you use Mackup.

### B. Machine that already has tools (brownfield)

1. Clone the repo (same path as above).

2. Preview, then merge live state into inventory:

   ```sh
   ./bin/macctl import --dry-run
   ./bin/macctl import
   ```

3. Review diffs, then align the machine to the merged inventory when you are ready:

   ```sh
   ./bin/macctl plan
   ./bin/macctl apply --dry-run
   ./bin/macctl apply
   ```

### C. Day two (updates)

- Refresh snapshots: `./bin/macctl sync` (add `--write` / `--pull-inventory` as needed; see `docs/USAGE.md`).
- Tighten shell quality: `./bin/macctl lint`.
- Edit lists under `inventory/` and re-run `plan` / `apply` for the modules you changed.

---

## What ships in the box (high level)

- **Platform:** Homebrew (formulae, casks, MAS, VS Code extensions via Brewfile + lists).
- **Languages & runtimes:** Python (pip inventory), Node globals, Go-related brew lines, `uv` / pyenv flow via bootstrap where enabled.
- **Editor:** Vim / vim-plug path via the `vim` module (see `docs/USAGE.md` for markers like `state/vim-plugins.ok`).
- **AI / DevOps add-ons:** Curated `ia` inventory (brew + `uv pip` lists); extend with `inventory/ia/manifest.txt` and `uv-packages.txt`.
- **Shell & productivity:** Zsh, themes, aliases, SRE-oriented helpers and wizards under `config/zsh/`.
- **Optional:** Mackup for app settings; `.pre-commit.yml` for repo hygiene when you work inside this tree.

Deep inventory map: `inventory/TOOLS.md`.

---

## Repository map (for contributors)

| Area | Role |
|------|------|
| `bin/macctl` | CLI entry → `core/main.sh` |
| `core/` | Engine: helpers, registry, runner, `module-order`, `import.sh` |
| `modules/` | One plugin per ecosystem (`brew`, `golang`, `python`, `node`, `vim`, `ia`) |
| `inventory/` | Desired state (the source of truth for reconciliation) |
| `config/` | Files symlinked into `$HOME` (zsh, git, mac prefs) |
| `bootstrap/` | First-run and maintenance scripts |
| `state/` | Snapshots and import backups (usually gitignored) |

Canonical Brew inventory lives at `inventory/brew/Brewfile` (no root-level duplicate file). See the table above for the mental model; file-level detail stays in `docs/MACCTL-ARCHITECTURE.md`.

---

## Customization (where to edit)

- **Packages & apps:** `inventory/brew/Brewfile`, `inventory/brew/casks.txt`, and other `inventory/*` lists.
- **Shell:** `config/zsh/.zshrc`, `config/zsh/helpers/`, `config/zsh/wizards/`.
- **Git / macOS defaults:** `config/git/`, `config/mac/.macos` (apply macOS prefs manually when you want them).

---

## Troubleshooting

- **Pre-commit failures:** follow the hook output (formatters, linters, etc.).
- **Paths:** keep the clone at `~/.dotfiles` unless you intentionally retarget `DOTFILES` in your shell.
- **Diagnostics:** `brew doctor`, `./bin/macctl doctor`, `./bin/macctl lint`, `./bootstrap/post-setup.sh`.
- **AI tooling issues:** confirm `brew` / `uv` pieces from `inventory/ia/` and re-run `macctl plan --only=ia`.

---

## Python, agents, and examples

- **uv** and **pre-commit** are wired through bootstrap and inventory where enabled; adjust `.pre-commit.yml` for your team.
- **Agent-style stacks (Python / Go):** this repo inventories common libraries and CLIs; heavy custom builds (for example compiling `llama.cpp`) stay manual by design.
- Quick checks:

  ```sh
  ./bin/macctl apply --only=python,ia
  ./bin/macctl apply --only=vim
  ```

---

## Mackup (optional)

```sh
brew install mackup
mackup backup
```

Defaults and options: [Mackup documentation](https://github.com/lra/mackup).

---

## License

MIT — see [LICENSE.md](LICENSE.md).
