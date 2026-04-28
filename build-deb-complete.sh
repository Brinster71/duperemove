#!/bin/bash
# Complete script to build duperemove-progressbar DEB package on Debian/Ubuntu
# This script installs all dependencies and builds the package

set -e

echo "=== Building duperemove-progressbar DEB package on Debian/Ubuntu ==="
echo ""

# Check if running on Debian/Ubuntu
if ! command -v apt-get &> /dev/null; then
    echo "Error: This script requires apt-get (Debian/Ubuntu)"
    exit 1
fi

echo "Step 1: Updating package lists..."
sudo apt-get update

echo ""
echo "Step 2: Installing build dependencies..."
sudo apt-get install -y \
    build-essential \
    debhelper \
    devscripts \
    fakeroot \
    git \
    libglib2.0-dev \
    libsqlite3-dev \
    uuid-dev \
    pkg-config \
    pandoc \
    libxxhash-dev || {
        echo "Warning: libxxhash-dev not available, trying alternative..."
        sudo apt-get install -y \
            build-essential \
            debhelper \
            devscripts \
            fakeroot \
            git \
            libglib2.0-dev \
            libsqlite3-dev \
            uuid-dev \
            pkg-config \
            pandoc
        echo "Note: xxhash may need to be built from source"
    }

echo ""
echo "Step 3: Determining source directory..."

# Check if we're already in the duperemove directory
if [ -f "duperemove.spec" ] && [ -d "debian" ]; then
    REPO_DIR="$(pwd)"
    echo "Using current directory: $REPO_DIR"
else
    # Clone the repository
    echo "Cloning repository from GitHub..."
    cd /tmp
    rm -rf duperemove
    git clone https://github.com/Brinster71/duperemove.git
    cd duperemove
    REPO_DIR="$(pwd)"
    echo "Repository cloned to: $REPO_DIR"
fi

cd "$REPO_DIR"

echo ""
echo "Step 4: Cleaning previous builds..."
make clean 2>/dev/null || true
rm -rf debian/.debhelper debian/duperemove-progressbar debian/files debian/*.log \
    debian/*.substvars debian/debhelper-build-stamp 2>/dev/null || true

echo ""
echo "Step 5: Building DEB package..."
dpkg-buildpackage -us -uc -b

echo ""
echo "=== Build Complete! ==="
echo ""
echo "DEB packages created in parent directory:"
cd ..
ls -lh duperemove-progressbar*.deb 2>/dev/null || {
    echo "No .deb files found, checking for errors..."
    exit 1
}

echo ""
echo "To install the package:"
echo "  sudo dpkg -i duperemove-progressbar_0.13.1-1_amd64.deb"
echo ""
echo "If there are dependency issues after install, run:"
echo "  sudo apt-get install -f"
