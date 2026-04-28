#!/bin/bash
# Script to create a GitHub release for duperemove-progressbar
# Usage: GH_TOKEN=your_token ./create-github-release.sh

set -e

REPO="Brinster71/duperemove"
VERSION="v0.13.1"
TAG="$VERSION"
RELEASE_NAME="duperemove-progressbar $VERSION"

# Files to upload
RPM_FILE=~/rpmbuild/RPMS/x86_64/duperemove-progressbar-0.13.1-1.fc43.x86_64.rpm
SRPM_FILE=~/rpmbuild/SRPMS/duperemove-progressbar-0.13.1-1.fc43.src.rpm

# Check if GH_TOKEN is set
if [ -z "$GH_TOKEN" ]; then
    echo "Error: GH_TOKEN environment variable not set"
    echo "Please set it with: export GH_TOKEN=your_github_token"
    echo ""
    echo "Or use GitHub CLI instead:"
    echo "  gh auth login"
    echo "  gh release create $TAG \\"
    echo "    $RPM_FILE \\"
    echo "    $SRPM_FILE \\"
    echo "    --title \"$RELEASE_NAME\" \\"
    echo "    --notes-file RELEASE_NOTES.md"
    exit 1
fi

# Check if files exist
if [ ! -f "$RPM_FILE" ]; then
    echo "Error: RPM file not found: $RPM_FILE"
    exit 1
fi

if [ ! -f "$SRPM_FILE" ]; then
    echo "Error: SRPM file not found: $SRPM_FILE"
    exit 1
fi

# Release notes
RELEASE_NOTES=$(cat <<'EOF'
## Duperemove with Progress Indicators

This release adds progress indicators for the hash loading phase, making it easier to monitor long-running deduplication operations on large hashfiles.

### Features
- **Progress bars** during hash loading phase showing count/total/percentage
- Visual feedback for operations that can take hours on large datasets (18GB+ hashfiles)
- No more wondering if the process has crashed during the duplicate detection phase

### Installation

#### Fedora/RHEL/CentOS:
```bash
sudo dnf install ./duperemove-progressbar-0.13.1-1.fc43.x86_64.rpm
```

### Example Output
```
Loading duplicate block hashes: [##########%...] 12500/50000 (25.0%)
```

### Package Files
- `duperemove-progressbar-0.13.1-1.fc43.x86_64.rpm` - Main binary package for Fedora 43
- `duperemove-progressbar-0.13.1-1.fc43.src.rpm` - Source RPM for rebuilding

Based on duperemove v0.13 with custom progress indicator patches.
EOF
)

echo "Creating GitHub release $TAG..."

# Create the release
RELEASE_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/releases" \
  -d "$(jq -n \
    --arg tag "$TAG" \
    --arg name "$RELEASE_NAME" \
    --arg body "$RELEASE_NOTES" \
    '{tag_name: $tag, name: $name, body: $body, draft: false, prerelease: false}')")

UPLOAD_URL=$(echo "$RELEASE_RESPONSE" | jq -r '.upload_url' | sed 's/{?name,label}//')

if [ "$UPLOAD_URL" == "null" ]; then
    echo "Error creating release:"
    echo "$RELEASE_RESPONSE" | jq .
    exit 1
fi

echo "Release created successfully!"
echo "Uploading RPM package..."

# Upload RPM
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/x-rpm" \
  "$UPLOAD_URL?name=$(basename $RPM_FILE)" \
  --data-binary "@$RPM_FILE" > /dev/null

echo "Uploading SRPM package..."

# Upload SRPM
curl -s -X POST \
  -H "Authorization: token $GH_TOKEN" \
  -H "Content-Type: application/x-rpm" \
  "$UPLOAD_URL?name=$(basename $SRPM_FILE)" \
  --data-binary "@$SRPM_FILE" > /dev/null

echo ""
echo "✅ Release created successfully!"
echo "View it at: https://github.com/$REPO/releases/tag/$TAG"
