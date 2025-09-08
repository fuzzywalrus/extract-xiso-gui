# Makefile for Extract-XISO GUI

CC = clang
CFLAGS = -Wall -Wextra -std=c99
OBJCFLAGS = -Wall -Wextra -fobjc-arc
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

.PHONY: all app gui cli clean install

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
	@echo "  help      - Show this help message"