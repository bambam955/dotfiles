# Agent Guidelines for Shell Scripts

## Commands
- **Lint**: `shellcheck *.sh` - Check for common shell script issues
- **Test single script**: `bash -n script.sh` - Syntax check without execution
- **Run script**: `bash script.sh` - Execute with bash for consistency

## Code Style
- Use `#!/bin/bash` shebang for all scripts
- Use `[[ ]]` for conditionals instead of `[ ]`
- Quote variables: `"$variable"` to prevent word splitting
- Use `set -euo pipefail` for strict error handling
- Functions: `function_name() { ... }` with lowercase names
- Error messages to stderr: `echo "Error: message" >&2`
- Exit codes: Use 0 for success, 1+ for errors

## Naming Conventions
- Scripts: lowercase with hyphens (e.g., `scan-ips.sh`)
- Variables: UPPERCASE for globals, lowercase for locals
- Functions: lowercase_with_underscores

## Error Handling
- Check command success: `command || exit 1`
- Validate arguments: `[[ $# -eq 1 ]] || { echo "Usage: $0 arg" >&2; exit 1; }`
- Use traps for cleanup: `trap 'rm -f "$tempfile"' EXIT`