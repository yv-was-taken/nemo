#!/usr/bin/env nu
# Run all nemo test suites
# Usage: nu tests/run_all.nu (from project root)

let test_files = [
    "tests/test_overlay.nu"
    "tests/test_abbreviations.nu"
    "tests/test_completions.nu"
    "tests/test_prompt.nu"
    "tests/test_keybindings.nu"
    "tests/test_pkgman.nu"
]

let results = ($test_files | each {|file|
    print $"\n(ansi cyan_bold)═══ ($file) ═══(ansi reset)"
    let result = (do { ^nu -c $"overlay use nu; source ($file)" } | complete)
    print $result.stdout
    if $result.exit_code != 0 {
        print $"(ansi red)($result.stderr)(ansi reset)"
        { file: $file, passed: false }
    } else {
        { file: $file, passed: true }
    }
})

let passed = ($results | where passed == true | length)
let failed = ($results | where passed == false)
let total = ($results | length)

print $"\n(ansi cyan_bold)═══ Summary ═══(ansi reset)"
print $"Passed: ($passed)/($total)"

if ($failed | length) > 0 {
    print $"(ansi red)Failed: ($failed | get file | str join ', ')(ansi reset)"
    exit 1
} else {
    print $"(ansi green_bold)All test suites passed!(ansi reset)"
}
