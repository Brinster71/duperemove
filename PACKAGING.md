# Building Duperemove-Progressbar Packages

This directory contains packaging files and scripts for building both RPM and DEB packages of duperemove-progressbar with progress indicator support.

## Quick Start

### Building RPM (Fedora/RHEL/CentOS)
```bash
./build-rpm.sh
```
Output will be in `~/rpmbuild/RPMS/x86_64/duperemove-progressbar-*.rpm`

### Building DEB (Debian/Ubuntu)
```bash
./build-deb.sh
```
Output will be in `../duperemove-progressbar_*.deb`

## Manual Building

### RPM Package

1. **Install build dependencies:**
   ```bash
   sudo dnf install -y rpm-build rpmdevtools gcc make glib2-devel \
       sqlite-devel libuuid-devel xxhash-devel
   ```

2. **Setup build environment:**
   ```bash
   rpmdev-setuptree
   ```

3. **Create source tarball:**
   ```bash
   tar --exclude='.git' --transform 's,^,duperemove-progressbar-0.13.1/,' \
       -czf ~/rpmbuild/SOURCES/duperemove-progressbar-0.13.1.tar.gz .
   ```

4. **Build RPM:**
   ```bash
   cp duperemove.spec ~/rpmbuild/SPECS/duperemove-progressbar.spec
   cd ~/rpmbuild/SPECS
   rpmbuild -ba duperemove-progressbar.spec
   ```

### DEB Package

1. **Install build dependencies:**
   ```bash
   sudo apt-get install -y debhelper devscripts build-essential \
       libglib2.0-dev libsqlite3-dev uuid-dev libxxhash-dev pkg-config
   ```

2. **Build package:**
   ```bash
   dpkg-buildpackage -us -uc -b
   ```

## Files Included

- `duperemove.spec` - RPM spec file
- `debian/` - Debian packaging directory
  - `control` - Package metadata and dependencies
  - `rules` - Build rules
  - `changelog` - Version history
  - `compat` - Debhelper compatibility level
  - `copyright` - License information
- `build-rpm.sh` - Automated RPM build script
- `build-deb.sh` - Automated DEB build script

## Version Information

Current version: **0.13.1-1**

Changes in this version:
- Added progress indicators for hash loading phase
- Shows progress when loading duplicate block and extent hashes
- Progress bars display current count, total count, and percentage
- Particularly useful for large hashfiles (18GB+)
- Helps users determine if process is running or has crashed

## Installing the Package

### RPM:
```bash
sudo dnf install ~/rpmbuild/RPMS/x86_64/duperemove-0.13.1-1.*.rpm
```

### DEB:
```bash
sudo dpkg -i ../duperemove_0.13.1-1_amd64.deb
sudo apt-get install -f  # Install any missing dependencies
```

## Testing

After installation, verify the progress indicators work:
```bash
duperemove --version
duperemove -h hashfile.db -d /path/to/files
```

You should see progress bars during the hash loading phase:
```
Loading duplicate block hashes: [##########%                              ] 12500/50000 (25.0%)
```
