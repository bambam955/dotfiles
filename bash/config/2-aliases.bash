#########################################################
# ------------------ GENERAL ALIASES ------------------ #
#########################################################

alias rebash="source ~/.bashrc"
alias j="goto"
alias e="xdg-open"

#########################################################
# -------------------- GIT ALIASES -------------------- #
#########################################################

# Function to get the working branch in a git repository
branchname() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/' || true
}

# Basic git aliases
alias gl='git log'
alias gs='git status'
alias ga='git add .'
alias gb='git branch'
alias gcb='git checkout -b'
alias gf='git fetch'
alias gt='git stash'
alias gtp='git stash pop'
alias gr='git restore .'
alias gsr='git restore --staged .'

# Git aliases requiring auto-complete
alias gco='git checkout'
alias gbd='git branch -D'
alias gbm='git branch -m'
alias gm='git merge'

source ~/.local/bin/git-completion.bash
__git_complete gco _git_checkout
__git_complete gbm _git_branch
__git_complete gbd _git_branch
__git_complete gm _git_merge

# Functions for more complicated git operations
gp() {
    local branch
    branch="$(branchname)" || true
    git pull origin "${branch}"
}
gcm() {
    git commit -m "$*"
}
gam() {
    ga && gcm "$*"
}
gph() {
    local branch
    branch="$(branchname)" || true
    git push origin "${branch}"
}
gch() {
    gcm "$*" && gph
}
gah() {
    ga && gcm "$*" && gph
}
