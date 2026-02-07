source /usr/lib/git-core/git-sh-prompt || true
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\] \\$ '

# Set up local tooling
source "${HOME}/.local/bin/goto.sh" || true
eval "$("${HOME}/.local/bin/mise" activate --shims bash)" || true
eval "$(fzf --bash)" || true

add_to_path() {
    case ":$PATH:" in
		# already in PATH, do nothing
        *":$1:"*) ;;
		# or PATH="$PATH:$1" for append
        *) PATH="$1:$PATH" ;;       
    esac
}

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
