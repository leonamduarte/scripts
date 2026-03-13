.PHONY: all build run clean deps test

BINARY_NAME=wsl-bootstrap.exe
BUILD_DIR=build

all: deps build

deps:
	go mod download
	go mod tidy

build:
	@echo "Building $(BINARY_NAME)..."
	go build -o $(BUILD_DIR)/$(BINARY_NAME) .
	@echo "Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

run: build
	$(BUILD_DIR)/$(BINARY_NAME)

clean:
	rm -rf $(BUILD_DIR)
	go clean

test:
	go test -v ./...

# Build for release (optimized)
release:
	@echo "Building release version..."
	go build -ldflags="-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) .
	@echo "Release build complete: $(BUILD_DIR)/$(BINARY_NAME)"

# Install dependencies
install-deps:
	go get github.com/charmbracelet/bubbletea
	go get github.com/charmbracelet/lipgloss
	go mod tidy
