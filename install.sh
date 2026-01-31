#!/bin/bash

# ================================================================
# GenLayer Validator - Automated Installation Script
# ================================================================
# This script automates the complete setup of a GenLayer validator node
# 
# Usage:
#   ./install.sh [OPTIONS]
#
# Options:
#   --version VERSION          Specify node version (default: latest)
#   --method [binary|docker]   Installation method (default: docker)
#   --llm-provider PROVIDER    LLM provider (heurist|anthropic|openai|etc)
#   --interactive              Run in interactive mode
#   --skip-deps                Skip dependency installation
#   --help                     Show this help message
# ================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
VERSION="latest"
METHOD="docker"
LLM_PROVIDER=""
INTERACTIVE=false
SKIP_DEPS=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ================================================================
# Helper Functions
# ================================================================

print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║       GenLayer Validator - Automated Setup v1.0           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}\n"
}

# ================================================================
# Argument Parsing
# ================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version)
                VERSION="$2"
                shift 2
                ;;
            --method)
                METHOD="$2"
                shift 2
                ;;
            --llm-provider)
                LLM_PROVIDER="$2"
                shift 2
                ;;
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
GenLayer Validator Installation Script

Usage: ./install.sh [OPTIONS]

Options:
  --version VERSION          Specify node version (default: latest)
  --method [binary|docker]   Installation method (default: docker)
  --llm-provider PROVIDER    LLM provider (heurist|anthropic|openai|comput3|ionet)
  --interactive              Run in interactive mode
  --skip-deps                Skip dependency installation
  --help                     Show this help message

Examples:
  # Full automated Docker installation with latest version
  ./install.sh --method docker --llm-provider heurist

  # Interactive mode
  ./install.sh --interactive

  # Binary installation with specific version
  ./install.sh --method binary --version v0.4.5 --llm-provider anthropic

EOF
}

# ================================================================
# Interactive Mode
# ================================================================

run_interactive() {
    log_step "Starting Interactive Setup"
    
    # Installation method
    echo "Select installation method:"
    echo "1) Docker (Recommended)"
    echo "2) Binary"
    read -p "Enter choice [1-2]: " method_choice
    case $method_choice in
        1) METHOD="docker" ;;
        2) METHOD="binary" ;;
        *) log_error "Invalid choice"; exit 1 ;;
    esac
    
    # Version selection
    read -p "Enter node version (press Enter for latest): " version_input
    if [[ -n "$version_input" ]]; then
        VERSION="$version_input"
    fi
    
    # LLM Provider
    echo -e "\nSelect LLM Provider:"
    echo "1) Heurist (Recommended for beginners)"
    echo "2) Anthropic"
    echo "3) OpenAI"
    echo "4) Comput3"
    echo "5) io.net"
    echo "6) Other"
    read -p "Enter choice [1-6]: " llm_choice
    case $llm_choice in
        1) LLM_PROVIDER="heurist" ;;
        2) LLM_PROVIDER="anthropic" ;;
        3) LLM_PROVIDER="openai" ;;
        4) LLM_PROVIDER="comput3" ;;
        5) LLM_PROVIDER="ionet" ;;
        6) read -p "Enter provider name: " LLM_PROVIDER ;;
        *) log_error "Invalid choice"; exit 1 ;;
    esac
}

# ================================================================
# System Checks
# ================================================================

check_system_requirements() {
    log_step "Checking System Requirements"
    
    # Check OS
    if [[ ! "$OSTYPE" == "linux-gnu"* ]]; then
        log_error "This script only supports Linux systems"
        exit 1
    fi
    
    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "x86_64" ]]; then
        log_error "Only AMD64 (x86_64) architecture is supported. Found: $ARCH"
        exit 1
    fi
    
    # Check memory
    TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $TOTAL_MEM -lt 14 ]]; then
        log_warn "System has ${TOTAL_MEM}GB RAM. Minimum required: 16GB"
        read -p "Continue anyway? [y/N]: " continue_mem
        if [[ ! "$continue_mem" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_info "Memory check passed: ${TOTAL_MEM}GB"
    fi
    
    # Check disk space
    AVAILABLE_DISK=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAILABLE_DISK -lt 128 ]]; then
        log_warn "Available disk space: ${AVAILABLE_DISK}GB. Recommended: 128GB+"
    else
        log_info "Disk space check passed: ${AVAILABLE_DISK}GB available"
    fi
    
    log_info "System requirements check completed"
}

