#!/usr/bin/env nu
# Tests for prompt rendering
# Run: nu -c "overlay use nu; source tests/test_prompt.nu"

use std/assert

# Test: Prompt contains directory
let prompt = (do $env.PROMPT_COMMAND)
assert ($prompt | str contains "~")
print "✓ Prompt contains directory"

# Test: Prompt contains prompt character
assert ($prompt | str contains "❯")
print "✓ Prompt contains ❯ character"

# Test: Prompt contains git branch (we're in a git repo)
assert ($prompt | str contains "master")
print "✓ Prompt shows git branch"

# Test: Transient prompt is minimal
let transient = (do $env.TRANSIENT_PROMPT_COMMAND)
assert ($transient | str contains "❯")
# Transient should NOT contain directory or git info
assert (not ($transient | str contains "~"))
print "✓ Transient prompt is minimal (just ❯)"

# Test: PROMPT_INDICATOR is blank (nemo includes ❯ in prompt itself)
assert equal $env.PROMPT_INDICATOR ""
print "✓ PROMPT_INDICATOR is blank (no double prompt)"

# Test: TRANSIENT_PROMPT_INDICATOR is blank
assert equal $env.TRANSIENT_PROMPT_INDICATOR ""
print "✓ TRANSIENT_PROMPT_INDICATOR is blank"

# Test: Prompt renders without error (non-zero length output)
let p = (nemo-prompt)
assert ($p | str length | $in > 0)
print "✓ Prompt renders without crash"

# Test: Transient prompt renders
let t = (nemo-transient-prompt)
assert ($t | str length | $in > 0)
print "✓ Transient prompt renders without crash"

print "\n✓ All prompt tests passed"
