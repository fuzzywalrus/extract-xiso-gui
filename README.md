# Extract-XISO GUI for macOS

A native macOS GUI wrapper for the [extract-xiso](https://github.com/XboxDev/extract-xiso) command-line utility. Extract-XISO allows creation, modification, and extraction of Xbox ISO files (XISOs), and this GUI version makes it accessible to macOS users through a native interface.

The Xbox ISO format is a proprietary disc image format used by the original Xbox console. It is based on the ISO 9660 file system but includes additional metadata and encryption specific to the Xbox. Emulators, like XEMU, on the other hand, expect standard ISOs. Extract XISO is a tool that helps to extract the contents of Xbox ISOs and convert them into standard ISO that can be used by these emulators.

- **Native macOS App**: Double-clickable `.app` bundle with Cocoa interface
- **Fully Self-Contained**: CLI binary bundled inside - no dependencies needed!
- **Point & Click**: Easy file selection with native file browsers  
- **Visual Feedback**: Progress bars and real-time status updates
- **All CLI Features**: Full support for Extract, Create, List, and Rewrite modes
- **Zero Setup**: Works immediately after download - no installation required!

##  Quick Start

### Option 1: Download Release (Recommended)
1. Download the latest release from [GitHub Releases](https://github.com/fuzzywalrus/extract-xiso-gui/releases)
2. **Important**: On first launch, macOS may show "Apple cannot check it for malicious software"
   - Right-click the app and select "Open" 
   - Click "Open" in the security dialog
   - Or go to System Preferences > Security & Privacy > General and click "Open Anyway"
3. Double-click `Extract-XISO.app` to launch the GUI


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
- **CLI Core**: Original C implementation (v2.7.1)
- **Architecture**: GUI wrapper executes bundled CLI binary
- **Threading**: Background execution keeps UI responsive
- **Bundle Structure**: Complete `.app` with embedded CLI
- **Dependencies**: Only system libraries - fully portable
- **Binary Location**: `Contents/Resources/extract-xiso` (auto-detected)

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
