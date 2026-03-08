# nemo keybindings — fish-like navigation and convenience
# All keybindings are additive (merged with user's existing keybindings)

# Toggle sudo prefix on current command line
export def nemo-toggle-sudo [] {
    let line = (commandline)
    if ($line | str starts-with "sudo ") {
        commandline edit --replace ($line | str substring 5..)
        commandline set-cursor ((commandline get-cursor) - 5)
    } else {
        commandline edit --replace $"sudo ($line)"
        commandline set-cursor ((commandline get-cursor) + 5)
    }
}

# Navigate to parent directory
export def --env nemo-cd-parent [] {
    cd ..
    commandline edit --replace ""
}

# Navigate back in directory history
export def --env nemo-cd-back [] {
    let history = ($env.NEMO_DIR_HISTORY? | default [])
    let idx = ($env.NEMO_DIR_IDX? | default 0 | into int)
    if $idx > 0 {
        let new_idx = $idx - 1
        let target = ($history | get $new_idx)
        $env.NEMO_DIR_NAVIGATING = true
        cd $target
        $env.NEMO_DIR_IDX = $new_idx
        $env.NEMO_DIR_NAVIGATING = false
        commandline edit --replace ""
    }
}

# Navigate forward in directory history
export def --env nemo-cd-forward [] {
    let history = ($env.NEMO_DIR_HISTORY? | default [])
    let idx = ($env.NEMO_DIR_IDX? | default 0 | into int)
    let max_idx = (($history | length) - 1)
    if $idx < $max_idx {
        let new_idx = $idx + 1
        let target = ($history | get $new_idx)
        $env.NEMO_DIR_NAVIGATING = true
        cd $target
        $env.NEMO_DIR_IDX = $new_idx
        $env.NEMO_DIR_NAVIGATING = false
        commandline edit --replace ""
    }
}

# Open current command line in $EDITOR
export def nemo-edit-command [] {
    let line = (commandline)
    let tmpfile = (mktemp --suffix .nu)
    $line | save --force $tmpfile
    let editor = ($env.EDITOR? | default "vim")
    ^$editor $tmpfile
    let result = (open $tmpfile | str trim)
    rm $tmpfile
    commandline edit --replace $result
}

# Keybinding definitions
export def nemo-keybindings [] {
    [
        {
            name: nemo_sudo_toggle
            modifier: alt
            keycode: char_s
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-toggle-sudo" }
        }
        {
            name: nemo_cd_parent
            modifier: alt
            keycode: up
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-cd-parent" }
        }
        {
            name: nemo_cd_back
            modifier: alt
            keycode: left
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-cd-back" }
        }
        {
            name: nemo_cd_forward
            modifier: alt
            keycode: right
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-cd-forward" }
        }
        {
            name: nemo_edit_command
            modifier: alt
            keycode: char_e
            mode: [emacs vi_insert]
            event: { send: executehostcommand, cmd: "nemo-edit-command" }
        }
        # Fish-style: Right arrow accepts entire autosuggestion (falls back to move right)
        {
            name: nemo_accept_hint
            modifier: none
            keycode: right
            mode: [emacs vi_insert]
            event: [
                { send: historyhintcomplete }
                { edit: moveright }
            ]
        }
        # Accept one word of autosuggestion
        {
            name: nemo_accept_hint_word
            modifier: control
            keycode: right
            mode: [emacs vi_insert]
            event: { send: historyhintwordcomplete }
        }
        {
            name: nemo_accept_hint_full_enter
            modifier: control
            keycode: enter
            mode: [emacs vi_insert]
            event: { send: historyhintcomplete }
        }
    ]
}

# PWD change hook to track directory history
export def nemo-dir-history-hook [] {
    {|before, after|
        if ($env.NEMO_DIR_NAVIGATING? | default false) { return }
        let history = ($env.NEMO_DIR_HISTORY? | default [])
        let idx = ($env.NEMO_DIR_IDX? | default 0 | into int)
        # Truncate forward history when navigating to new directory
        let truncated = ($history | first ($idx + 1))
        $env.NEMO_DIR_HISTORY = ($truncated | append $after)
        $env.NEMO_DIR_IDX = ($truncated | length)
    }
}
