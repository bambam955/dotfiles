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
PROFILE="${1:-}"

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
	echo -e "${YELLOW}! $1${NC}" >&2
}

# Function to validate profile
validate_profile() {
	local profiles_list
	profiles_list=$(find "${SCRIPT_DIR}/profiles" -maxdepth 1 -type d -not -path "${SCRIPT_DIR}/profiles" -exec basename {} \; | tr '\n' ' ') || true

	if [[ -z "${PROFILE}" ]]; then
		print_error "No profile specified"
		print_error "Usage: $0 [ ${profiles_list}]"
		exit 1
	fi

	if [[ ! -d "${SCRIPT_DIR}/profiles/${PROFILE}" ]]; then
		print_error "Profile '${PROFILE}' not found"
		print_error "Available profiles: ${profiles_list}"
		exit 1
	fi
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

	if [[ -e "${dest}" ]] && [[ ! -L "${dest}" ]]; then
		# It's a regular file, back it up
		backup_path="${backup_dir}${dest}"
		mkdir -p "$(dirname "${backup_path}")"
		print_warning "Backing up existing file: ${dest} -> .backups/${backup_date}${dest}"
		mv "${dest}" "${backup_path}"
	elif [[ -L "${dest}" ]]; then
		if [[ -e "${dest}" ]]; then
			# It's already a symlink to an existing file
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
			# Broken symlink
			print_warning "Symlink exists but points to invalid location: ${dest}"
			rm "${dest}"
		fi
	fi

	print_status "Linking ${src} -> ${dest}"
	ln -s "${src}" "${dest}"
}

# Function to install mise if not already installed
install_mise() {
	if command -v mise &>/dev/null; then
		return 0
	fi

	print_status "Installing mise..."
	curl https://mise.run | sh

	# Add mise to PATH for this session
	export PATH="${HOME_DIR}/.local/bin:${PATH}"
}

# Function to setup mise tools
setup_mise() {
	if ! command -v mise &>/dev/null; then
		print_error "mise installation failed or not found in PATH"
		return 1
	fi

	print_status "Setting up mise configuration..."

	# Create .config/mise directory if it doesn't exist
	mkdir -p "${HOME_DIR}/.config/mise"

	# Symlink mise config
	symlink_file "${SCRIPT_DIR}/profiles/${PROFILE}/mise/config.toml" "${HOME_DIR}/.config/mise/config.toml"

	print_status "Installing tools via mise..."
	mise install
	mise prune --yes
}

main() {
	echo -e "\033[1;34m=== Installing dotfiles from ${SCRIPT_DIR} ===${NC}"

	# Validate profile
	validate_profile
	print_success "Using profile: ${PROFILE}"

	# Bash configuration
	print_status "Setting up bash configuration..."
	symlink_file "${SCRIPT_DIR}/bash/.bashrc" "${HOME_DIR}/.bashrc"
	symlink_file "${SCRIPT_DIR}/bash/.bash_logout" "${HOME_DIR}/.bash_logout"
	symlink_file "${SCRIPT_DIR}/bash/.profile" "${HOME_DIR}/.profile"

	# Bash config directory
	mkdir -p "${HOME_DIR}/.config/bash"
	for config_file in "${SCRIPT_DIR}/bash/config"/*.bash "${SCRIPT_DIR}/profiles/${PROFILE}/bash"/*.bash; do
		symlink_file "${config_file}" "${HOME_DIR}/.config/bash/$(basename "${config_file}")"
	done
	unset config_file
	print_success "Bash configuration complete"

	# Git configuration
	print_status "Setting up git configuration..."
	symlink_file "${SCRIPT_DIR}/profiles/${PROFILE}/git/.gitconfig" "${HOME_DIR}/.gitconfig"
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
