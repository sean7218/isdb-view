import ArgumentParser
import Foundation
import IndexStoreDB

@main
struct IndexStoreDBViewer: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "view-indexdb",
        abstract: "A tool for viewing IndexStore database contents",
        subcommands: [ListSymbols.self]
    )
}

struct ListSymbols: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-symbols",
        abstract: "List all symbols in the IndexStore database"
    )

    @Option(name: .shortAndLong, help: "Path to the IndexStore")
    var storePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore database")
    var databasePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore library")
    var libraryPath: String = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

    func run() throws {
        print("Opening IndexStore database at: \(databasePath)")

        // Verify database path exists
        guard FileManager.default.fileExists(atPath: databasePath) else {
            throw ValidationError("IndexStore database not found at path: \(databasePath)")
        }

        // Create IndexStore library
        let library: IndexStoreLibrary
        do {
            library = try IndexStoreLibrary(dylibPath: libraryPath)
        } catch {
            throw ValidationError("Failed to load IndexStore library: \(error.localizedDescription)")
        }

        // Open the IndexStore database
        let indexStoreDB: IndexStoreDB
        do {
            indexStoreDB = try IndexStoreDB(
                storePath: storePath,
                databasePath: databasePath,
                library: library
            )
        } catch {
            throw ValidationError(
                "Failed to open IndexStore database: \(error.localizedDescription)")
        }

        print("Successfully opened IndexStore database")

        // Enumerate all symbols
        indexStoreDB.forEachSymbolName { name in
            print(name)
            return true
        }
    }
}
