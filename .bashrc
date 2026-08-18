###################################################################################################
# CORE                                                                                            #
###################################################################################################

# don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth
HISTFILE="${HOME}/.history/bash_history"

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
if [[ -x /usr/bin/lesspipe ]]; then
    eval "$(SHELL=/bin/sh lesspipe)" || true
fi

# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    if [[ -r ~/.dircolors ]]; then
        eval "$(dircolors -b ~/.dircolors)" || true
    else
        eval "$(dircolors -b)" || true
    fi
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Set a default editor
export EDITOR="nano"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


###################################################################################################
# PROMPT                                                                                          #
###################################################################################################
# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "${TERM}" in
    xterm-color|*-256color) color_prompt=yes;;
    *) ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [[ -n "${force_color_prompt}" ]]; then
    if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [[ "${color_prompt}" = yes ]]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "${TERM}" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+(${debian_chroot})}\u@\h: \w\a\]${PS1}"
    ;;
*)
    ;;
esac

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi


###################################################################################################
# GENERAL ALIASES                                                                                 #
###################################################################################################

alias rebash="source ~/.bashrc"
alias j="goto"
alias e="xdg-open"

up() {
    sudo apt update && sudo apt full-upgrade
    mise self-update
    mise up --bump --interactive
}

# Apps
alias t="time-tracker"
alias astudio="/opt/android-studio/bin/studio >/dev/null 2>&1 &"

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
    if [[ "$#" -ne 0 ]]; then
	git push "$*" origin "${branch}"
    else
        git push origin "${branch}"
    fi
}
gphf() {
    gph --force-with-lease
}
gch() {
    gcm "$*" && gph
}
gah() {
    ga && gcm "$*" && gph
}

gm() {
    git merge -m "chore: merge branch '$1' into '$(branchname)'" "$1"
}

# Delete all local branches that don't exist on the remote
gbda() {
    git fetch --prune
    git branch -vv |
        awk '/: gone]/{print $1}' |
        xargs -r git branch -D
}

# Rebase a branch from default after its target branch got squashed onto default.
grb() {
    if [[ "$#" -ne 3 ]]; then
        echo "Usage: grb <target-branch> <branch-a> <branch-b>"
        echo -e "  <branch-a>\tThe branch that was just squash-merged"
        echo -e "  <branch-b>\tThe branch that was depending on <branch-a>"
        echo -e "  <target-branch>\tThe branch that <branch-a> was just merged into"
        return 2
    fi
    git rebase --onto "$1" "$2" "$3"
}
__git_complete grb _git_rebase


###################################################################################################
# INIT                                                                                            #
###################################################################################################
source /usr/lib/git-core/git-sh-prompt || true
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\] \n\\$ '

add_to_path() {
    case ":$PATH:" in
		# already in PATH, do nothing
        *":$1:"*) ;;
		# or PATH="$PATH:$1" for append
        *) PATH="$1:$PATH" ;;       
    esac
}
export -f add_to_path

add_to_path "${HOME}/.local/bin"

# Set up local tooling
source "${HOME}/.local/bin/goto.sh" || true
eval "$(mise activate --shims bash)" || true
eval "$(fzf --bash)" || true
eval "$(just --completions bash)" || true

# Set up Golang PATH dir
gopath="$(go env GOPATH)" && [[ -n $gopath && ":$PATH:" != *":$gopath/bin:"* ]] && PATH="$gopath/bin:$PATH" && unset gopath

# Set up Android PATH dirs
ANDROID_HOME="${HOME}/Android/Sdk"
if [[ -d "${ANDROID_HOME}" ]]; then
    add_to_path "${ANDROID_HOME}/platform-tools"
    add_to_path "${ANDROID_HOME}/cmdline-tools/latest/bin"
    export ANDROID_HOME
    export JAVA_HOME="/opt/android-studio/jbr"
else
    unset ANDROID_HOME
fi

# Set up Dart global package dir
add_to_path "${HOME}/.pub-cache/bin"


###################################################################################################
# EXTRAS                                                                                          #
###################################################################################################
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source configuration files from ~/.config/bash/
mapfile -t bash_config_files < <(printf '%s\n' ~/.config/bash/*.bash | sort -V || true)
for config_file in "${bash_config_files[@]}"; do
    [[ -f ${config_file} ]] && source "${config_file}"
done
unset bash_config_files
unset config_file

