# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source configuration files from ~/.config/bash/
mapfile -t bash_config_files < <(printf '%s\n' ~/.config/bash/[0-9]*.bash | sort -V || true)
for config_file in "${bash_config_files[@]}"; do
    [[ -f ${config_file} ]] && source "${config_file}"
done
unset bash_config_files
unset config_file
