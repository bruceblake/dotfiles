#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}   ULTIMATE NEOVIM INSTALLATION SCRIPT        ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo
echo -e "This script will try ${YELLOW}multiple methods${NC} to install Neovim"
echo -e "and ensure it works on your system."
echo

# Log function
log() {
  echo -e "${GREEN}[LOG]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

section() {
  echo
  echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to test if nvim is working
test_nvim() {
  local nvim_path="$1"
  log "Testing Neovim at $nvim_path"
  
  if [ -x "$nvim_path" ]; then
    log "Neovim binary exists and is executable"
    
    # Test version command
    if "$nvim_path" --version > /dev/null 2>&1; then
      local version=$("$nvim_path" --version | head -n 1)
      success "Neovim works! Version: $version"
      return 0
    else
      error "Neovim exists but --version command failed"
    fi
  else
    error "Neovim binary is not executable or doesn't exist"
  fi
  
  return 1
}

# Function to clean up any previous installation attempts
cleanup() {
  section "Cleaning up previous installation attempts"
  
  # Remove any temporary Neovim binaries we might have created
  if [ -f "$HOME/.local/bin/nvim" ]; then
    log "Removing existing Neovim in ~/.local/bin"
    rm -f "$HOME/.local/bin/nvim"
  fi
  
  # Try to find and kill any hanging nvim processes
  if pgrep nvim > /dev/null; then
    warn "Found running nvim processes. Attempting to kill them."
    pkill -9 nvim || true
  fi
}

# Function to ensure PATH is properly set up
setup_path() {
  section "Setting up PATH"
  
  # Create local bin directory
  mkdir -p "$HOME/.local/bin"
  
  # Check if ~/.local/bin is in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    log "Adding ~/.local/bin to PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    export PATH="$HOME/.local/bin:$PATH"
  else
    log "~/.local/bin is already in PATH"
  fi
}

# Function to try system package manager
try_package_manager() {
  section "Trying system package manager"
  
  # Detect OS
  local os="unknown"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    os=$ID
  elif [ -f /etc/debian_version ]; then
    os="debian"
  elif [ -f /etc/fedora-release ]; then
    os="fedora"
  elif [ -f /etc/arch-release ]; then
    os="arch"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    os="macos"
  fi
  
  log "Detected OS: $os"
  
  case $os in
    ubuntu|debian|pop|mint|kali)
      log "Installing Neovim with apt"
      sudo apt update
      sudo apt install -y neovim
      ;;
    fedora|centos|rhel)
      log "Installing Neovim with dnf"
      sudo dnf install -y neovim
      ;;
    arch|manjaro|endeavouros)
      log "Installing Neovim with pacman"
      sudo pacman -S --noconfirm neovim
      ;;
    opensuse|sles)
      log "Installing Neovim with zypper"
      sudo zypper install -y neovim
      ;;
    alpine)
      log "Installing Neovim with apk"
      sudo apk add neovim
      ;;
    macos)
      if command -v brew &> /dev/null; then
        log "Installing Neovim with Homebrew"
        brew install neovim
      else
        warn "Homebrew not found on macOS"
        return 1
      fi
      ;;
    *)
      warn "Unsupported OS for package manager installation: $os"
      return 1
      ;;
  esac
  
  # Test if it worked
  if command -v nvim &> /dev/null; then
    success "Neovim installed via package manager!"
    test_nvim "$(command -v nvim)"
    return $?
  else
    warn "Package manager installation did not add nvim to PATH"
    return 1
  fi
}

# Function to try AppImage
try_appimage() {
  section "Trying AppImage installation"
  
  local nvim_dir="$HOME/.local/bin"
  local appimage_path="$nvim_dir/nvim.appimage"
  
  log "Downloading latest Neovim AppImage..."
  mkdir -p "$nvim_dir"
  
  if command -v curl &> /dev/null; then
    curl -L -o "$appimage_path" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  elif command -v wget &> /dev/null; then
    wget -O "$appimage_path" https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  else
    error "Neither curl nor wget is available for downloading"
    return 1
  fi
  
  log "Making AppImage executable"
  chmod +x "$appimage_path"
  
  # Check if AppImage works directly
  if test_nvim "$appimage_path"; then
    log "AppImage works directly, creating symlink"
    ln -sf "$appimage_path" "$nvim_dir/nvim"
    success "AppImage successfully installed at $nvim_dir/nvim"
    return 0
  else
    warn "AppImage does not work directly, trying to extract it"
    
    # Try to extract the AppImage
    log "Extracting AppImage..."
    cd "$nvim_dir"
    "$appimage_path" --appimage-extract > /dev/null 2>&1
    
    if [ -d "$nvim_dir/squashfs-root" ]; then
      log "AppImage extracted, creating symlink"
      chmod +x "$nvim_dir/squashfs-root/usr/bin/nvim"
      ln -sf "$nvim_dir/squashfs-root/usr/bin/nvim" "$nvim_dir/nvim"
      
      if test_nvim "$nvim_dir/nvim"; then
        success "Extracted AppImage works!"
        return 0
      else
        error "Extracted AppImage doesn't work"
      fi
    else
      error "Failed to extract AppImage"
    fi
  fi
  
  return 1
}