# ================================================================
# Dependency Installation
# ================================================================

install_dependencies() {
    if [[ "$SKIP_DEPS" == true ]]; then
        log_info "Skipping dependency installation"
        return
    fi
    
    log_step "Installing Dependencies"
    
    # Detect package manager
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    else
        log_error "Unsupported package manager. Please install dependencies manually."
        exit 1
    fi
    
    log_info "Updating package lists..."
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt-get update
    else
        sudo yum check-update || true
    fi
    
    # Install common dependencies
    log_info "Installing common dependencies..."
    COMMON_DEPS="curl wget tar git"
    
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        sudo apt-get install -y $COMMON_DEPS
    else
        sudo yum install -y $COMMON_DEPS
    fi
    
    # Install Python 3
    if ! command -v python3 &> /dev/null; then
        log_info "Installing Python 3..."
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt-get install -y python3 python3-pip python3-venv
        else
            sudo yum install -y python3 python3-pip
        fi
    else
        log_info "Python 3 already installed: $(python3 --version)"
    fi
    
    # Install Node.js if not present
    if ! command -v node &> /dev/null; then
        log_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            sudo apt-get install -y nodejs
        else
            sudo yum install -y nodejs
        fi
    else
        log_info "Node.js already installed: $(node --version)"
    fi
    
    # Install GenLayer CLI
    if ! command -v genlayer &> /dev/null; then
        log_info "Installing GenLayer CLI..."
        sudo npm install -g genlayer
    else
        log_info "GenLayer CLI already installed"
    fi
    
    # Install Docker if method is docker
    if [[ "$METHOD" == "docker" ]]; then
        if ! command -v docker &> /dev/null; then
            log_info "Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            sudo usermod -aG docker $USER
            rm get-docker.sh
            log_warn "Please log out and log back in for Docker group changes to take effect"
        else
            log_info "Docker already installed: $(docker --version)"
        fi
        
        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
            log_info "Installing Docker Compose..."
            if [[ "$PKG_MANAGER" == "apt" ]]; then
                sudo apt-get install -y docker-compose-plugin
            else
                sudo yum install -y docker-compose-plugin
            fi
        else
            log_info "Docker Compose already installed"
        fi
    fi
    
    log_info "Dependencies installation completed"
}

# ================================================================
# Node Installation
# ================================================================

install_node() {
    log_step "Installing GenLayer Node"
    
    if [[ "$METHOD" == "docker" ]]; then
        install_docker_node
    else
        install_binary_node
    fi
}

install_binary_node() {
    log_info "Installing GenLayer Node (Binary Method)"
    
    # Get latest version if not specified
    if [[ "$VERSION" == "latest" ]]; then
        log_info "Fetching latest version..."
        VERSION=$(curl -s "https://storage.googleapis.com/storage/v1/b/gh-af/o?prefix=genlayer-node/bin/amd64" | \
                  grep -o '"name": *"[^"]*"' | \
                  sed -n 's/.*\/\(v[^/]*\)\/.*/\1/p' | \
                  sort -ru | \
                  grep -v "rc" | \
                  head -n 1)
        log_info "Latest version: $VERSION"
    fi
    
    # Create installation directory
    INSTALL_DIR="$SCRIPT_DIR/node-$VERSION"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Download node package
    log_info "Downloading GenLayer Node $VERSION..."
    PACKAGE_URL="https://storage.googleapis.com/gh-af/genlayer-node/bin/amd64/${VERSION}/genlayer-node-linux-amd64-${VERSION}.tar.gz"
    wget -q --show-progress "$PACKAGE_URL" -O genlayer-node.tar.gz
    
    # Extract package
    log_info "Extracting package..."
    tar -xzf genlayer-node.tar.gz
    rm genlayer-node.tar.gz
    
    # Run GenVM setup
    log_info "Running GenVM setup..."
    python3 ./third_party/genvm/bin/setup.py
    
    log_info "Binary installation completed at: $INSTALL_DIR"
}

