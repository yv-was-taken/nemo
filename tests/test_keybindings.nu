#!/usr/bin/env nu
# Tests for keybinding registration and helper functions
# Run: nu -c "overlay use nu; source tests/test_keybindings.nu"
# Note: Actual key press behavior requires interactive REPL.
# These tests verify registration and testable helper logic.

use std/assert

# --- Keybinding registration ---

let bindings = $env.config.keybindings
let nemo_bindings = ($bindings | where name =~ "nemo")

# Test: All expected keybindings are registered
let expected_names = [
    "nemo_abbrev_space"
    "nemo_literal_space"
    "nemo_sudo_toggle"
    "nemo_cd_parent"
    "nemo_cd_back"
    "nemo_cd_forward"
    "nemo_edit_command"
    "nemo_accept_hint"
    "nemo_accept_hint_word"
    "nemo_accept_hint_full_enter"
]

for name in $expected_names {
    let found = ($nemo_bindings | where name == $name)
    assert (($found | length) == 1) $"Missing keybinding: ($name)"
}
print $"✓ All ($expected_names | length) expected keybindings registered"

# Test: Hint acceptance uses correct events
let hint_binding = ($nemo_bindings | where name == "nemo_accept_hint" | first)
assert equal $hint_binding.keycode "right"
assert equal $hint_binding.modifier "none"
print "✓ Right arrow bound to hint acceptance"

let hint_word = ($nemo_bindings | where name == "nemo_accept_hint_word" | first)
assert equal $hint_word.keycode "right"
assert equal $hint_word.modifier "control"
print "✓ Ctrl+Right bound to word hint acceptance"

let hint_enter = ($nemo_bindings | where name == "nemo_accept_hint_full_enter" | first)
assert equal $hint_enter.keycode "enter"
assert equal $hint_enter.modifier "control"
print "✓ Ctrl+Enter bound to full hint acceptance"

# --- Directory history state ---

# Test: Directory history initialized
assert equal ($env.NEMO_DIR_HISTORY | length) 1
assert equal ($env.NEMO_DIR_HISTORY | first) $env.PWD
assert equal $env.NEMO_DIR_IDX 0
assert equal $env.NEMO_DIR_NAVIGATING false
print "✓ Directory history state initialized correctly"

# Test: PWD hook is registered
let pwd_hooks = ($env.config | get -o hooks.env_change.PWD | default [])
assert (($pwd_hooks | length) >= 1)
print "✓ PWD change hook registered for directory history"

# --- Sudo toggle logic ---

# Test: nemo-toggle-sudo is available
let cmds = (help commands | where name == "nemo-toggle-sudo" | get name)
assert ("nemo-toggle-sudo" in $cmds)
print "✓ nemo-toggle-sudo command available"

# --- Navigation commands ---

# Test: nemo-cd-parent is available
assert ("nemo-cd-parent" in (help commands | get name))
print "✓ nemo-cd-parent command available"

# Test: nemo-cd-back is available
assert ("nemo-cd-back" in (help commands | get name))
print "✓ nemo-cd-back command available"

# Test: nemo-cd-forward is available
assert ("nemo-cd-forward" in (help commands | get name))
print "✓ nemo-cd-forward command available"

# --- Kitty protocol ---

# Test: Kitty protocol enabled if KITTY_PID is set
if ("KITTY_PID" in $env) {
    assert $env.config.use_kitty_protocol
    print "✓ Kitty protocol enabled (KITTY_PID detected)"
} else {
    print "✓ Kitty protocol test skipped (not in kitty)"
}

print "\n✓ All keybinding tests passed"
