# Git completions with rich metadata
# Branches show last commit date and message, tags show annotations

export def nemo-complete-git-branches [] {
    let result = (do { ^git branch --format '%(refname:short)|%(committerdate:relative)|%(subject)' } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|line|
        let parts = ($line | split column '|' name date subject)
        let row = ($parts | first)
        {
            value: $row.name
            description: $"($row.date) — ($row.subject | str substring 0..60)"
        }
    }
}

export def nemo-complete-git-tags [] {
    let result = (do { ^git tag -l --format '%(refname:short)|%(creatordate:relative)|%(subject)' } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|line|
        let parts = ($line | split column '|' name date subject)
        let row = ($parts | first)
        {
            value: $row.name
            description: $"($row.date) — ($row.subject | str substring 0..40)"
        }
    }
}

export def nemo-complete-git-remotes [] {
    let result = (do { ^git remote -v } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str contains "(fetch)") }
    | each {|line|
        let parts = ($line | split row "\t")
        let name = ($parts | first)
        let url = ($parts | last | split row ' ' | first)
        {
            value: $name
            description: $url
        }
    }
}

# Combined git ref completer (branches + tags)
export def nemo-complete-git-refs [] {
    let branches = (nemo-complete-git-branches)
    let tags = (nemo-complete-git-tags)
    $branches | append $tags
}
