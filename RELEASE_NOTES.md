# Duperemove with Progress Indicators v0.13.1

This release adds progress indicators for the hash loading phase, making it easier to monitor long-running deduplication operations on large hashfiles.

## Features

- **Progress bars** during hash loading phase showing count/total/percentage
- Visual feedback for operations that can take hours on large datasets (18GB+ hashfiles)
- No more wondering if the process has crashed during the duplicate detection phase

## Installation

### Fedora/RHEL/CentOS

```bash
sudo dnf install ./duperemove-progressbar-0.13.1-1.fc43.x86_64.rpm
```

### Debian/Ubuntu

DEB packages can be built from source using the included `build-deb.sh` script on Debian/Ubuntu systems.

## Example Output

```
Loading duplicate block hashes: [##########%...] 12500/50000 (25.0%)
```

## Package Files

- `duperemove-progressbar-0.13.1-1.fc43.x86_64.rpm` - Main binary package for Fedora 43
- `duperemove-progressbar-0.13.1-1.fc43.src.rpm` - Source RPM for rebuilding

## Notes

Based on duperemove v0.13 with custom progress indicator patches.

See the [README](https://github.com/Brinster71/duperemove/blob/master/README.md) for more information about the progress indicator feature.
