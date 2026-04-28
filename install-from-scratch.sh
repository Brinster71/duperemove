#!/bin/bash
# Complete from-scratch script to build and install duperemove-progressbar
# Works on Debian/Ubuntu and Fedora/RHEL/CentOS
# Run with: bash install-duperemove-progressbar.sh

set -e

echo "=========================================="
echo "duperemove-progressbar Installation"
echo "=========================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS. /etc/os-release not found."
    exit 1
fi

echo "Detected OS: $OS $VER"
echo ""

# Set variables
REPO_URL="https://github.com/Brinster71/duperemove.git"
BUILD_DIR="/tmp/duperemove-build-$$"
INSTALL_PREFIX="/usr/local"

echo "Configuration:"
echo "  Repository: $REPO_URL"
echo "  Build directory: $BUILD_DIR"
echo "  Install prefix: $INSTALL_PREFIX"
echo ""

# Function to install dependencies on Debian/Ubuntu
install_deps_debian() {
    echo "Installing dependencies for Debian/Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        git \
        libglib2.0-dev \
        libsqlite3-dev \
        uuid-dev \
        pkg-config \
        pandoc \
        debhelper \
        devscripts \
        fakeroot
    
    # Try to install xxhash, fallback if not available
    if ! sudo apt-get install -y libxxhash-dev; then
        echo "Warning: libxxhash-dev not available in repositories"
        echo "Package will be built without xxhash support"
    fi
}

# Function to install dependencies on Fedora/RHEL/CentOS
install_deps_fedora() {
    echo "Installing dependencies for Fedora/RHEL/CentOS..."
    sudo dnf install -y \
        gcc \
        make \
        git \
        glib2-devel \
        sqlite-devel \
        libuuid-devel \
        xxhash-devel \
        pkg-config \
        pandoc \
        rpm-build \
        rpmdevtools
}

# Function to build and install from source (manual)
build_and_install_manual() {
    echo ""
    echo "=========================================="
    echo "Building from source..."
    echo "=========================================="
    
    # Clone repository
    echo "Cloning repository..."
    git clone "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    echo ""
    echo "Building binaries..."
    make clean || true
    make
    
    echo ""
    echo "Installing to $INSTALL_PREFIX..."
    sudo make install PREFIX="$INSTALL_PREFIX" SBINDIR="$INSTALL_PREFIX/bin" MANDIR="$INSTALL_PREFIX/share/man"
    
    echo ""
    echo "Installation complete!"
    echo "Binary installed to: $INSTALL_PREFIX/bin/duperemove"
}

# Function to build DEB package
build_deb() {
    echo ""
    echo "=========================================="
    echo "Building DEB package..."
    echo "=========================================="
    
    # Clone repository
    echo "Cloning repository..."
    git clone "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Build package
    echo "Building DEB package..."
    dpkg-buildpackage -us -uc -b
    
    echo ""
    echo "Installing DEB package..."
    sudo dpkg -i ../duperemove-progressbar_*.deb || {
        echo "Fixing dependencies..."
        sudo apt-get install -f -y
    }
    
    echo ""
    echo "DEB package installed successfully!"
}

# Function to build RPM package
build_rpm() {
    echo ""
    echo "=========================================="
    echo "Building RPM package..."
    echo "=========================================="
    
    # Setup RPM build environment
    rpmdev-setuptree
    
    # Clone repository
    echo "Cloning repository..."
    git clone "$REPO_URL" "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Build package using the build script
    ./build-rpm.sh
    
    echo ""
    echo "Installing RPM package..."
    sudo dnf install -y ~/rpmbuild/RPMS/*/duperemove-progressbar-*.rpm
    
    echo ""
    echo "RPM package installed successfully!"
}

# Main installation logic
case "$OS" in
    ubuntu|debian)
        echo "Installing on Debian/Ubuntu system..."
        install_deps_debian
        
        echo ""
        read -p "Build as DEB package? (recommended) [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            build_and_install_manual
        else
            build_deb
        fi
        ;;
        
    fedora|rhel|centos|rocky|almalinux)
        echo "Installing on Fedora/RHEL/CentOS system..."
        install_deps_fedora
        
        echo ""
        read -p "Build as RPM package? (recommended) [Y/n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            build_and_install_manual
        else
            build_rpm
        fi
        ;;
        
    *)
        echo "Unsupported OS: $OS"
        echo "Attempting manual build and install..."
        
        echo ""
        echo "Please install these dependencies manually:"
        echo "  - gcc/build tools"
        echo "  - glib2 development files"
        echo "  - sqlite3 development files"
        echo "  - uuid development files"
        echo "  - xxhash development files"
        echo "  - pkg-config"
        echo ""
        read -p "Press Enter when dependencies are installed..."
        
        build_and_install_manual
        ;;
esac

# Cleanup
echo ""
echo "Cleaning up build directory..."
rm -rf "$BUILD_DIR"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Verify installation:"
echo "  duperemove --version"
echo ""
echo "Usage example:"
echo "  duperemove -hdr /path/to/files"
echo ""
echo "Progress indicators will show during hash loading:"
echo "  Loading duplicate block hashes: [###...] 1234/5000 (24.7%)"
echo ""
