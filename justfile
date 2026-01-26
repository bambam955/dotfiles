# List available recipes
default:
    @just --list

# Install dotfiles for home profile
home:
    ./install.sh home

# Install dotfiles for work profile
work:
    ./install.sh work

# Lint shell scripts
lint:
    @shellcheck $(find . -type f ! -path './.git/*' ! -name '.shellcheckrc' \
        \( -name "*.sh" -o -name ".*rc" -o -name ".*profile" -o -name ".bash_*" \)) && echo "All checks passed!"
