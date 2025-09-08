# Makefile for Extract-XISO GUI

CC = clang
CFLAGS = -Wall -Wextra -std=c99
OBJCFLAGS = -Wall -Wextra -fobjc-arc
FRAMEWORKS = -framework Cocoa -framework Foundation

# Targets
GUI_TARGET = extract-xiso-gui
CLI_TARGET = extract-xiso

# Sources
GUI_SOURCE = ExtractXISOGUI.m
CLI_SOURCE = extract-xiso.c

# Build directories
BUILD_DIR = build
GUI_BUILD_DIR = $(BUILD_DIR)/gui

.PHONY: all gui cli clean install

all: cli gui

# Build CLI version first (required for GUI)
cli:
	@echo "Building CLI version..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake .. && make

# Build GUI version
gui: cli
	@echo "Building GUI version..."
	@mkdir -p $(GUI_BUILD_DIR)
	$(CC) $(OBJCFLAGS) $(FRAMEWORKS) -o $(GUI_BUILD_DIR)/$(GUI_TARGET) $(GUI_SOURCE)
	@echo "Copying CLI binary to GUI bundle..."
	@cp $(BUILD_DIR)/$(CLI_TARGET) $(GUI_BUILD_DIR)/

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)

# Install (copy to /usr/local/bin)
install: gui
	@echo "Installing to /usr/local/bin..."
	@cp $(BUILD_DIR)/$(CLI_TARGET) /usr/local/bin/
	@cp $(GUI_BUILD_DIR)/$(GUI_TARGET) /usr/local/bin/
	@echo "Installation complete!"

# Run GUI
run-gui: gui
	@echo "Starting GUI..."
	@$(GUI_BUILD_DIR)/$(GUI_TARGET)

# Run CLI help
run-cli: cli
	@$(BUILD_DIR)/$(CLI_TARGET) -h

help:
	@echo "Extract-XISO Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build both CLI and GUI versions"
	@echo "  cli       - Build CLI version only"  
	@echo "  gui       - Build GUI version (requires cli)"
	@echo "  clean     - Clean build artifacts"
	@echo "  install   - Install both versions to /usr/local/bin"
	@echo "  run-gui   - Build and run GUI version"
	@echo "  run-cli   - Build and show CLI help"
	@echo "  help      - Show this help message"