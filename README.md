# nemo

Fish mode for Nushell.

Brings fish shell's zero-config delight — smart abbreviations, rich completions, polished prompt — into nushell's structured data world.

## Features

- **Abbreviation engine** — type `gs` + space, get `git status`. Command-position only, won't expand arguments.
- **Smart completions** — `kill ki<TAB>` shows PIDs with CPU/memory info. Git branches show commit dates. SSH hosts from config.
- **Fish-style prompt** — git branch, dirty indicator, command duration, error status. Transient previous prompts.
- **Fish-like keybindings** — Alt+Left/Right for directory history, Alt+S for sudo toggle, Alt+Up for parent dir.
- **Package manager** — install nushell modules and plugins from git repos.

## Install

```nushell
git clone https://github.com/<user>/nemo ~/.local/share/nemo/nemo
nu ~/.local/share/nemo/nemo/scripts/install.nu
```

## Usage

Nemo activates as a nushell overlay. After installation:

```nushell
# It's auto-loaded via ~/.config/nushell/autoload/nemo.nu
# To temporarily disable:
overlay hide nemo

# To re-enable:
overlay use nemo
```

## Abbreviations

Edit `~/.config/nemo/abbrevs.nuon` to customize:

```nuon
{
    gs: "git status"
    gp: "git push"
    gco: "git checkout"
    gc: "git commit"
    gd: "git diff"
    gl: "git log --oneline"
    dc: "docker compose"
}
```

Ctrl+Space inserts a literal space without expansion.

## License

MIT
