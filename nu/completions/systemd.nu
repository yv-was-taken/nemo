# Systemd unit completions

export def nemo-complete-systemd-units [] {
    let result = (do { ^systemctl list-unit-files --no-pager --no-legend } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|line|
        let parts = ($line | split row --regex '\s+')
        let unit = ($parts | first)
        let state = if ($parts | length) > 1 { $parts | get 1 } else { "" }
        {
            value: $unit
            description: $state
        }
    }
}
