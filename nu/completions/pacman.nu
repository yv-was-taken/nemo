# Pacman package completions

export def nemo-complete-pacman-install [] {
    # Use pacman -Ssq for available packages (names only, fast)
    let result = (do { ^pacman -Ssq } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|pkg| { value: $pkg } }
}

export def nemo-complete-pacman-remove [] {
    # Use pacman -Qq for installed packages
    let result = (do { ^pacman -Qq } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|pkg| { value: $pkg } }
}
