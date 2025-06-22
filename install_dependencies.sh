#!/bin/bash

# Install Dependencies for Long Reads QC Pipeline
# Author: Bright Boamah
# Date: $(date +%Y-%m-%d)
# Description: Install fastp and other required dependencies

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to detect the system and package manager
detect_system() {
    if command -v apt-get &> /dev/null; then
        PACKAGE_MANAGER="apt"
        DISTRO="debian"
    elif command -v yum &> /dev/null; then
        PACKAGE_MANAGER="yum"
        DISTRO="redhat"
    elif command -v dnf &> /dev/null; then
        PACKAGE_MANAGER="dnf"
        DISTRO="redhat"
    elif command -v pacman &> /dev/null; then
        PACKAGE_MANAGER="pacman"
        DISTRO="arch"
    elif command -v brew &> /dev/null; then
        PACKAGE_MANAGER="brew"
        DISTRO="macos"
    else
        PACKAGE_MANAGER="unknown"
        DISTRO="unknown"
    fi
    
    log_info "Detected system: $DISTRO with package manager: $PACKAGE_MANAGER"
}

# Function to install basic dependencies
install_basic_deps() {
    log_info "Installing basic dependencies..."
    
    case $PACKAGE_MANAGER in
        apt)
            sudo apt-get update
            sudo apt-get install -y wget curl build-essential zlib1g-dev
            ;;
        yum)
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y wget curl zlib-devel
            ;;
        dnf)
            sudo dnf update -y
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y wget curl zlib-devel
            ;;
        pacman)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm wget curl base-devel zlib
            ;;
        brew)
            brew update
            brew install wget curl
            ;;
        *)
            log_warning "Unknown package manager. Please install wget, curl, and build tools manually."
            ;;
    esac
    
    log_success "Basic dependencies installed"
}

# Function to install fastp
install_fastp() {
    log_info "Installing fastp..."
    
    # Check if conda is available first
    if command -v conda &> /dev/null; then
        log_info "Installing fastp using conda..."
        conda install -c bioconda fastp -y
        log_success "fastp installed via conda"
        return 0
    fi
    
    # Check if mamba is available
    if command -v mamba &> /dev/null; then
        log_info "Installing fastp using mamba..."
        mamba install -c bioconda fastp -y
        log_success "fastp installed via mamba"
        return 0
    fi
    
    # Install from binary
    log_info "Installing fastp from binary..."
    FASTP_VERSION="0.23.2"
    FASTP_URL="https://github.com/OpenGene/fastp/releases/download/v${FASTP_VERSION}/fastp"
    
    # Create local bin directory if it doesn't exist
    mkdir -p "$HOME/bin"
    
    # Download and install fastp
    if wget -O "$HOME/bin/fastp" "$FASTP_URL"; then
        chmod +x "$HOME/bin/fastp"
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
            export PATH="$HOME/bin:$PATH"
            log_info "Added $HOME/bin to PATH in .bashrc"
        fi
        
        log_success "fastp installed to $HOME/bin/fastp"
    else
        log_error "Failed to download fastp binary"
        return 1
    fi
}

# Function to verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    if command -v fastp &> /dev/null; then
        FASTP_VERSION=$(fastp --version 2>&1 | head -1)
        log_success "fastp is installed: $FASTP_VERSION"
    else
        log_error "fastp installation failed"
        return 1
    fi
    
    log_success "All dependencies verified successfully"
}

# Function to install conda/mamba (optional)
install_conda() {
    if command -v conda &> /dev/null; then
        log_info "Conda is already installed"
        return 0
    fi
    
    log_info "Would you like to install Miniconda? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        log_info "Installing Miniconda..."
        
        # Detect architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        elif [[ "$ARCH" == "aarch64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh"
        else
            log_error "Unsupported architecture: $ARCH"
            return 1
        fi
        
        # Download and install Miniconda
        TEMP_FILE=$(mktemp)
        if wget -O "$TEMP_FILE" "$MINICONDA_URL"; then
            bash "$TEMP_FILE" -b -p "$HOME/miniconda3"
            rm "$TEMP_FILE"
            
            # Initialize conda
            "$HOME/miniconda3/bin/conda" init bash
            source "$HOME/.bashrc"
            
            log_success "Miniconda installed successfully"
            log_info "Please restart your terminal or run 'source ~/.bashrc'"
        else
            log_error "Failed to download Miniconda"
            return 1
        fi
    fi
}

# Main function
main() {
    log_info "Starting dependency installation for Long Reads QC Pipeline"
    log_info "Author: Bright Boamah"
    
    detect_system
    
    # Ask if user wants to install conda first
    install_conda
    
    # Install basic dependencies
    install_basic_deps
    
    # Install fastp
    install_fastp
    
    # Verify installation
    verify_installation
    
    log_success "Installation completed successfully!"
    log_info "You can now run the long_reads_qc.sh script"
    
    # Display usage example
    echo ""
    echo "Usage example:"
    echo "  ./long_reads_qc.sh -i /path/to/input/fastq/files -o /path/to/output/directory"
}

# Check if script is being run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
