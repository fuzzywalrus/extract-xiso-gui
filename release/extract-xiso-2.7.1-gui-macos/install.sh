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
