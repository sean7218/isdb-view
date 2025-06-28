# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Swift Package Manager project for `isdb-view`, a CLI tool for viewing IndexStore database contents. It depends on IndexStoreDB library to query and display symbol information from Xcode's index stores.

## Build System & Commands

This project uses Swift Package Manager (SPM). Common commands:

```bash
# Build the project
swift build

# Run the executable with arguments
swift run isdb-view list-symbols --store-path /path/to/.index-store --database-path /path/to/.index-db --library-path /path/to/libIndexStore.dylib

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

- `Package.swift` - Swift Package Manager manifest declaring dependencies on IndexStoreDB and ArgumentParser
- `Sources/main.swift` - Main executable with command-line interface using ArgumentParser
- `Package.resolved` - Locked dependency versions

## Architecture Notes

### Dependencies
- **IndexStoreDB** (from swiftlang/indexstore-db): Core library for reading IndexStore databases
- **ArgumentParser** (from Apple): Command-line argument parsing framework
- **swift-lmdb** (transitive dependency): Database backend used by IndexStoreDB

### Command Structure
The CLI uses a hierarchical command structure:
- Root command: `IndexStoreDBViewer` (commandName: "view-indexdb")
- Subcommand: `ListSymbols` for enumerating all symbols in an IndexStore database

### Key Components
- **IndexStoreLibrary**: Wrapper around the native IndexStore dynamic library (libIndexStore.dylib)
- **IndexStoreDB**: Main interface for querying the IndexStore database
- **Command-line options**: Requires store path, database path, and library path (defaults to Xcode toolchain location)

## Development Notes

- Swift 6.1 toolchain is required
- Default library path assumes standard Xcode installation at `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib`
- The tool validates file existence before attempting to open databases
- Error handling includes user-friendly validation messages for missing files or library loading failures