# SSH host completions from ~/.ssh/config

export def nemo-complete-ssh-hosts [] {
    let config_path = ($env.HOME | path join ".ssh" "config")
    if not ($config_path | path exists) { return [] }

    open $config_path
    | lines
    | where {|l| ($l | str trim | str starts-with "Host ") }
    | each {|line|
        $line
        | str trim
        | str substring 5..
        | split row ' '
        | where {|h| not ($h | str contains "*") }
    }
    | flatten
    | each {|host| { value: $host, description: "ssh host" } }
}
