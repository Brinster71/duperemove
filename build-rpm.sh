#!/bin/bash
# Build script for creating RPM package

set -e

echo "=== Building RPM Package for Duperemove ==="

# Install build dependencies
echo "Installing build dependencies..."
sudo dnf install -y rpm-build rpmdevtools gcc make glib2-devel sqlite-devel \
    libuuid-devel xxhash-devel

# Setup RPM build environment
echo "Setting up RPM build environment..."
rpmdev-setuptree

# Get version
VERSION="0.13.1"
TARBALL="duperemove-${VERSION}.tar.gz"

# Create source tarball
echo "Creating source tarball..."
cd "$(dirname "$0")"
REPODIR=$(pwd)

# Clean build artifacts first
make clean 2>/dev/null || true

cd ..
tar --exclude='.git' --exclude='*.o' --exclude='*.d' \
    --exclude='duperemove/duperemove' --exclude='duperemove/hashstats' \
    --exclude='duperemove/btrfs-extent-same' --exclude='duperemove/csum-test' \
    --exclude='duperemove/rpmbuild' \
    --transform "s,^duperemove,duperemove-${VERSION}," \
    -czf "/tmp/${TARBALL}" duperemove/

# Copy files to RPM build tree
echo "Copying files to RPM build tree..."
cp "/tmp/${TARBALL}" ~/rpmbuild/SOURCES/
cp "${REPODIR}/duperemove.spec" ~/rpmbuild/SPECS/

# Build RPM
echo "Building RPM package..."
cd ~/rpmbuild/SPECS
rpmbuild -ba duperemove.spec

echo ""
echo "=== Build Complete! ==="
echo "RPM packages are in:"
echo "  SRPMS: ~/rpmbuild/SRPMS/"
ls -lh ~/rpmbuild/SRPMS/duperemove*.rpm 2>/dev/null || true
echo "  RPMS:  ~/rpmbuild/RPMS/$(uname -m)/"
ls -lh ~/rpmbuild/RPMS/$(uname -m)/duperemove*.rpm 2>/dev/null || true
