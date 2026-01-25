source /usr/lib/git-core/git-sh-prompt || true
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\] \\$ '

source "${HOME}/.local/bin/goto.sh" || true
eval "$("${HOME}/.local/bin/mise" activate bash)" || true
eval "$(zoxide init bash)" || true
eval "$(fzf --bash)" || true
