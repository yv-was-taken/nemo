# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nemo is a **fish mode for nushell** — an overlay that brings Fish shell's user-friendly features (abbreviations, smart completions, prompt, keybindings, package manager) into Nushell, while going beyond Fish by leveraging Nushell's structured data (e.g., PID completions with CPU/memory, git branches with commit dates). Originally called "nufish", renamed to "nemo" (the famous fish).

**Status**: Phase 1 MVP complete and all tests passing. Phase 2 (Rust plugin) not yet started.

## Development Commands

```nushell
# Test the overlay locally (loads all features)
overlay use nu/

# Run test suite
nu tests/test_overlay.nu

# Run tests with explicit overlay (if needed)
nu -c "overlay use nu; source tests/test_overlay.nu"
```

No build step for Phase 1 — pure Nushell. Phase 2 will add a Rust plugin at `crates/nu_plugin_nemo/` (placeholder exists).

## Architecture

**Entry point**: `nu/mod.nu` — composes all features in a single `export-env` block that:
1. Loads abbreviations into `$env.NEMO_ABBREVS`
2. Registers keybindings (appended, not replaced)
3. Sets up external completer (wraps any existing user completer)
4. Configures fish-style prompt with transient prompt support
5. Hooks directory changes for navigation history
6. Initializes state vars (`NEMO_DIR_HISTORY`, `NEMO_DIR_IDX`, `NEMO_DIR_NAVIGATING`)

**Key modules**:
- `nu/abbreviations/` — Expansion engine + 30+ defaults. Expands only in command position (start of line or after `|`/`;`). Loaded from `~/.config/nemo/abbrevs.nuon` or `defaults.nu`.
- `nu/completions/` — External completer dispatcher (`nemo-dispatch`) routing to per-command generators (git, docker, ssh, pacman, systemd, process). Each generator produces structured completion data with descriptions.
- `nu/prompt/mod.nu` — Fish-style prompt with git branch/dirty indicator, command duration (>2s), error status via color. Transient prompt collapses previous prompts.
- `nu/keybindings.nu` — Alt+Left/Right (dir history), Alt+Up (cd ..), Alt+S (sudo toggle), Alt+E (edit in $EDITOR), Ctrl+Space (literal space).
- `nu/pkgman/` — Fisher-inspired package manager. Manifest at `~/.local/share/nemo/manifest.nuon`, packages cloned to `~/.local/share/nemo/plugins/<name>/`.

**Design patterns**:
- Additive merging: all configs upsert/append rather than replace user settings
- Environment-driven state: mutable state lives in `$env.*` vars
- Keybindings use `executehostcommand` to call exported functions
- External completer wrapping preserves user's existing completer
- Error resilience: completers use `complete | where exit_code` for graceful fallback
- Abbreviation context detection via string parsing (not regex) to avoid argument expansion

## Writing Nushell Code

All code is Nushell — **never use bash syntax**. Key reminders:
- `$env.VAR = "value"` not `export VAR="value"`
- `def name [] {}` not `function name() {}`
- Pipe structured data; use `| to text` or `| str join` when string output needed
- Use `^command` to disambiguate external binaries from builtins
- NUON format (not JSON) for data files (`.nuon`)

## Key Design Decisions

- **Architecture**: Hybrid — Rust plugin for data providers, .nu modules for all UX. Phased rollout starting pure .nu.
- **Critical constraint**: Nushell plugins can add commands but **cannot hook into reedline** (the line editor). The plugin protocol communicates via stdin/stdout — no access to completion engine, keybindings, or text buffer. Rust is only for *data providers*; all UX must use Nushell's built-in mechanisms.
- **No theming**: Colors come from terminal emulator (kitty + wallust). Nemo does not touch `$env.config.color_config`. "Nemo focuses on behavior, not colors."
- **Abbreviation config**: File-based (`~/.config/nemo/abbrevs.nuon`), not CLI commands. User edits NUON directly. Falls back to built-in defaults.
- **Abbreviation performance**: Pure .nu stays — record lookup is O(1), <1ms, faster than Rust IPC (~2-5ms overhead).
- **Prompt**: Nemo provides left prompt only. Does NOT touch `PROMPT_COMMAND_RIGHT` — user adds their own right prompt.
- **Existing config preserved**: Atuin history, mommy right prompt, Kitty shell integration, existing aliases — nemo must not conflict.

## Roadmap

### Phase 1 — Pure .nu MVP (v0.1) — COMPLETE
All features implemented in pure Nushell: abbreviation engine, smart completions (pid, git, ssh, docker, pacman, systemd), fish-style prompt with transient prompt, keybindings, package manager skeleton, install script, tests.

### Phase 2 — Rust Plugin (v0.2) — NOT STARTED
Add `nu_plugin_nemo` for performance-critical data:
- `nemo ps` — cached /proc reads (sysinfo crate), only rescan if >500ms stale
- `nemo git branches` — libgit2-based branch listing with commit metadata
- `nemo packages search` — ALPM crate for pacman DB queries (10-100x faster)
- `nemo ssh-hosts` and `nemo systemd units` — fast data providers
- Update .nu completers to prefer plugin commands when available, fallback to subprocess
- GitHub Actions CI for pre-built Linux x86_64 binaries

### Phase 3 — Polish (v0.3) — NOT STARTED
- More completions: kubectl, cargo, bun
- `command_not_found` hook: suggest packages to install
- Package registry: curated index of nemo-compatible packages
- Documentation site

## File Locations at Runtime

| Path | Purpose |
|------|---------|
| `~/.config/nemo/abbrevs.nuon` | User abbreviation overrides |
| `~/.config/nushell/autoload/nemo.nu` | Installed overlay activation |
| `~/.config/nushell/autoload/nemo-packages.nu` | Package autoload (generated) |
| `~/.local/share/nemo/manifest.nuon` | Package manager manifest |
| `~/.local/share/nemo/plugins/<name>/` | Installed packages |

## Design Document

Full design doc at `/home/ywvlfy/.claude/plans/transient-exploring-ember.md` — contains detailed feature specs, completion provider tables, package format conventions, and verification checklist.
