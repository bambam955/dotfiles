# List available recipes
default:
    @just --List

lint:
    @shellcheck $(find . -type f ! -path './.git/*' ! -name '.shellcheckrc' \
        \( -name "*.sh" -o -name ".*rc" -o -name ".*profile" -o -name ".bash_*" \)) && echo "All checks passed!"
