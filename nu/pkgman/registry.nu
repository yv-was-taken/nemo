# nemo package registry
# Stub for Phase 1 — will be populated with community packages

const REGISTRY_URL = "https://raw.githubusercontent.com/nemo-sh/registry/main/registry.nuon"

export def nemo-fetch-registry [] {
    let cache_dir = ($env.HOME | path join ".local" "share" "nemo" "cache")
    let cache_file = ($cache_dir | path join "registry.nuon")

    if ($cache_file | path exists) {
        open $cache_file
    } else {
        # Return empty registry for now
        []
    }
}

export def nemo-search-registry [query: string] {
    let registry = (nemo-fetch-registry)
    $registry | where {|pkg|
        ($pkg.name? | default "" | str contains $query)
        or ($pkg.description? | default "" | str contains $query)
    }
}
