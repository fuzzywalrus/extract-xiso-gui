# Extract-XISO GUI v0.1.4

Native macOS GUI for the extract-xiso command-line tool. This release provides a double-clickable app while keeping full compatibility with the original CLI (extract-xiso v2.7.1).

## ✨ What's New

### 🖥️ **Native macOS GUI Application**
- **Double-clickable app** - Just double-click to launch!
- **Native Cocoa interface** - Feels right at home on macOS
- **All CLI modes supported**:
  - 📤 **Extract** XISO files to directories
  - 📦 **Create** XISO from directories  
  - 📋 **List** XISO file contents
  - 🔄 **Rewrite/Optimize** XISO files
- **File browser integration** - Easy point-and-click file selection
- **Progress feedback** - Visual progress bars and status updates
- **Real-time output** - See command results as they happen
- **Options support** - Quiet mode and system update skipping

### 📁 **What's Included**
- `Extract-XISO.app` - Double-clickable GUI application
- `extract-xiso` - Original CLI tool (same v2.7.1 functionality)
- Installation script for system-wide setup
- Complete documentation

## 🚀 **Quick Start**

### Option 1: Portable Use
1. Download and extract the ZIP or mount the DMG
2. Double-click `Extract-XISO.app` to launch the GUI
3. Or run `./extract-xiso -h` for CLI help

### Option 2: System Installation  
1. Download and extract
2. Run `./install.sh` (requires admin password)
3. Find "Extract-XISO" in your Applications folder
4. Use `extract-xiso` command from anywhere in Terminal

## 💻 **System Requirements**
- macOS 11.0 (Big Sur) or later
- Intel or Apple Silicon (universal binary)
- ~1MB disk space

## 📦 **Downloads**

Choose your preferred format:

- **ZIP Archive**: `extract-xiso-0.1.4-macos.zip`
  - Extract and use immediately
  
- **DMG Image**: `extract-xiso-0.1.4-macos.dmg` (when built via `build-release.sh`)
  - Native macOS installer format
  - Mount and drag to Applications

- **Checksums**: `checksums.txt`
  - SHA-256 hashes for verification

## 🔐 **Verification**

Verify your download integrity:
```bash
shasum -a 256 -c checksums.txt
```

## 📚 **Documentation**

Each release includes:
- `README-CLI.md` - Command-line usage guide
- `README-GUI.md` - GUI application guide  
- `RELEASE-NOTES.md` - Detailed release information
- `LICENSE.TXT` - Software license

## 🎯 **GUI Features Demo**

The GUI provides an intuitive interface for all extract-xiso operations:

1. **Mode Selection** - Choose Extract, Create, List, or Rewrite
2. **File Browser** - Click "Browse" to select files/directories
3. **Options** - Enable quiet mode or skip system updates
4. **One-Click Execute** - Hit "Execute" and watch the progress
5. **Live Output** - See real-time command results

## 🛠️ **For Developers**

This release includes:
- Full source code for the GUI wrapper
- Makefile for easy building
- App bundle structure for macOS distribution
- Build scripts for creating releases

## 🐛 **Known Issues**

- Some deprecation warnings during build (doesn't affect functionality)
- GUI currently macOS-only (CLI works on all platforms)

## 🤝 **Contributing**

Found a bug or want to contribute? Please:
- Report issues on the GitHub Issues page
- Submit pull requests for improvements
- Share feedback on the GUI experience

---

**Full Changelog**: [Link to compare view]

Enjoy the new GUI! 🎊