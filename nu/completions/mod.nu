# nemo completions — external completer dispatch
# Wraps existing completers; falls through if nemo has no match

use process.nu nemo-complete-process
use git.nu [nemo-complete-git-refs, nemo-complete-git-branches, nemo-complete-git-tags, nemo-complete-git-remotes]
use ssh.nu nemo-complete-ssh-hosts
use pacman.nu [nemo-complete-pacman-install, nemo-complete-pacman-remove]
use systemd.nu nemo-complete-systemd-units
use docker.nu [nemo-complete-docker-containers, nemo-complete-docker-images]

# Commands that get PID completions
const PROCESS_CMDS = [kill signal]

# Git subcommands that get branch/ref completions
const GIT_REF_CMDS = [checkout switch merge rebase cherry-pick diff log show]
const GIT_BRANCH_CMDS = [branch]
const GIT_REMOTE_CMDS = [push pull fetch]

# Build the nemo external completer
export def nemo-build-completer [existing: closure] {
    {|spans: list<string>|
        let cmd = ($spans | first)
        let result = (nemo-dispatch $spans)
        if ($result | is-not-empty) {
            $result
        } else {
            do $existing $spans
        }
    }
}

export def nemo-build-completer-fresh [] {
    {|spans: list<string>|
        nemo-dispatch $spans
    }
}

# Dispatch completions based on command
export def nemo-dispatch [spans: list<string>] {
    let cmd = ($spans | first)

    if $cmd in $PROCESS_CMDS {
        return (nemo-complete-process ($spans | str join ' '))
    }

    if $cmd == "git" and ($spans | length) >= 2 {
        let subcmd = ($spans | get 1)
        if $subcmd in $GIT_REF_CMDS {
            return (nemo-complete-git-refs)
        }
        if $subcmd in $GIT_BRANCH_CMDS {
            return (nemo-complete-git-branches)
        }
        if $subcmd in $GIT_REMOTE_CMDS {
            return (nemo-complete-git-remotes)
        }
    }

    if $cmd == "ssh" {
        return (nemo-complete-ssh-hosts)
    }

    if $cmd == "pacman" and ($spans | length) >= 2 {
        let flag = ($spans | get 1)
        if ($flag | str starts-with "-S") {
            return (nemo-complete-pacman-install)
        }
        if ($flag | str starts-with "-R") {
            return (nemo-complete-pacman-remove)
        }
    }

    if $cmd == "systemctl" or $cmd == "sc" {
        return (nemo-complete-systemd-units)
    }

    if $cmd == "docker" and ($spans | length) >= 2 {
        let subcmd = ($spans | get 1)
        if $subcmd in [stop start restart rm logs exec inspect] {
            return (nemo-complete-docker-containers)
        }
        if $subcmd in [rmi tag push pull run] {
            return (nemo-complete-docker-images)
        }
    }

    []
}
