# Makefile for Extract-XISO GUI

CC = clang
CFLAGS = -Wall -Wextra -std=c99 -mmacosx-version-min=11.0 -arch x86_64 -arch arm64
OBJCFLAGS = -Wall -Wextra -fobjc-arc -mmacosx-version-min=11.0 -arch x86_64 -arch arm64
FRAMEWORKS = -framework Cocoa -framework Foundation

# Targets
GUI_TARGET = Extract-XISO
CLI_TARGET = extract-xiso
APP_BUNDLE = Extract-XISO.app

# Sources
GUI_SOURCE = ExtractXISOGUI.m
CLI_SOURCE = extract-xiso.c

# Build directories
BUILD_DIR = build
APP_DIR = $(BUILD_DIR)/$(APP_BUNDLE)
APP_CONTENTS = $(APP_DIR)/Contents
APP_MACOS = $(APP_CONTENTS)/MacOS
APP_RESOURCES = $(APP_CONTENTS)/Resources

.PHONY: all app gui cli clean install notarize staple

all: cli app

# Build CLI version first (required for GUI)
cli:
	@echo "Building CLI version..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake .. && make

# Build GUI version as app bundle
app: cli
	@echo "Building app bundle..."
	@mkdir -p $(APP_MACOS) $(APP_RESOURCES)
	$(CC) $(OBJCFLAGS) $(FRAMEWORKS) -o $(APP_MACOS)/$(GUI_TARGET) $(GUI_SOURCE)
	@echo "Copying CLI binary to app bundle..."
	@cp $(BUILD_DIR)/$(CLI_TARGET) $(APP_RESOURCES)/
	@echo "Copying Info.plist..."
	@cp Info.plist $(APP_CONTENTS)/
	@echo "Copying app icon..."
	@cp Icon-Mac-Default-1024x1024@1x.icns $(APP_RESOURCES)/
	@echo "Copying launch script..."
	@cp launch-extract-xiso.sh $(BUILD_DIR)/
	@echo "Code signing app bundle..."
	@codesign --force --deep --options runtime --sign "Developer ID Application: Greg Gant (36SA478KNK)" $(APP_DIR)
	@echo "App bundle created: $(APP_DIR)"

# Legacy GUI target for compatibility
gui: app

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

# Install (copy to /Applications and /usr/local/bin)
install: app
	@echo "Installing CLI to /usr/local/bin..."
	@cp $(BUILD_DIR)/$(CLI_TARGET) /usr/local/bin/
	@echo "Installing app to /Applications..."
	@cp -R $(APP_DIR) /Applications/
	@echo "Installation complete!"

# Run GUI app
run-app: app
	@echo "Starting app..."
	@open $(APP_DIR)

# Legacy run-gui target
run-gui: run-app

# Run CLI help
run-cli: cli
	@$(BUILD_DIR)/$(CLI_TARGET) -h

# Notarization (requires Apple ID app-specific password)
notarize: app
	@echo "Creating ZIP for notarization..."
	@cd $(BUILD_DIR) && zip -r Extract-XISO.zip $(APP_BUNDLE)
	@echo "Submitting for notarization..."
	@echo "You'll need to run: xcrun notarytool submit $(BUILD_DIR)/Extract-XISO.zip --apple-id YOUR_APPLE_ID --password YOUR_APP_PASSWORD --team-id 36SA478KNK --wait"

# Staple notarization ticket
staple: 
	@echo "Stapling notarization ticket..."
	@xcrun stapler staple $(APP_DIR)
	@xcrun stapler validate $(APP_DIR)

help:
	@echo "Extract-XISO Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build both CLI and app bundle"
	@echo "  cli       - Build CLI version only"  
	@echo "  app       - Build macOS app bundle (requires cli)"
	@echo "  gui       - Alias for app (compatibility)"
	@echo "  clean     - Clean build artifacts"
	@echo "  install   - Install CLI to /usr/local/bin and app to /Applications"
	@echo "  run-app   - Build and open app bundle"
	@echo "  run-gui   - Alias for run-app (compatibility)"
	@echo "  run-cli   - Build and show CLI help"
	@echo "  notarize  - Create ZIP and show notarization command"
	@echo "  staple    - Staple notarization ticket to app"
	@echo "  help      - Show this help message"