install_docker_node() {
    log_info "Setting up GenLayer Node (Docker Method)"
    
    # Get latest version if not specified
    if [[ "$VERSION" == "latest" ]]; then
        log_info "Using latest Docker image"
        DOCKER_VERSION="latest"
    else
        DOCKER_VERSION="$VERSION"
    fi
    
    # Create installation directory
    INSTALL_DIR="$SCRIPT_DIR/node-docker"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Copy docker-compose and config templates
    log_info "Creating Docker configuration..."
    
    # Copy from scripts/templates
    cp "$SCRIPT_DIR/scripts/templates/docker-compose.yaml" .
    cp "$SCRIPT_DIR/scripts/templates/genvm-module-web-docker.yaml" .
    cp "$SCRIPT_DIR/scripts/templates/.env.example" .env
    
    # Update version in .env
    sed -i "s/NODE_VERSION=.*/NODE_VERSION=$DOCKER_VERSION/" .env
    
    log_info "Docker setup completed at: $INSTALL_DIR"
}

# ================================================================
# Configuration
# ================================================================

configure_node() {
    log_step "Configuring Node"
    
    if [[ "$METHOD" == "docker" ]]; then
        configure_docker_node
    else
        configure_binary_node
    fi
}

configure_docker_node() {
    log_info "Configuring Docker Node"
    
    cd "$INSTALL_DIR"
    
    # Create configs directory
    mkdir -p configs/node
    
    # Copy config template
    cp "$SCRIPT_DIR/scripts/templates/config.yaml" configs/node/config.yaml
    
    # Get RPC endpoints
    echo -e "\n${YELLOW}GenLayer Chain RPC Configuration${NC}"
    echo "You need to provide RPC endpoints for the GenLayer Chain ZKSync node"
    echo "Example: https://your-zksync-node.com:3050"
    
    read -p "Enter GenLayer Chain HTTP RPC URL: " rpc_url
    read -p "Enter GenLayer Chain WebSocket RPC URL: " ws_url
    
    # Update config.yaml
    sed -i "s|genlayerchainrpcurl:.*|genlayerchainrpcurl: \"$rpc_url\"|" configs/node/config.yaml
    sed -i "s|genlayerchainwebsocketurl:.*|genlayerchainwebsocketurl: \"$ws_url\"|" configs/node/config.yaml
    
    # Configure LLM provider in .env
    if [[ -n "$LLM_PROVIDER" ]]; then
        configure_llm_provider
    fi
    
    log_info "Docker node configuration completed"
}

configure_binary_node() {
    log_info "Configuring Binary Node"
    
    cd "$INSTALL_DIR"
    
    # Create configs directory
    mkdir -p configs/node
    
    # Copy config template
    cp "$SCRIPT_DIR/scripts/templates/config.yaml" configs/node/config.yaml
    
    # Get RPC endpoints
    echo -e "\n${YELLOW}GenLayer Chain RPC Configuration${NC}"
    read -p "Enter GenLayer Chain HTTP RPC URL: " rpc_url
    read -p "Enter GenLayer Chain WebSocket RPC URL: " ws_url
    
    # Update config.yaml
    sed -i "s|genlayerchainrpcurl:.*|genlayerchainrpcurl: \"$rpc_url\"|" configs/node/config.yaml
    sed -i "s|genlayerchainwebsocketurl:.*|genlayerchainwebsocketurl: \"$ws_url\"|" configs/node/config.yaml
    
    # Configure LLM provider
    if [[ -n "$LLM_PROVIDER" ]]; then
        configure_llm_provider
    fi
    
    log_info "Binary node configuration completed"
}

configure_llm_provider() {
    log_info "Configuring LLM Provider: $LLM_PROVIDER"
    
    case $LLM_PROVIDER in
        heurist)
            read -p "Enter Heurist API Key: " api_key
            echo "HEURISTKEY=$api_key" >> .env
            ;;
        anthropic)
            read -p "Enter Anthropic API Key: " api_key
            echo "ANTHROPICKEY=$api_key" >> .env
            ;;
        openai)
            read -p "Enter OpenAI API Key: " api_key
            echo "OPENAIKEY=$api_key" >> .env
            ;;
        comput3)
            read -p "Enter Comput3 API Key: " api_key
            echo "COMPUT3KEY=$api_key" >> .env
            ;;
        ionet)
            read -p "Enter io.net API Key: " api_key
            echo "IOINTELLIGENCE_API_KEY=$api_key" >> .env
            ;;
        *)
            log_warn "Custom LLM provider. Please configure manually in .env"
            ;;
    esac
}

