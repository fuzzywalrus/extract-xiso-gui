#!/bin/bash

# Launch script for Extract-XISO GUI on macOS

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Build the app if it doesn't exist
if [ ! -d "build/Extract-XISO.app" ]; then
    echo "Building app bundle..."
    make app
fi

# Launch the app bundle
echo "Launching Extract-XISO GUI..."
open build/Extract-XISO.app