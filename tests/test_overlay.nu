#!/usr/bin/env nu
# nemo overlay integration tests
# Run from the project root: nu -c "overlay use nu; source tests/test_overlay.nu"

use std/assert

# Test 1: Abbreviations loaded (empty by default, like fish)
let abbrevs = $env.NEMO_ABBREVS
assert ($abbrevs | describe | str starts-with "record")
print "✓ Abbreviations loaded correctly"

# Test 2: Directory history initialized
assert equal ($env.NEMO_DIR_HISTORY | length) 1
assert equal $env.NEMO_DIR_IDX 0
print "✓ Directory history initialized"

# Test 3: External completer is set
assert $env.config.completions.external.enable
assert ($env.config.completions.external.completer | describe | str starts-with "closure")
print "✓ External completer configured"

# Test 4: Keybindings added
let nemo_bindings = ($env.config.keybindings | where name =~ "nemo")
assert (($nemo_bindings | length) >= 8)
print $"✓ ($nemo_bindings | length) nemo keybindings added"

# Test 5: Prompt set
assert ($env.PROMPT_COMMAND | describe | str starts-with "closure")
assert ($env.TRANSIENT_PROMPT_COMMAND | describe | str starts-with "closure")
print "✓ Prompt configured"

# Test 6: nemo commands available
let cmds = (help commands | where name =~ "nemo" | get name)
assert ("nemo-expand-abbrev" in $cmds)
assert ("nemo-toggle-sudo" in $cmds)
assert ("nemo-dispatch" in $cmds)
assert ("nemo install" in $cmds)
assert ("nemo remove" in $cmds)
print $"✓ ($cmds | length) nemo commands available"

# Test 7: Prompt renders without error
let prompt_output = (do $env.PROMPT_COMMAND)
assert ($prompt_output | str contains "❯")
print "✓ Prompt renders correctly"

# Test 8: Transient prompt renders
let transient = (do $env.TRANSIENT_PROMPT_COMMAND)
assert ($transient | str contains "❯")
print "✓ Transient prompt renders correctly"

print "\n✓ All tests passed"
