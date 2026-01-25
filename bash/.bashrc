# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source configuration files from ~/.config/bash/
for config_file in ~/.config/bash/{core,prompt,completion,aliases,git-aliases,init}.bash; do
    [[ -f "${config_file}" ]] && source "${config_file}"
done
unset config_file
