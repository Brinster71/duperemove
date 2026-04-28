#!/bin/bash
# Build script for creating DEB package

set -e

echo "=== Building DEB Package for Duperemove ==="

# Install build dependencies
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y debhelper devscripts build-essential \
    libglib2.0-dev libsqlite3-dev uuid-dev libxxhash-dev pkg-config \
    dh-make fakeroot

# Clean previous builds
echo "Cleaning previous builds..."
cd "$(dirname "$0")"
make clean || true
rm -rf debian/.debhelper debian/duperemove-progressbar debian/files debian/*.log \
    debian/*.substvars debian/debhelper-build-stamp

# Build package
echo "Building DEB package..."
dpkg-buildpackage -us -uc -b

echo ""
echo "=== Build Complete! ==="
echo "DEB package is in parent directory:"
cd ..
ls -lh duperemove-progressbar*.deb 2>/dev/null || echo "Note: Check parent directory for .deb file"
