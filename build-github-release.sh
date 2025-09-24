#!/bin/bash

# GitHub Release Build Script for Extract-XISO
# Creates distribution-ready packages optimized for GitHub releases

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="0.1.3"
RELEASE_DIR="release"
DIST_DIR="$RELEASE_DIR/extract-xiso-$VERSION-macos"

echo "🚀 Building Extract-XISO for GitHub Release v$VERSION"
echo "===================================================="

# Clean previous builds
echo "🧹 Cleaning previous builds..."
make clean
rm -rf "$RELEASE_DIR"

# Create release directory structure
echo "📁 Creating release directory structure..."
mkdir -p "$DIST_DIR"

# Build everything
echo "🔨 Building CLI and GUI..."
make all

# Verify builds exist
if [ ! -f "build/extract-xiso" ]; then
    echo "❌ CLI build failed!"
    exit 1
fi

if [ ! -d "build/Extract-XISO.app" ]; then
    echo "❌ GUI build failed!"
    exit 1
fi

echo "✅ Build successful!"

# Copy binaries to release directory
echo "📦 Packaging release files..."

# Copy app bundle
cp -R "build/Extract-XISO.app" "$DIST_DIR/"

# Copy CLI binary
cp "build/extract-xiso" "$DIST_DIR/"

# Copy documentation
cp "README.md" "$DIST_DIR/README-CLI.md"
cp "GUI-README.md" "$DIST_DIR/README-GUI.md"
cp "LICENSE.TXT" "$DIST_DIR/"

# Create GitHub-specific installation guide
cat > "$DIST_DIR/INSTALLATION.md" << 'EOF'
# Installation Guide

## Security Notice for GitHub Downloads

When downloading from GitHub, macOS may show a security warning. This is normal for apps distributed outside the App Store.

### For the GUI App:
1. **First time opening**: Right-click `Extract-XISO.app` → **Open** → **Open** again
2. **Alternative**: Go to System Settings → Security & Privacy → Allow Extract-XISO
3. **For advanced users**: Remove quarantine: `xattr -dr com.apple.quarantine Extract-XISO.app`

### Installation Options:
- **Portable**: Use directly from this folder
- **System-wide GUI**: Copy `Extract-XISO.app` to `/Applications/`
- **CLI access**: Copy `extract-xiso` to `/usr/local/bin/`

### Quick Install Script:
Run `./install.sh` to install both GUI and CLI system-wide.

## Requirements
- macOS 11.0 or later
- Intel or Apple Silicon Mac

## Usage
- **GUI**: Double-click `Extract-XISO.app` or run `open Extract-XISO.app`
- **CLI**: Run `./extract-xiso -h` for help
EOF

# Create installation script
cat > "$DIST_DIR/install.sh" << 'EOF'
#!/bin/bash

echo "Installing Extract-XISO..."

# Copy app to Applications
echo "📱 Installing GUI app to /Applications..."
sudo cp -R "Extract-XISO.app" /Applications/

# Copy CLI to /usr/local/bin
echo "⚡ Installing CLI to /usr/local/bin..."
sudo cp extract-xiso /usr/local/bin/
sudo chmod +x /usr/local/bin/extract-xiso

echo "✅ Installation complete!"
echo ""
echo "🎉 You can now:"
echo "   - Find 'Extract-XISO' in your Applications folder"
echo "   - Run 'extract-xiso' from Terminal anywhere"
echo ""
echo "Note: First time opening the GUI app, right-click → Open to bypass security warning"
EOF

chmod +x "$DIST_DIR/install.sh"

# Create launcher script
cat > "$DIST_DIR/launch-gui.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "Opening Extract-XISO GUI..."
echo "Note: If you see a security warning, right-click the app and choose 'Open'"
open Extract-XISO.app
EOF

chmod +x "$DIST_DIR/launch-gui.command"

# Create ZIP archive for GitHub release
echo "🗜️  Creating ZIP archive for GitHub..."
cd "$RELEASE_DIR"
zip -r "extract-xiso-$VERSION-macos.zip" "extract-xiso-$VERSION-macos/"
cd ..

# Generate checksums for GitHub release
echo "🔐 Generating checksums..."
cd "$RELEASE_DIR"
shasum -a 256 *.zip > checksums.txt
cd ..

echo ""
echo "🎉 GitHub Release build complete!"
echo "================================="
echo "📁 Release directory: $DIST_DIR"
echo "📦 ZIP for GitHub: $RELEASE_DIR/extract-xiso-$VERSION-macos.zip"
echo "🔐 Checksums: $RELEASE_DIR/checksums.txt"
echo ""
echo "🚀 Ready for GitHub Release! Upload:"
echo "   - extract-xiso-$VERSION-macos.zip"
echo "   - checksums.txt"
echo ""
echo "📋 Release Notes Template:"
echo "   - Universal binary (Intel + Apple Silicon)"
echo "   - Code signed for security"
echo "   - No App Store dependencies"
echo "   - Includes both GUI app and CLI tool"
EOF