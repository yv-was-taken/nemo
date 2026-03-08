#!/usr/bin/env nu
# Tests for abbreviation engine
# Run: nu -c "overlay use nu; source tests/test_abbreviations.nu"

use std/assert

# Test: Empty abbreviations loaded by default
assert ($env.NEMO_ABBREVS | describe | str starts-with "record")
print "✓ Abbreviations loaded as record"

# Test: Custom abbreviations config file is valid NUON when present
let config_dir = ($env.HOME | path join ".config" "nemo")
let config_path = ($config_dir | path join "abbrevs.nuon")
if ($config_path | path exists) {
    let loaded = (open $config_path)
    assert equal ($loaded | describe) "record"
    print "✓ Custom abbreviations file is valid NUON record"
} else {
    print "✓ No custom abbreviations file (using defaults)"
}

# Test: Abbreviation keybindings registered
let abbrev_bindings = ($env.config.keybindings | where name =~ "nemo_abbrev")
assert (($abbrev_bindings | length) >= 1)
let space_binding = ($abbrev_bindings | where name == "nemo_abbrev_space")
assert equal ($space_binding | length) 1
print "✓ Abbreviation space keybinding registered"

# Test: Literal space keybinding registered (Ctrl+Space escape hatch)
let literal_space = ($env.config.keybindings | where name == "nemo_literal_space")
assert equal ($literal_space | length) 1
print "✓ Ctrl+Space literal space keybinding registered"

print "\n✓ All abbreviation tests passed"
