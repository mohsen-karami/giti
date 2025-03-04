#!/bin/bash

# Function to check and validate requirements
check_requirements() {
  # Check if script is run with sudo/root when needed
  if [ "$EUID" -ne 0 ] && [ "$os_type" != "Windows" ]; then
    echo "==============================================="
    echo "This script must be run with sudo privileges for the following reasons:"
    echo ""
    echo "1. System-wide Installation:"
    echo "   - Files will be installed in system directories like /usr/local/"
    echo "   - This ensures the tool is available for ALL users on the system"
    echo ""
    echo "2. Protected Directory Access:"
    echo "   - Need to create/modify files in protected system directories"
    echo "   - Requires root access to modify /usr/local/bin or /opt/homebrew/bin"
    echo ""
    echo "3. Package Management:"
    echo "   - May need to install system dependencies (like Git)"
    echo "   - Package installation requires root privileges"
    echo ""
    echo "4. File Permissions:"
    echo "   - Need to set proper executable permissions for security"
    echo "   - Requires root access to set system-level file permissions"
    echo ""
    echo "To run with sudo, use either:"
    echo "sudo bash $0    (recommended)"
    echo "  or"
    echo "chmod +x $0 && sudo $0"
    echo "==============================================="
    exit 1
  fi

  # Validate required commands exist
  for cmd in mktemp chmod mkdir rm; do
    if ! command -v $cmd &> /dev/null; then
      echo "Required command '$cmd' not found"
      exit 1
    fi
  done
}

# Function to install Git
install_git() {
  if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    case "$os_type" in
      Linux)
        sudo apt-get update || { echo "Failed to update package list"; exit 1; }
        sudo apt-get install -y git || { echo "Failed to install git"; exit 1; }
        ;;
      Darwin)
        if ! command -v brew &> /dev/null; then
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || exit 1
        fi
    if [ "$(uname -m)" == "arm64" ]; then
          arch -arm64 brew install git || exit 1
  else
          brew install git || exit 1
  fi
        ;;
      Windows)
        echo "Please install Git manually from https://git-scm.com/downloads"
    exit 1
        ;;
    esac
  fi
}

install_for_os() {
  local os_type=$1
  local temp_dir
  temp_dir=$(mktemp -d) || { echo "Failed to create temp directory"; exit 1; }

  # Ensure temp directory cleanup on exit
  trap 'rm -rf "$temp_dir"' EXIT

  git clone https://github.com/mohsen-karami/giti.git "$temp_dir" || {
    echo "Failed to clone repository"
    exit 1
  }

  cd "$temp_dir" || {
    echo "Failed to change directory"
    exit 1
  }

  [ -f "giti.sh" ] || {
    echo "Error: giti file not found in repository"
    exit 1
  }

  chmod +x giti.sh || exit 1

  case "$os_type" in
    Linux)
      sudo mkdir -p /usr/local/share/giti || exit 1
      sudo cp -r . /usr/local/share/giti/ || exit 1
      install_linux
      ;;
    Darwin)
      if [ "$(uname -m)" == "arm64" ]; then
        sudo mkdir -p /opt/homebrew/share/giti || exit 1
        sudo cp -r . /opt/homebrew/share/giti/ || exit 1
        install_darwin_arm
      else
        sudo mkdir -p /usr/local/share/giti || exit 1
        sudo cp -r . /usr/local/share/giti/ || exit 1
        install_darwin_intel
      fi
      ;;
    Windows)
      mkdir -p /c/ProgramData/giti || exit 1
      cp -r . /c/ProgramData/giti/ || exit 1
      install_windows
      ;;
    *)
      echo "Unsupported OS: $os_type"
      exit 1
      ;;
  esac
}

install_linux() {
  cat << 'EOF' | sudo tee /usr/local/bin/giti > /dev/null || exit 1
#!/bin/bash
GITI_PATH="/usr/local/share/giti"
[ -d "$GITI_PATH" ] || { echo "Error: GITI_PATH ($GITI_PATH) does not exist"; exit 1; }
exec "$GITI_PATH/giti.sh" "$@"
EOF
  sudo chmod 755 /usr/local/bin/giti || exit 1
  sudo chmod 755 /usr/local/share/giti/giti.sh || exit 1
  sudo chmod 755 /usr/local/share/giti/commands/*.sh || exit 1
}

install_darwin_arm() {
  cat << 'EOF' | sudo tee /opt/homebrew/bin/giti > /dev/null || exit 1
#!/bin/bash
GITI_PATH="/opt/homebrew/share/giti"
[ -d "$GITI_PATH" ] || { echo "Error: GITI_PATH ($GITI_PATH) does not exist"; exit 1; }
exec "$GITI_PATH/giti.sh" "$@"
EOF
  sudo chmod +x /opt/homebrew/bin/giti || exit 1
  sudo chmod +x /opt/homebrew/share/giti/giti.sh || exit 1
  sudo chmod +x /opt/homebrew/share/giti/commands/*.sh || exit 1
}

install_darwin_intel() {
  cat << 'EOF' | sudo tee /usr/local/bin/giti > /dev/null || exit 1
#!/bin/bash
GITI_PATH="/usr/local/share/giti"
[ -d "$GITI_PATH" ] || { echo "Error: GITI_PATH ($GITI_PATH) does not exist"; exit 1; }
exec "$GITI_PATH/giti.sh" "$@"
EOF
  sudo chmod 755 /usr/local/bin/giti || exit 1
  sudo chmod 755 /usr/local/share/giti/giti.sh || exit 1
  sudo chmod 755 /usr/local/share/giti/commands/*.sh || exit 1
}

install_windows() {
  cat << 'EOF' > /c/ProgramData/giti/giti.cmd || exit 1
@echo off
"%SYSTEMDRIVE%\Program Files\Git\bin\bash.exe" "/c/ProgramData/giti/giti.sh" %*
EOF
  chmod +x /c/ProgramData/giti/giti.sh || exit 1
  chmod +x /c/ProgramData/giti/commands/*.sh || exit 1
  echo 'export PATH=$PATH:/c/ProgramData/giti' >> ~/.bashrc || exit 1
}
os_type=$(uname)
check_requirements
install_git
install_for_os "$os_type"

cat << 'EOF'
-----------------------------------------------------------
Installation completed successfully!

Next steps:
   1. Restart your terminal or run: source ~/.bashrc
   2. Verify installation by running: giti --version
   3. Get started with: giti --help

Documentation: https://github.com/mohsen-karami/giti#command-reference

EOF