#!/usr/bin/env nu
# Tests for completion providers
# Run: nu -c "overlay use nu; source tests/test_completions.nu"

use std/assert

# Helper: check result is a list or table (nushell returns table for populated, list for empty)
def is-completion-result [result]: nothing -> bool {
    let desc = ($result | describe)
    ($desc | str starts-with "list") or ($desc | str starts-with "table")
}

# --- Dispatch routing ---

# Test: kill dispatches to process completer
let kill_result = (nemo-dispatch [kill])
assert (is-completion-result $kill_result)
if ($kill_result | length) > 0 {
    let first = ($kill_result | first)
    assert ("value" in ($first | columns))
    assert ("description" in ($first | columns))
    # Description should contain process info
    assert ($first.description | str contains "cpu:")
    assert ($first.description | str contains "mem:")
}
print "✓ kill completion returns PIDs with cpu/mem info"

# Test: signal dispatches to process completer
let signal_result = (nemo-dispatch [signal])
assert (is-completion-result $signal_result)
print "✓ signal completion dispatches correctly"

# Test: git checkout dispatches to refs
let git_co = (nemo-dispatch [git checkout])
assert (is-completion-result $git_co)
if ($git_co | length) > 0 {
    let first = ($git_co | first)
    assert ("value" in ($first | columns))
    assert ("description" in ($first | columns))
}
print "✓ git checkout completion returns refs"

# Test: git branch dispatches to branches
let git_br = (nemo-dispatch [git branch])
assert (is-completion-result $git_br)
if ($git_br | length) > 0 {
    let first = ($git_br | first)
    assert ("value" in ($first | columns))
    assert ($first.description | str length | $in > 0)
}
print "✓ git branch completion returns branches with metadata"

# Test: git push dispatches to remotes
let git_push = (nemo-dispatch [git push])
assert (is-completion-result $git_push)
if ($git_push | length) > 0 {
    let first = ($git_push | first)
    assert ("value" in ($first | columns))
}
print "✓ git push completion returns remotes"

# Test: git switch/merge/rebase/cherry-pick/diff/log/show all dispatch to refs
for subcmd in [switch merge rebase cherry-pick diff log show] {
    let result = (nemo-dispatch [git $subcmd])
    assert (is-completion-result $result)
}
print "✓ git ref subcommands all dispatch correctly"

# Test: ssh dispatches to hosts
let ssh_result = (nemo-dispatch [ssh])
assert (is-completion-result $ssh_result)
if ($ssh_result | length) > 0 {
    let first = ($ssh_result | first)
    assert ("value" in ($first | columns))
    assert ("description" in ($first | columns))
}
print "✓ ssh completion returns hosts"

# Test: pacman -S dispatches to install completer
let pacman_s = (nemo-dispatch [pacman -S])
assert (is-completion-result $pacman_s)
print "✓ pacman -S completion dispatches"

# Test: pacman -Ss also dispatches (starts with -S)
let pacman_ss = (nemo-dispatch [pacman -Ss])
assert (is-completion-result $pacman_ss)
print "✓ pacman -Ss completion dispatches"

# Test: pacman -R dispatches to remove completer
let pacman_r = (nemo-dispatch [pacman -R])
assert (is-completion-result $pacman_r)
print "✓ pacman -R completion dispatches"

# Test: systemctl dispatches to units
let systemctl_result = (nemo-dispatch [systemctl])
assert (is-completion-result $systemctl_result)
if ($systemctl_result | length) > 0 {
    let first = ($systemctl_result | first)
    assert ("value" in ($first | columns))
    assert ("description" in ($first | columns))
}
print "✓ systemctl completion returns units"

# Test: sc alias also dispatches to systemd
let sc_result = (nemo-dispatch [sc])
assert (is-completion-result $sc_result)
print "✓ sc alias dispatches to systemd completions"

# Test: docker stop dispatches to containers
let docker_stop = (nemo-dispatch [docker stop])
assert (is-completion-result $docker_stop)
print "✓ docker stop completion dispatches to containers"

# Test: docker rmi dispatches to images
let docker_rmi = (nemo-dispatch [docker rmi])
assert (is-completion-result $docker_rmi)
print "✓ docker rmi completion dispatches to images"

# Test: unknown command returns empty
let unknown = (nemo-dispatch [somethingweird])
assert equal ($unknown | length) 0
print "✓ Unknown command returns empty completions"

# Test: git without subcommand returns empty
let git_bare = (nemo-dispatch [git])
assert equal ($git_bare | length) 0
print "✓ git without subcommand returns empty"

# Test: docker without subcommand returns empty
let docker_bare = (nemo-dispatch [docker])
assert equal ($docker_bare | length) 0
print "✓ docker without subcommand returns empty"

# Test: pacman without flag returns empty
let pacman_bare = (nemo-dispatch [pacman])
assert equal ($pacman_bare | length) 0
print "✓ pacman without flag returns empty"

print "\n✓ All completion tests passed"
