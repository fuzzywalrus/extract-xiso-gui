# Extract-XISO GUI for macOS

A native macOS GUI wrapper for the [extract-xiso](https://github.com/XboxDev/extract-xiso) command-line utility. Extract-XISO allows creation, modification, and extraction of Xbox ISO files (XISOs), and this GUI version makes it accessible to macOS users through a native interface.

The Xbox ISO format is a proprietary disc image format used by the original Xbox console. It is based on the ISO 9660 file system but includes additional metadata and encryption specific to the Xbox. Emulators, like XEMU, on the other hand, expect standard ISOs. Extract XISO is a tool that helps to extract the contents of Xbox ISOs and convert them into standard ISO that can be used by these emulators.

- **Native macOS App**: Double-clickable `.app` bundle with Cocoa interface
- **Fully Self-Contained**: CLI binary bundled inside - no dependencies needed!
- **Point & Click**: Easy file selection with native file browsers  
- **Visual Feedback**: Progress bars and real-time status updates
- **All CLI Features**: Full support for Extract, Create, List, and Rewrite modes
- **Zero Setup**: Works immediately after download - no installation required!
- **minor CLI improvements**: Fixed warnings and improved type safety (100% compatible)

##  Quick Start

### Option 1: Download Release (Recommended)
1. Download the latest release from [GitHub Releases](https://github.com/fuzzywalrus/extract-xiso-gui/releases)
2. **Notarized builds** (v0.1.3+): Double-click `Extract-XISO.app` - no security warnings!
3. **Older builds**: If you see "Apple cannot check it for malicious software":
   - Right-click the app and select "Open" 
   - Click "Open" in the security dialog
   - Or go to System Settings > Privacy & Security and click "Open Anyway"


### Option 2: Build from Source
```bash
# Build both CLI and GUI
make all

# Launch the GUI app
./launch-gui.sh
# or
make run-app
```

## GUI Features

The GUI provides an intuitive interface for all extract-xiso operations:

### **Extract Mode and repackage** (Default)
- Select XISO files to extract
- Choose output directory  
- Extract Xbox game files to folders
- Creates a decrypted ISO

### **Create Mode**
- Select source directory
- Create XISO files from Xbox game folders
- Automatic .xbe media patching

### **List Mode** 
- Browse XISO file contents
- View file structure without extracting

### **Rewrite Mode**
- Optimize XISO file structure
- Batch processing support



## Command Line Usage

The following is documenation from the CLI version supports all original functionality:

### Create XISO
```bash
# Create halo-2.iso from ./halo-2 directory
./extract-xiso -c ./halo-2

# Create with custom name and location
./extract-xiso -c ./halo-ce /home/games/halo-ce.iso
```

### Extract XISO
```bash
# Extract to ./halo-ce/ directory
./extract-xiso ./halo-ce.iso

# Extract to specific directory
./extract-xiso ./halo-2.iso -d /home/games/halo-2/
```

### List Contents
```bash
# List single XISO
./extract-xiso -l ./halo-ce.iso

# List multiple XISOs
./extract-xiso -l ./halo-2.iso ./halo-ce.iso
```

### Rewrite/Optimize
```bash
# Optimize single XISO
./extract-xiso -r ./halo-ce.iso

# Batch optimization
./extract-xiso -r ./halo-ce.iso ./halo-2.iso
```

### Options
```
-d <directory>      Extract/rewrite to specific directory
-D                  Delete original after rewrite
-h                  Show help
-m                  Disable .xbe media patching
-q                  Quiet mode (less output)
-Q                  Silent mode (no output)
-s                  Skip $SystemUpdate folder
-v                  Show version info
```

##  Building

### Requirements
- **macOS**: 11.0+ with Xcode command line tools
- **Tools**: cmake, make, clang

### Build Commands
```bash
# Build everything (CLI + GUI app bundle)
make all

# Build just the CLI
make cli

# Build just the GUI app
make app

# Clean build files
make clean
```

### Installation
```bash
# Install system-wide
make install

# This installs:
# - CLI binary to /usr/local/bin/extract-xiso
# - GUI app to /Applications/Extract-XISO.app
```

### Code Signing and Notarization (For Developers)

To create properly signed and notarized builds for distribution:

#### 1. Setup Apple Developer Account
- Enroll in the **Apple Developer Program** ($99/year)
- Generate an **App-Specific Password** at [appleid.apple.com](https://appleid.apple.com)

#### 2. Create `.env` File
Create a `.env` file in the project root with your credentials:

```bash
# Apple Developer Account Configuration for Code Signing and Notarization
# Do NOT commit this file to git - it contains sensitive credentials

APPLE_ID="your-apple-id@example.com"
APP_PASSWORD="your-app-specific-password"
TEAM_ID="YOUR_TEAM_ID"
SIGNING_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
```

**To find your Team ID:**
```bash
# List your signing identities
security find-identity -v -p codesigning
```

#### 3. Sign and Notarize
```bash
# Build, sign, and notarize for distribution
./sign.sh

# Or use the GitHub release build (includes signing)
./build-github-release.sh
```

**What this does:**
- ✅ Signs both the app and embedded CLI with your Developer ID
- ✅ Submits to Apple for notarization
- ✅ Staples the notarization ticket to the app
- ✅ Creates apps that run without security warnings

**Note:** The `.env` file is automatically excluded from git commits for security.

## System Requirements

- **macOS**: 11.0 (Big Sur) or later
- **Architecture**: Intel or Apple Silicon
- **Disk Space**: ~1MB
- **Memory**: Minimal - works with system resources

## File Support

- **`.iso`** - Standard ISO files
- **Directories** - For creating XISOs from game folders

## Technical Details

- **GUI Framework**: Objective-C with Cocoa
- **CLI Core**: Based on extract-xiso v2.7.1 with minor improvements
- **Architecture**: GUI wrapper executes bundled CLI binary
- **Threading**: Background execution keeps UI responsive
- **Bundle Structure**: Complete `.app` with embedded CLI
- **Dependencies**: Only system libraries - fully portable
- **Binary Location**: `Contents/Resources/extract-xiso` (auto-detected)

### CLI Improvements

This wrapper includes minor improvements to the extract-xiso v2.7.1 CLI:
- Fixed compiler warnings for cleaner builds
- Fixed unsequenced modification warning (potential undefined behavior)
- Fixed nested comment formatting
- Improved type safety in pointer casts
- All functionality remains 100% compatible with original extract-xiso

## Contributing

This is a GUI wrapper for the original [extract-xiso](https://github.com/XboxDev/extract-xiso) project. 

- **Main functionality Issues**: Report to the [main extract-xiso project](https://github.com/XboxDev/extract-xiso)
- **GUI Issues**: Report here for interface-related problems
- **Feature Requests**: Welcome for GUI improvements

##  License

This GUI wrapper uses the same license as the original extract-xiso project. See `LICENSE.TXT` for details.

Original extract-xiso created by [*in*](mailto:in@fishtank.com), currently maintained by the [XboxDev organization](https://github.com/XboxDev/XboxDev).

---

**Enjoy the new GUI! ** For questions or support, please check the documentation or open an issue.
