# Default abbreviations for nemo
# These are used when ~/.config/nemo/abbrevs.nuon doesn't exist

export def nemo-default-abbrevs [] {
    {
        gs: "git status"
        gp: "git push"
        gpl: "git pull"
        gco: "git checkout"
        gc: "git commit"
        gca: "git commit --amend"
        gd: "git diff"
        gds: "git diff --staged"
        ga: "git add"
        gl: "git log --oneline"
        gb: "git branch"
        gst: "git stash"
        gstp: "git stash pop"
        gm: "git merge"
        grb: "git rebase"
        gf: "git fetch"
        dc: "docker compose"
        dcu: "docker compose up"
        dcd: "docker compose down"
        dcr: "docker compose restart"
        sc: "sudo systemctl"
        scs: "sudo systemctl status"
        sce: "sudo systemctl enable"
        scd: "sudo systemctl disable"
    }
}
