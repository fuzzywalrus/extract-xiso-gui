#!/bin/bash

# Code signing and notarization script for Extract-XISO
# This script handles the complete signing and notarization process

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load configuration from .env file
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env file not found! Please create .env with your signing credentials."
    echo "See README for setup instructions."
    exit 1
fi

# Verify required variables are set
if [ -z "$APPLE_ID" ] || [ -z "$APP_PASSWORD" ] || [ -z "$TEAM_ID" ] || [ -z "$SIGNING_IDENTITY" ]; then
    echo "❌ Missing required environment variables in .env file:"
    echo "   APPLE_ID, APP_PASSWORD, TEAM_ID, SIGNING_IDENTITY"
    exit 1
fi

APP_BUNDLE="build/Extract-XISO.app"
ZIP_FILE="build/Extract-XISO.zip"

echo "🔐 Starting code signing and notarization process..."
echo "=================================================="

# Step 1: Build the app if it doesn't exist
if [ ! -d "$APP_BUNDLE" ]; then
    echo "📦 Building app bundle first..."
    make app
fi

# Step 2: Sign the embedded CLI binary first
echo "✍️  Code signing embedded CLI binary..."
codesign --force --options runtime --sign "$SIGNING_IDENTITY" "$APP_BUNDLE/Contents/Resources/extract-xiso"

# Step 3: Clean sign the app bundle  
echo "✍️  Code signing app bundle..."
codesign --force --deep --options runtime --sign "$SIGNING_IDENTITY" "$APP_BUNDLE"

# Verify code signing
echo "🔍 Verifying code signature..."
codesign -dv --verbose=4 "$APP_BUNDLE"

# Step 4: Create ZIP for notarization
echo "🗜️  Creating ZIP for notarization..."
rm -f "$ZIP_FILE"
cd build
zip -r Extract-XISO.zip Extract-XISO.app
cd ..

# Step 5: Submit for notarization
echo "📤 Submitting to Apple for notarization..."
xcrun notarytool submit "$ZIP_FILE" \
    --apple-id "$APPLE_ID" \
    --password "$APP_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait

# Step 6: Staple the notarization ticket
echo "📎 Stapling notarization ticket..."
xcrun stapler staple "$APP_BUNDLE"

# Step 7: Validate the final result
echo "✅ Validating final app bundle..."
xcrun stapler validate "$APP_BUNDLE"
spctl -a -vv "$APP_BUNDLE"

echo ""
echo "🎉 Code signing and notarization complete!"
echo "========================================="
echo "Your app is now ready for distribution and will run on all Macs without security warnings."
echo ""
echo "App location: $APP_BUNDLE"
echo "You can now distribute this app bundle safely."