#!/bin/bash

# Build release script for Extract-XISO GUI
# This script creates distribution-ready packages for macOS

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="0.1.4"
RELEASE_DIR="release"
DIST_DIR="$RELEASE_DIR/extract-xiso-$VERSION-macos"

echo "🚀 Building Extract-XISO GUI Release v$VERSION"
echo "================================================"

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

# Sign and notarize the app before packaging (so ZIP/DMG contain signed app)
echo "🔐 Code signing and notarizing app..."
./sign.sh

# Copy binaries to release directory (signed app)
echo "📦 Packaging release files..."
cp -R "build/Extract-XISO.app" "$DIST_DIR/"
cp "build/extract-xiso" "$DIST_DIR/"

# Copy documentation
cp "README.md" "$DIST_DIR/README-CLI.md"
cp "GUI-README.md" "$DIST_DIR/README-GUI.md"
cp "LICENSE.TXT" "$DIST_DIR/"

# Create release notes
cat > "$DIST_DIR/RELEASE-NOTES.md" << EOF
# Extract-XISO GUI v$VERSION

## What's New

Native macOS GUI for extract-xiso with full CLI compatibility.

### 🖥️ **macOS GUI Application**
- **Double-clickable app**: Just double-click \`Extract-XISO.app\` to launch
- **Native Cocoa interface**: Extract, Create, List, and Rewrite modes
- **File browser integration**, **progress feedback**, **real-time output**

### 📦 **What's Included**
- \`Extract-XISO.app\` - GUI application (signed/notarized in this build)
- \`extract-xiso\` - Command-line tool (v2.7.1 compatible)
- Documentation and license

### 🚀 **Quick Start**
1. **GUI**: Double-click \`Extract-XISO.app\`
2. **CLI**: Run \`./extract-xiso -h\` for help

### 💻 **System Requirements**
- macOS 11.0 (Big Sur) or later
- Intel or Apple Silicon (universal binary)

### 🔧 **Installation**
- **Portable**: Use from this folder
- **System-wide**: Copy \`Extract-XISO.app\` to \`/Applications/\`, \`extract-xiso\` to \`/usr/local/bin/\`
- Or run \`./install.sh\` for both

Enjoy! 🎊
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
EOF

chmod +x "$DIST_DIR/install.sh"

# Create launcher script
cat > "$DIST_DIR/launch-gui.command" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
open Extract-XISO.app
EOF

chmod +x "$DIST_DIR/launch-gui.command"

# Create ZIP archive
echo "🗜️  Creating ZIP archive..."
cd "$RELEASE_DIR"
zip -r "extract-xiso-$VERSION-macos.zip" "extract-xiso-$VERSION-macos/"
cd ..

# Create DMG (if hdiutil is available)
if command -v hdiutil >/dev/null 2>&1; then
    echo "💿 Creating DMG image..."
    DMG_NAME="extract-xiso-$VERSION-macos.dmg"
    hdiutil create -volname "Extract-XISO v$VERSION" -srcfolder "$DIST_DIR" -ov -format UDZO "$RELEASE_DIR/$DMG_NAME"
    echo "✅ DMG created: $RELEASE_DIR/$DMG_NAME"
fi

# Generate checksums
echo "🔐 Generating checksums..."
cd "$RELEASE_DIR"
shasum -a 256 *.zip > checksums.txt
for f in *.dmg; do
    [ -f "$f" ] && shasum -a 256 "$f" >> checksums.txt
done
cd ..

echo ""
echo "🎉 Release build complete!"
echo "========================================"
echo "📁 Release directory: $DIST_DIR"
echo "📦 ZIP archive: $RELEASE_DIR/extract-xiso-$VERSION-macos.zip"
if [ -f "$RELEASE_DIR/extract-xiso-$VERSION-macos.dmg" ]; then
    echo "💿 DMG image: $RELEASE_DIR/extract-xiso-$VERSION-macos.dmg"
fi
echo "🔐 Checksums: $RELEASE_DIR/checksums.txt"
echo ""
echo "📋 Ready for GitHub release! Upload these files:"
echo "   - extract-xiso-$VERSION-macos.zip"
if [ -f "$RELEASE_DIR/extract-xiso-$VERSION-macos.dmg" ]; then
    echo "   - extract-xiso-$VERSION-macos.dmg"
fi
echo "   - checksums.txt"
echo ""
echo "🚀 You can test the release by running:"
echo "   cd $DIST_DIR && open Extract-XISO.app"