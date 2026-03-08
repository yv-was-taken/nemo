# nemo abbreviation engine
# Expands abbreviations in command position when pressing space

use defaults.nu nemo-default-abbrevs

# Load abbreviations from config file or defaults
export def nemo-load-abbrevs [] {
    let config_path = ($env.HOME | path join ".config" "nemo" "abbrevs.nuon")
    if ($config_path | path exists) {
        open $config_path
    } else {
        nemo-default-abbrevs
    }
}

# Check if the cursor is at a command position
# (start of line, or immediately after | or ;)
def is-command-position [before: string, word: string]: nothing -> bool {
    let prefix_len = ($before | str length) - ($word | str length)
    let trimmed = ($before | str substring 0..<$prefix_len | str trim --right)
    ($trimmed | is-empty) or ($trimmed | str ends-with "|") or ($trimmed | str ends-with ";")
}

# Expand abbreviation and insert space
export def nemo-expand-abbrev [] {
    let line = (commandline)
    let cursor = (commandline get-cursor)
    let before = ($line | str substring 0..<$cursor)
    let parts = ($before | split row ' ')
    let last_word = ($parts | last)

    if ($last_word | is-empty) {
        commandline edit --insert " "
        return
    }

    let is_cmd_pos = (is-command-position $before $last_word)

    if $is_cmd_pos and ($last_word in $env.NEMO_ABBREVS) {
        let expanded = ($env.NEMO_ABBREVS | get $last_word)
        let prefix_len = $cursor - ($last_word | str length)
        let prefix = ($line | str substring 0..<$prefix_len)
        let after = ($line | str substring $cursor..)
        let new_line = $"($prefix)($expanded) ($after)"
        commandline edit --replace $new_line
        commandline set-cursor ($prefix_len + ($expanded | str length) + 1)
    } else {
        commandline edit --insert " "
    }
}

# Keybinding definitions for the abbreviation engine
export def nemo-abbrev-keybindings [] {
    [
        {
            name: nemo_abbrev_space
            modifier: none
            keycode: space
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-expand-abbrev" }
        }
        {
            name: nemo_literal_space
            modifier: control
            keycode: space
            mode: [emacs vi_insert]
            event: { edit: insertchar, value: ' ' }
        }
    ]
}
