#!/bin/bash

# Launch script for Extract-XISO.app
# This bypasses macOS Gatekeeper security restrictions

echo "Launching Extract-XISO..."

# Remove quarantine attribute if present
xattr -d com.apple.quarantine "Extract-XISO.app" 2>/dev/null || true

# Launch the app
open "Extract-XISO.app"

echo "Extract-XISO launched successfully!"