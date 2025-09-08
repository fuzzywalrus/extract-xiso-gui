# Extract-XISO GUI for macOS

A simple graphical user interface wrapper for the extract-xiso command-line tool.

## Features

- **Graphical Interface**: Easy-to-use macOS native Cocoa interface
- **All Modes Supported**: 
  - Extract XISO files (default)
  - Create XISO from directories  
  - List XISO contents
  - Rewrite/optimize XISO files
- **File Browser Integration**: Browse for files and directories
- **Progress Feedback**: Visual progress indicator and status updates
- **Command Output**: View real-time command output
- **Options Support**: Quiet mode and skip system update options

## Building

### Requirements
- macOS with Xcode command line tools
- cmake
- make

### Build Instructions

```bash
# Build both CLI and app bundle (recommended)
make all

# Or build app bundle specifically (automatically builds CLI first)
make app

# Legacy: build GUI (now creates app bundle)
make gui
```

## Running

### Option 1: Double-click the app (easiest!)
After building, simply **double-click** `build/Extract-XISO.app` in Finder!

### Option 2: Use the launch script
```bash
./launch-gui.sh
```

### Option 3: Use make
```bash
make run-app
```

### Option 4: Open via command line
```bash
open build/Extract-XISO.app
```

## Usage

1. **Launch the application** using one of the methods above
2. **Select Mode**: Choose from Extract, Create, List, or Rewrite
3. **Choose File/Directory**: Click Browse to select your XISO file or directory
4. **Set Output Directory** (optional): Choose where to extract/save files
5. **Configure Options** (optional): Enable quiet mode or skip system updates
6. **Execute**: Click the Execute button to run the operation
7. **View Results**: Monitor progress and view command output

## GUI Layout

- **Mode Selection**: Dropdown to choose operation mode
- **File Selection**: Text field and browse button for input files
- **Output Directory**: Optional output location
- **Options**: Checkboxes for quiet mode and skip system update
- **Execute Button**: Runs the selected operation
- **Progress Bar**: Shows when operation is running
- **Status Label**: Displays current status
- **Output Area**: Shows command results and output

## Supported File Types

- `.iso` - Standard ISO files
- `.xiso` - Xbox ISO files
- Directories (for create mode)

## Command Line Equivalent

The GUI generates and executes extract-xiso commands. For example:
- Extract: `./extract-xiso game.xiso -d /output/directory`
- Create: `./extract-xiso -c /source/directory`  
- List: `./extract-xiso -l game.xiso`
- Rewrite: `./extract-xiso -r game.xiso -d /output/directory`

## Installation

To install both CLI and app system-wide:

```bash
make install
```

This copies:
- CLI binary to `/usr/local/bin/extract-xiso`
- App bundle to `/Applications/Extract-XISO.app`

After installation, you can find "Extract-XISO" in your Applications folder!

## Troubleshooting

- **Command fails**: Check that the input file/directory exists and is readable
- **GUI doesn't launch**: Ensure you have built the application first with `make gui`
- **Build errors**: Make sure you have Xcode command line tools installed: `xcode-select --install`

## Technical Notes

- Built with Objective-C and Cocoa frameworks
- Uses NSTask to execute the CLI binary
- Runs command execution on background thread to keep UI responsive
- Automatically detects CLI binary location (bundled or build directory)