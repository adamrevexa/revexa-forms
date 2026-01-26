#!/bin/bash
#
# Revexa Forms - Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/adamrevexa/revexa-forms/main/install.sh | bash
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║         Revexa Forms Installer           ║"
    echo "║      Booking Confirmation Forms          ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

# Check for required commands
check_requirements() {
    print_info "Checking requirements..."

    if ! command -v git &> /dev/null; then
        print_error "git is required but not installed."
        exit 1
    fi
    print_success "git found"
}

# Clone the repository
clone_repo() {
    local install_dir="${1:-revexa-forms}"

    if [ -d "$install_dir" ]; then
        print_warning "Directory '$install_dir' already exists"
        read -p "Do you want to overwrite it? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$install_dir"
        else
            print_info "Installation cancelled"
            exit 0
        fi
    fi

    print_info "Cloning Revexa Forms..."
    git clone https://github.com/adamrevexa/revexa-forms.git "$install_dir" 2>/dev/null || {
        print_error "Failed to clone repository"
        exit 1
    }
    print_success "Repository cloned to $install_dir"
}

# Setup local development server
setup_dev_server() {
    local install_dir="${1:-revexa-forms}"

    echo ""
    print_info "Setting up development environment..."

    # Check for available local servers
    if command -v python3 &> /dev/null; then
        print_success "Python 3 available for local server"
        SERVER_CMD="python3 -m http.server 8080"
    elif command -v python &> /dev/null; then
        print_success "Python available for local server"
        SERVER_CMD="python -m SimpleHTTPServer 8080"
    elif command -v npx &> /dev/null; then
        print_success "npx available for local server"
        SERVER_CMD="npx serve -l 8080"
    elif command -v php &> /dev/null; then
        print_success "PHP available for local server"
        SERVER_CMD="php -S localhost:8080"
    else
        print_warning "No local server found (python, node, or php)"
        SERVER_CMD=""
    fi

    # Create a helper script to start the dev server
    if [ -n "$SERVER_CMD" ]; then
        cat > "$install_dir/start-server.sh" << EOF
#!/bin/bash
# Start local development server for Revexa Forms
echo "Starting local server at http://localhost:8080"
echo "Press Ctrl+C to stop"
echo ""
cd "\$(dirname "\$0")"
$SERVER_CMD
EOF
        chmod +x "$install_dir/start-server.sh"
        print_success "Created start-server.sh helper script"
    fi
}

# Print final instructions
print_instructions() {
    local install_dir="${1:-revexa-forms}"

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}       Installation Complete!               ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo ""
    echo "Project structure:"
    echo "  $install_dir/"
    echo "  ├── confirm-booking.html    # Hedin Bil Service form"
    echo "  ├── lasses/"
    echo "  │   └── index.html          # Lasses Sol och Energi form"
    echo "  └── lasses-m365/"
    echo "      └── index.html          # Lasses M365 form"
    echo ""
    echo "Quick start:"
    echo "  cd $install_dir"
    if [ -n "$SERVER_CMD" ]; then
        echo "  ./start-server.sh"
        echo ""
        echo "Then open http://localhost:8080 in your browser"
    else
        echo "  # Open any HTML file directly in your browser"
    fi
    echo ""
    echo "Testing forms with booking ID:"
    echo "  http://localhost:8080/confirm-booking.html?id=test123"
    echo "  http://localhost:8080/lasses/?id=test123"
    echo ""
    echo "Live site: https://form.revexa.io"
    echo ""
}

# Main installation flow
main() {
    print_banner

    local install_dir="${1:-revexa-forms}"

    check_requirements
    clone_repo "$install_dir"
    setup_dev_server "$install_dir"
    print_instructions "$install_dir"
}

# Run main with optional directory argument
main "$@"