# ================================================================
# Wallet Setup
# ================================================================

setup_wallet() {
    log_step "Validator Wallet Setup"
    
    echo -e "\n${YELLOW}Wallet Setup Options:${NC}"
    echo "1) Create new validator wallet (requires 42,000 GEN)"
    echo "2) I already have a validator wallet"
    echo "3) Skip wallet setup for now"
    
    read -p "Enter choice [1-3]: " wallet_choice
    
    case $wallet_choice in
        1)
            create_validator_wallet
            ;;
        2)
            import_existing_wallet
            ;;
        3)
            log_info "Skipping wallet setup. You can run 'genlayer staking wizard' later."
            ;;
        *)
            log_error "Invalid choice"
            exit 1
            ;;
    esac
}

create_validator_wallet() {
    log_info "Starting validator wallet creation wizard..."
    echo -e "\n${YELLOW}Note: You need at least 42,000 GEN tokens${NC}\n"
    
    genlayer staking wizard
    
    echo -e "\n${GREEN}Please save the following information from the wizard output:${NC}"
    echo "1. Validator Wallet Address"
    echo "2. Operator Address"
    echo "3. Operator Keystore file location"
    
    read -p "Press Enter when you have saved this information..."
    
    read -p "Enter Validator Wallet Address: " validator_address
    read -p "Enter Operator Address: " operator_address
    
    # Update config with validator addresses
    update_validator_config "$validator_address" "$operator_address"
}

import_existing_wallet() {
    log_info "Importing existing validator wallet..."
    
    read -p "Enter Validator Wallet Address: " validator_address
    read -p "Enter Operator Address: " operator_address
    read -p "Enter path to operator keystore file: " keystore_path
    
    # Import operator key
    if [[ "$METHOD" == "docker" ]]; then
        log_warn "For Docker installations, you'll need to import the key after starting the container"
    else
        import_operator_key "$keystore_path"
    fi
    
    # Update config
    update_validator_config "$validator_address" "$operator_address"
}

import_operator_key() {
    local keystore_path=$1
    
    read -s -p "Enter node password: " node_password
    echo
    read -s -p "Enter keystore passphrase: " keystore_passphrase
    echo
    
    cd "$INSTALL_DIR"
    ./bin/genlayernode account import \
        --password "$node_password" \
        --passphrase "$keystore_passphrase" \
        --path "$keystore_path" \
        -c $(pwd)/configs/node/config.yaml \
        --setup
}

update_validator_config() {
    local validator_address=$1
    local operator_address=$2
    
    if [[ "$METHOD" == "docker" ]]; then
        # Update .env for docker
        sed -i "s|GENLAYERNODE_NODE_VALIDATORWALLETADDRESS=.*|GENLAYERNODE_NODE_VALIDATORWALLETADDRESS=$validator_address|" .env
        sed -i "s|GENLAYERNODE_NODE_OPERATORADDRESS=.*|GENLAYERNODE_NODE_OPERATORADDRESS=$operator_address|" .env
    else
        # Update config.yaml for binary
        sed -i "s|validatorWalletAddress:.*|validatorWalletAddress: \"$validator_address\"|" configs/node/config.yaml
        sed -i "s|operatorAddress:.*|operatorAddress: \"$operator_address\"|" configs/node/config.yaml
    fi
    
    log_info "Validator configuration updated"
}

# ================================================================
# Monitoring Setup (Optional)
# ================================================================