# Function to try building from source
try_build_from_source() {
  section "Trying to build Neovim from source"
  
  # Check for build dependencies
  local missing_deps=0
  for cmd in git gcc make cmake unzip; do
    if ! command -v $cmd &> /dev/null; then
      warn "Missing dependency: $cmd"
      missing_deps=1
    fi
  done
  
  if [ $missing_deps -eq 1 ]; then
    error "Missing build dependencies. Skipping build from source."
    return 1
  fi
  
  log "Cloning Neovim repository..."
  local build_dir="$HOME/.neovim_build"
  rm -rf "$build_dir"
  mkdir -p "$build_dir"
  
  git clone --depth=1 https://github.com/neovim/neovim.git "$build_dir"
  
  if [ ! -d "$build_dir" ]; then
    error "Failed to clone Neovim repository"
    return 1
  fi
  
  log "Building Neovim (this may take a while)..."
  cd "$build_dir"
  make CMAKE_BUILD_TYPE=Release -j$(nproc)
  
  if [ $? -ne 0 ]; then
    error "Failed to build Neovim"
    return 1
  fi
  
  log "Installing Neovim to ~/.local"
  make CMAKE_INSTALL_PREFIX="$HOME/.local" install
  
  if test_nvim "$HOME/.local/bin/nvim"; then
    success "Neovim built and installed successfully!"
    return 0
  else
    error "Neovim was built but doesn't seem to work"
    return 1
  fi
}

# Function to create a wrapper script as a last resort
create_wrapper() {
  section "Creating a Neovim wrapper script"
  
  local wrapper_path="$HOME/.local/bin/nvim"
  
  log "Searching for any Neovim installation..."
  local nvim_paths=()
  
  # Look in common locations
  for path in /usr/bin/nvim /usr/local/bin/nvim /opt/nvim/bin/nvim /snap/bin/nvim /opt/homebrew/bin/nvim /usr/sbin/nvim; do
    if [ -x "$path" ]; then
      log "Found Neovim at $path"
      nvim_paths+=("$path")
    fi
  done
  
  # Look for any command called nvim
  if command -v nvim &> /dev/null; then
    local cmd_path=$(command -v nvim)
    log "Found Neovim in PATH at $cmd_path"
    nvim_paths+=("$cmd_path")
  fi
  
  # If we found Neovim installations, create a wrapper
  if [ ${#nvim_paths[@]} -gt 0 ]; then
    log "Creating wrapper script at $wrapper_path"
    
    cat > "$wrapper_path" << 'EOF'
#!/bin/bash

# Try to find nvim in common locations
for nvim_path in /usr/bin/nvim /usr/local/bin/nvim /opt/nvim/bin/nvim /snap/bin/nvim /opt/homebrew/bin/nvim /usr/sbin/nvim $(command -v nvim 2>/dev/null)
do
  if [ -x "$nvim_path" ] && [ "$nvim_path" != "$0" ]; then
    exec "$nvim_path" "$@"
    exit $?
  fi
done

# If we couldn't find nvim, print an error
echo "Error: Could not locate a working Neovim installation."
echo "Please install Neovim or check your PATH."
exit 1
EOF
    
    chmod +x "$wrapper_path"
    
    if test_nvim "$wrapper_path"; then
      success "Wrapper script works!"
      return 0
    else
      error "Wrapper script doesn't work"
    fi
  else
    warn "No existing Neovim installations found"
  fi
  
  return 1
}

# Function to test and set up Neovim configuration
setup_config() {
  section "Setting up Neovim configuration"
  
  # Ensure Neovim config directory exists
  mkdir -p "$HOME/.config/nvim"
  
  # Check if nvim config is already a symlink
  if [ -L "$HOME/.config/nvim" ]; then
    log "Neovim config is already a symlink to $(readlink -f "$HOME/.config/nvim")"
    if [ ! -e "$HOME/.config/nvim" ]; then
      warn "Symlink target doesn't exist, recreating"
      rm "$HOME/.config/nvim"
      ln -sf "$(pwd)/nvim" "$HOME/.config/nvim"
    fi
  else
    # Back up existing config if it's not a symlink and not empty
    if [ -d "$HOME/.config/nvim" ] && [ "$(ls -A "$HOME/.config/nvim")" ]; then
      local backup_dir="$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
      log "Backing up existing Neovim config to $backup_dir"
      mv "$HOME/.config/nvim" "$backup_dir"
    else
      # Remove empty directory
      rm -rf "$HOME/.config/nvim"
    fi
    
    # Create symlink to our dotfiles nvim config
    log "Creating symlink to dotfiles Neovim config"
    ln -sf "$(pwd)/nvim" "$HOME/.config/nvim"
  fi
  
  success "Neovim config set up!"
}

# Main installation process
main() {
  cleanup
  setup_path
  
  # Try different installation methods in sequence
  local installed=false
  
  if try_package_manager; then
    installed=true
  elif try_appimage; then
    installed=true
  elif try_build_from_source; then
    installed=true
  elif create_wrapper; then
    installed=true
  fi
  
  if $installed; then
    setup_config
    section "Installation Complete!"
    success "Neovim has been successfully installed and configured!"
    echo
    echo -e "${GREEN}To start using Neovim:${NC}"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Run: nvim"
    echo
    echo -e "${YELLOW}Note:${NC} On first run, Neovim will install plugins automatically."
    echo "This may take a few minutes. Please be patient."
    echo
    echo -e "${BLUE}===============================================${NC}"
    return 0
  else
    section "Installation Failed"
    error "All installation methods failed."
    echo
    echo -e "${YELLOW}As a last resort, you can try:${NC}"
    echo "1. Installing vim instead: ./use_vim_instead.sh"
    echo "2. Manually installing Neovim following the official guide:"
    echo "   https://github.com/neovim/neovim/wiki/Installing-Neovim"
    echo
    echo -e "${BLUE}===============================================${NC}"
    return 1
  fi
}

# Run the main function
main