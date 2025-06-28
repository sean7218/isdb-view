import ArgumentParser
import Foundation
import IndexStoreDB

@main
struct IndexStoreDBViewer: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "idbview",
        abstract: "A tool for viewing IndexStore database contents",
        subcommands: [ListSymbols.self]
    )
}

struct ListSymbols: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-symbols",
        abstract: "List all symbols in the IndexStore database"
    )

    @Argument(help: "Path to the IndexStore")
    var storePath: String

    @Argument(help: "Path to the IndexStore database")
    var databasePath: String

    @Flag(name: .shortAndLong, help: "Show verbose output")
    var verbose = false

    @Option(name: .shortAndLong, help: "Filter symbols by name pattern")
    var filter: String?

    @Option(name: .shortAndLong, help: "Limit number of results")
    var limit: Int?

    @Flag(help: "Show symbol details (kind, location, etc.)")
    var details = false

    func run() throws {
        if verbose {
            print("Opening IndexStore database at: \(databasePath)")
        }

        // Verify database path exists
        guard FileManager.default.fileExists(atPath: databasePath) else {
            throw ValidationError("IndexStore database not found at path: \(databasePath)")
        }

        // Open the IndexStore database
        let indexStoreDB: IndexStoreDB
        do {
            indexStoreDB = try IndexStoreDB(
                storePath: storePath,
                databasePath: databasePath,
                library: nil
            )
        } catch {
            throw ValidationError(
                "Failed to open IndexStore database: \(error.localizedDescription)")
        }

        if verbose {
            print("Successfully opened IndexStore database")
        }

        var symbolCount = 0
        var filteredCount = 0

        // Enumerate all symbols
        try indexStoreDB.forEachSymbolName { name in
            print(name)
        }
    }
}
