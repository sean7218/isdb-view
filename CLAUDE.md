# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift Package Manager project for an IndexStore database viewer tool that depends on [indexstore-db](https://github.com/swiftlang/indexstore-db) to view database contents.

## Build System & Commands

This project uses Swift Package Manager (SPM). Common commands:

```bash
# Build the project
swift build

# Run the executable
swift run

# Build in release mode
swift build -c release

# Run tests (if any exist)
swift test

# Clean build artifacts
swift package clean

# Generate Xcode project (if needed)
swift package generate-xcodeproj
```

## Project Structure

- `Package.swift` - Swift Package Manager manifest file
- `Sources/main.swift` - Main executable entry point (currently a placeholder)
- No dependencies are currently declared in Package.swift

## Architecture Notes

- This is a simple executable target with no current dependencies
- The main.swift file contains only a "Hello, world!" placeholder
- The project is intended to integrate with indexstore-db for database viewing functionality
- Swift 6.1 toolchain is required as specified in Package.swift

## Development Notes

- The project appears to be in early development stage
- No external dependencies are currently configured despite the README mentioning indexstore-db dependency
- No tests are currently defined in the package manifest