setup_monitoring() {
    log_step "Monitoring Setup (Optional)"
    
    read -p "Do you want to set up centralized monitoring? [y/N]: " setup_mon
    
    if [[ "$setup_mon" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}You need credentials from GenLayer Foundation${NC}"
        echo "Ask in #testnet-asimov Discord channel for:"
        echo "  - CENTRAL_MONITORING_URL"
        echo "  - CENTRAL_LOKI_URL"
        echo "  - Monitoring credentials"
        
        read -p "Do you have these credentials? [y/N]: " has_creds
        
        if [[ "$has_creds" =~ ^[Yy]$ ]]; then
            configure_monitoring
        else
            log_info "You can configure monitoring later by editing .env file"
        fi
    else
        log_info "Skipping monitoring setup"
    fi
}

configure_monitoring() {
    read -p "Enter CENTRAL_MONITORING_URL: " mon_url
    read -p "Enter CENTRAL_LOKI_URL: " loki_url
    read -p "Enter Metrics Username: " mon_user
    read -s -p "Enter Metrics Password: " mon_pass
    echo
    read -p "Enter Logs Username: " loki_user
    read -s -p "Enter Logs Password: " loki_pass
    echo
    read -p "Enter Node ID: " node_id
    read -p "Enter Validator Name: " val_name
    
    # Update .env
    cat >> .env << EOF

# Monitoring Configuration
CENTRAL_MONITORING_URL=$mon_url
CENTRAL_LOKI_URL=$loki_url
CENTRAL_MONITORING_USERNAME=$mon_user
CENTRAL_MONITORING_PASSWORD=$mon_pass
CENTRAL_LOKI_USERNAME=$loki_user
CENTRAL_LOKI_PASSWORD=$loki_pass
NODE_ID=$node_id
VALIDATOR_NAME=$val_name
EOF
    
    log_info "Monitoring configuration added to .env"
}

# ================================================================
# Final Steps
# ================================================================

show_completion_message() {
    log_step "Installation Complete!"
    
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║          GenLayer Validator Setup Complete!               ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${YELLOW}Installation Summary:${NC}"
    echo "  Method: $METHOD"
    echo "  Version: $VERSION"
    echo "  Location: $INSTALL_DIR"
    
    if [[ "$METHOD" == "docker" ]]; then
        echo -e "\n${YELLOW}Next Steps:${NC}"
        echo "  1. Review configuration: $INSTALL_DIR/.env"
        echo "  2. Start the node:"
        echo "     cd $INSTALL_DIR"
        echo "     docker compose --profile node up -d"
        echo ""
        echo "  3. Check logs:"
        echo "     docker logs -f genlayer-node"
        echo ""
        echo "  4. (Optional) Start monitoring:"
        echo "     docker compose --profile monitoring up -d"
    else
        echo -e "\n${YELLOW}Next Steps:${NC}"
        echo "  1. Review configuration: $INSTALL_DIR/configs/node/config.yaml"
        echo "  2. Start WebDriver:"
        echo "     cd $INSTALL_DIR"
        echo "     docker compose up -d"
        echo ""
        echo "  3. Start the node:"
        echo "     ./bin/genlayernode run -c \$(pwd)/configs/node/config.yaml --password 'your-password'"
    fi
    
    echo -e "\n${YELLOW}Useful Commands:${NC}"
    echo "  Check validator status:"
    echo "    genlayer staking validator-info --validator YOUR_VALIDATOR_ADDRESS"
    echo ""
    echo "  Node diagnostics:"
    if [[ "$METHOD" == "docker" ]]; then
        echo "    docker exec genlayer-node ./bin/genlayernode doctor"
    else
        echo "    ./bin/genlayernode doctor"
    fi
    
    echo -e "\n${YELLOW}Documentation:${NC}"
    echo "  Setup Guide: https://docs.genlayer.com/validators/setup"
    echo "  Troubleshooting: https://docs.genlayer.com/validators/troubleshooting"
    
    echo -e "\n${GREEN}Happy validating! 🚀${NC}\n"
}

# ================================================================
# Main Execution
# ================================================================

main() {
    print_banner
    
    parse_arguments "$@"
    
    if [[ "$INTERACTIVE" == true ]]; then
        run_interactive
    fi
    
    check_system_requirements
    install_dependencies
    install_node
    configure_node
    setup_wallet
    
    if [[ "$METHOD" == "docker" ]]; then
        setup_monitoring
    fi
    
    show_completion_message
}

# Run main function
main "$@"
