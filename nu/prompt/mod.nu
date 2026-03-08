# nemo prompt — fish-style with git, duration, error indicator
# Does NOT manage colors/themes — uses terminal emulator colors

# Get abbreviated path (replace home with ~)
def nemo-prompt-dir [] {
    let cwd = ($env.PWD)
    let home = ($env.HOME)
    if ($cwd | str starts-with $home) {
        $"~($cwd | str substring ($home | str length)..)"
    } else {
        $cwd
    }
}

# Get git branch and dirty/clean status
def nemo-prompt-git [] {
    let branch_result = (do { ^git branch --show-current } | complete)
    if $branch_result.exit_code != 0 { return "" }

    let branch = ($branch_result.stdout | str trim)
    if ($branch | is-empty) {
        # Detached HEAD — show short hash
        let hash = (do { ^git rev-parse --short HEAD } | complete)
        if $hash.exit_code != 0 { return "" }
        let ref = ($hash.stdout | str trim)
        return $"(ansi yellow_dimmed) (($ref))(ansi reset)"
    }

    let status = (do { ^git status --porcelain } | complete)
    let dirty = if $status.exit_code == 0 and ($status.stdout | str trim | is-not-empty) {
        $"(ansi red)*"
    } else {
        ""
    }

    $"(ansi yellow_dimmed) ($branch)($dirty)(ansi reset)"
}

# Format command duration (only show if >2s)
def nemo-prompt-duration [] {
    let dur = ($env.CMD_DURATION_MS? | default "0" | into int)
    if $dur < 2000 { return "" }

    let secs = $dur / 1000
    if $secs < 60 {
        $" (ansi yellow)(($secs | math round --precision 1))s(ansi reset)"
    } else {
        let mins = ($secs / 60 | math floor)
        let remaining = ($secs mod 60 | math round --precision 0)
        $" (ansi yellow)($mins)m($remaining)s(ansi reset)"
    }
}

# Build the left prompt
export def nemo-prompt [] {
    let dir = (nemo-prompt-dir)
    let git = (nemo-prompt-git)
    let duration = (nemo-prompt-duration)

    # Error indicator — red prompt char on non-zero exit
    let last_exit = ($env.LAST_EXIT_CODE? | default 0)
    let prompt_char = if $last_exit != 0 {
        $"(ansi red)❯(ansi reset) "
    } else {
        $"(ansi green)❯(ansi reset) "
    }

    $"(ansi cyan_bold)($dir)(ansi reset)($git)($duration)\n($prompt_char)"
}

# Transient prompt — collapses previous prompts to minimal form
export def nemo-transient-prompt [] {
    $"(ansi green)❯(ansi reset) "
}

# Setup prompt environment
export def nemo-setup-prompt [] {
    {
        PROMPT_COMMAND: {|| nemo-prompt }
        TRANSIENT_PROMPT_COMMAND: {|| nemo-transient-prompt }
    }
}
