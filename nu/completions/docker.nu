# Docker container and image completions

export def nemo-complete-docker-containers [] {
    let result = (do { ^docker ps --format '{{.Names}}|{{.Image}}|{{.Status}}' } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|line|
        let parts = ($line | split column '|' name image status)
        let row = ($parts | first)
        {
            value: $row.name
            description: $"($row.image) ($row.status)"
        }
    }
}

export def nemo-complete-docker-images [] {
    let result = (do { ^docker images --format '{{.Repository}}:{{.Tag}}|{{.Size}}|{{.CreatedSince}}' } | complete)
    if $result.exit_code != 0 { return [] }

    $result.stdout
    | lines
    | where {|l| ($l | str trim | is-not-empty) }
    | each {|line|
        let parts = ($line | split column '|' repo size created)
        let row = ($parts | first)
        {
            value: $row.repo
            description: $"($row.size) ($row.created)"
        }
    }
}
