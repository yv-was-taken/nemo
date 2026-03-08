# nemo — fish mode for nushell
# Main overlay entry point

# Re-export abbreviation commands (needed for executehostcommand keybindings)
export use abbreviations/mod.nu [
    nemo-expand-abbrev
]

# Re-export keybinding commands (needed for executehostcommand keybindings)
export use keybindings.nu [
    nemo-toggle-sudo
    nemo-cd-parent
    nemo-cd-back
    nemo-cd-forward
    nemo-edit-command
]

# Re-export package manager commands
export use pkgman/mod.nu [
    "nemo install"
    "nemo remove"
    "nemo update"
    "nemo list"
    "nemo search"
]

# Re-export completion dispatch (needed for external completer closure)
export use completions/mod.nu [nemo-dispatch]

# Re-export prompt commands (needed for prompt closures)
export use prompt/mod.nu [nemo-prompt nemo-transient-prompt]

# Setup environment on overlay activation
export-env {
    use abbreviations/mod.nu [nemo-load-abbrevs nemo-abbrev-keybindings]
    use keybindings.nu [nemo-keybindings nemo-dir-history-hook]

    # --- Abbreviations ---
    $env.NEMO_ABBREVS = (nemo-load-abbrevs)

    # --- Directory history ---
    $env.NEMO_DIR_HISTORY = [$env.PWD]
    $env.NEMO_DIR_IDX = 0
    $env.NEMO_DIR_NAVIGATING = false

    # --- Prompt ---
    # Sets left prompt; does NOT touch PROMPT_COMMAND_RIGHT (user's mommy etc.)
    $env.PROMPT_COMMAND = {|| nemo-prompt }
    $env.TRANSIENT_PROMPT_COMMAND = {|| nemo-transient-prompt }
    # Nemo's prompt already includes ❯, so blank out nushell's default "> " indicator
    $env.PROMPT_INDICATOR = ""
    $env.TRANSIENT_PROMPT_INDICATOR = ""

    # --- External completer ---
    # Must be set up before keybindings/menus upsert (nushell type inference quirk)
    let existing_completer = ($env.config | get -o completions.external.completer)
    let nemo_completer = {|spans: list<string>|
        let result = (nemo-dispatch $spans)
        if ($result | is-not-empty) { $result }
        else if $existing_completer != null { do $existing_completer $spans }
        else { [] }
    }
    $env.config.completions.external.enable = true
    $env.config.completions.external.completer = $nemo_completer

    # --- Keybindings (additive — merged with existing) ---
    let abbrev_keys = (nemo-abbrev-keybindings)
    let nav_keys = (nemo-keybindings)
    $env.config = ($env.config | upsert keybindings ($env.config.keybindings | append $abbrev_keys | append $nav_keys))

    # --- Completion menu with descriptions ---
    let desc_menu = {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 5
            description_rows: 10
        }
        style: {
            text: green
            selected_text: green_reverse
            description_text: yellow
        }
    }
    let menus = ($env.config | get -o menus | default [])
    let filtered_menus = ($menus | where name != "completion_menu")
    $env.config = ($env.config | upsert menus ($filtered_menus | append $desc_menu))

    # --- Directory history hook ---
    let dir_hook = (nemo-dir-history-hook)
    let existing_pwd_hooks = ($env.config | get -o hooks.env_change.PWD | default [])
    $env.config = ($env.config | upsert hooks.env_change.PWD ($existing_pwd_hooks | append $dir_hook))

    # --- Kitty protocol ---
    if ("KITTY_PID" in $env) {
        $env.config = ($env.config | upsert use_kitty_protocol true)
    }
}
