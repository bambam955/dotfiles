#!/bin/bash

set -euo pipefail

# Colors for output
WHITE='\033[0;37m'
GREEN='\033[1;92m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"

# Function to print status messages
print_status() {
    echo -e "${WHITE}|${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Function to create symlink with backup
symlink_file() {
    local src="$1"
    local dest="$2"
    local backup_date
    local backup_dir
    local backup_path
    
    backup_date="$(date +%Y%m%d-%H%M%S)"
    backup_dir="${HOME_DIR}/.backups/${backup_date}"
    
    if [[ -e "${dest}" ]]; then
        if [[ -L "${dest}" ]]; then
            # It's already a symlink
            local link_target
            link_target="$(readlink "${dest}")" || true
            if [[ "${link_target}" == "${src}" ]]; then
                print_status "Already linked: ${dest}"
                return 0
            else
                print_warning "Symlink exists but points elsewhere: ${dest}"
                rm "${dest}"
            fi
        else
            # It's a regular file, back it up
            backup_path="${backup_dir}${dest}"
            mkdir -p "$(dirname "${backup_path}")"
            print_warning "Backing up existing file: ${dest} -> .backups/${backup_date}${dest}"
            mv "${dest}" "${backup_path}"
        fi
    fi
    
    print_status "Linking ${src} -> ${dest}"
    ln -s "${src}" "${dest}"
}

# Function to install mise if not already installed
install_mise() {
    if command -v mise &> /dev/null; then
        return 0
    fi
    
    print_status "Installing mise..."
    curl https://mise.run | sh
    
    # Add mise to PATH for this session
    export PATH="${HOME_DIR}/.local/bin:${PATH}"
}

# Function to setup mise tools
setup_mise() {
    if ! command -v mise &> /dev/null; then
        print_error "mise installation failed or not found in PATH"
        return 1
    fi
    
    print_status "Setting up mise configuration..."
    
    # Create .config/mise directory if it doesn't exist
    mkdir -p "${HOME_DIR}/.config/mise"
    
    # Symlink mise config
    symlink_file "${SCRIPT_DIR}/tools/mise/config.toml" "${HOME_DIR}/.config/mise/config.toml"
    
    print_status "Installing tools via mise..."
    mise install
}

main() {
    echo -e "\033[1;34m=== Installing dotfiles from ${SCRIPT_DIR} ===${NC}"
    
    # Bash configuration
    print_status "Setting up bash configuration..."
    symlink_file "${SCRIPT_DIR}/bash/.bashrc" "${HOME_DIR}/.bashrc"
    symlink_file "${SCRIPT_DIR}/bash/.bash_logout" "${HOME_DIR}/.bash_logout"
    symlink_file "${SCRIPT_DIR}/bash/.profile" "${HOME_DIR}/.profile"
    
    # Bash config directory
    mkdir -p "${HOME_DIR}/.config/bash"
    symlink_file "${SCRIPT_DIR}/bash/config/core.bash" "${HOME_DIR}/.config/bash/core.bash"
    symlink_file "${SCRIPT_DIR}/bash/config/prompt.bash" "${HOME_DIR}/.config/bash/prompt.bash"
    symlink_file "${SCRIPT_DIR}/bash/config/completion.bash" "${HOME_DIR}/.config/bash/completion.bash"
    symlink_file "${SCRIPT_DIR}/bash/config/aliases.bash" "${HOME_DIR}/.config/bash/aliases.bash"
    symlink_file "${SCRIPT_DIR}/bash/config/git-aliases.bash" "${HOME_DIR}/.config/bash/git-aliases.bash"
    symlink_file "${SCRIPT_DIR}/bash/config/init.bash" "${HOME_DIR}/.config/bash/init.bash"
    print_success "Bash configuration complete"
    
    # Git configuration
    print_status "Setting up git configuration..."
    symlink_file "${SCRIPT_DIR}/git/.gitconfig" "${HOME_DIR}/.gitconfig"
    mkdir -p "${HOME_DIR}/.local/bin"
    symlink_file "${SCRIPT_DIR}/git/git-completion.bash" "${HOME_DIR}/.local/bin/git-completion.bash"
    print_success "Git configuration complete"
    
    # GitHub CLI configuration
    print_status "Setting up GitHub CLI configuration..."
    mkdir -p "${HOME_DIR}/.config/gh"
    symlink_file "${SCRIPT_DIR}/gh/config.yml" "${HOME_DIR}/.config/gh/config.yml"
    symlink_file "${SCRIPT_DIR}/gh/hosts.yml" "${HOME_DIR}/.config/gh/hosts.yml"
    print_success "GitHub CLI configuration complete"
    
    # Goto setup
    print_status "Setting up goto..."
    mkdir -p "${HOME_DIR}/.local/bin"
    symlink_file "${SCRIPT_DIR}/goto/goto.sh" "${HOME_DIR}/.local/bin/goto.sh"
    print_success "Goto setup complete"
    
    # Mise setup
    install_mise
    setup_mise
    print_success "Mise tool install complete"
    
    echo -e "\n${GREEN}=== Dotfiles installation complete! ===${NC}"
}

main "$@"
