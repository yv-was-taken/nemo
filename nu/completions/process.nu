# PID completions with CPU/memory info
# Shows process name, CPU%, and memory when completing PIDs

def nemo-complete-pid [] {
    ps | each {|proc|
        let mem_mb = ($proc.mem | into int) / 1_000_000
        {
            value: ($proc.pid | into string)
            description: $"($proc.name) cpu:($proc.cpu | math round --precision 1)% mem:($mem_mb | math round --precision 0)M"
        }
    }
}

# Filter processes by name for kill/signal completions
export def nemo-complete-process [context: string] {
    let parts = ($context | str trim | split row ' ')
    let filter = if ($parts | length) > 1 { $parts | last } else { "" }

    nemo-complete-pid | where {|row|
        if ($filter | is-empty) {
            true
        } else {
            ($row.description | str downcase | str contains ($filter | str downcase))
                or ($row.value | str contains $filter)
        }
    }
}
