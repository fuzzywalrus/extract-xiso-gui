#!/bin/bash

# Launch script for Extract-XISO GUI on macOS

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Build the GUI if it doesn't exist
if [ ! -f "build/gui/extract-xiso-gui" ]; then
    echo "Building GUI application..."
    make gui
fi

# Launch the GUI
echo "Launching Extract-XISO GUI..."
./build/gui/extract-xiso-gui