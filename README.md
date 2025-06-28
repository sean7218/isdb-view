# IndexstoreDBView (isdb-view)

A Swift CLI tool for viewing and exploring IndexStore database contents. This tool helps developers inspect symbols, files, and their relationships within Xcode's IndexStore databases.

## Features

- **List Symbols**: Enumerate all symbols with their USRs (Unified Symbol Resolution) and locations
- **List Files**: Display all files indexed in the database
- **Symbol Details**: Show symbol relationships, roles, and providers

## Installation

### Build from Source

```bash
git clone <repository-url>
cd isdb-view
swift build -c release
```

The executable will be available at `.build/release/isdb-view`.

## Usage

The tool provides several subcommands to explore IndexStore databases:

### List All Symbols

```bash
swift run isdb-view list-symbols \
    --store-path /path/to/.index-store \
    --database-path /path/to/.index-db \
    --library-path /path/to/libIndexStore.dylib
```

### List All Files

```bash
swift run isdb-view list-files \
    --store-path /path/to/.index-store \
    --database-path /path/to/.index-db \
    --library-path /path/to/libIndexStore.dylib
```

### Command Line Options

- `--store-path` (`-s`): Path to the IndexStore directory (usually `.index-store`)
- `--database-path` (`-d`): Path to the IndexStore database directory (usually `.index-db`)
- `--library-path` (`-l`): Path to the IndexStore library (defaults to Xcode's libIndexStore.dylib)

### Default Library Path

The tool defaults to the standard Xcode installation path:
```
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib
```

## Examples

### Analyzing a Swift Project

If you have a Swift project with IndexStore enabled:

```bash
# Build your project first to generate index data
cd YourSwiftProject
xcodebuild -project YourProject.xcodeproj -scheme YourScheme

# Then analyze the generated index
swift run isdb-view list-symbols \
    --store-path ./DerivedData/YourProject/Build/Intermediates.noindex/YourProject.build/Debug/YourTarget.build/Objects-normal/arm64/.index-store \
    --database-path ./DerivedData/YourProject/Index.noindex/DataStore
```

### Typical Output

**List Symbols:**
```
Symbol: MyClass
  USR: c:@M@MyModule@objc(cs)MyClass
  Location: /path/to/MyClass.swift:10:7
  Role: Definition
  Provider: swift-frontend

Symbol: myFunction
  USR: s:8MyModule10myFunctionyyF
  Location: /path/to/MyFile.swift:25:6
  Role: Definition
```

**List Files:**
```
Files in IndexStore database:
/path/to/project/Sources/File1.swift
/path/to/project/Sources/File2.swift
/path/to/project/Sources/Module/File3.swift

Total files found: 3
```

## Dependencies

This project depends on:
- [IndexStoreDB](https://github.com/swiftlang/indexstore-db) - Core library for reading IndexStore databases
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Command-line interface framework

## Requirements

- Swift 6.1 or later
- Xcode (for libIndexStore.dylib)
- macOS (due to IndexStore library requirements)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
