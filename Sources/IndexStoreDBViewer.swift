import ArgumentParser
import Foundation
import IndexStoreDB

@main
struct IndexStoreDBViewer: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "view-indexdb",
        abstract: "A tool for viewing IndexStore database contents",
        subcommands: [ListSymbols.self, FindSymbol.self]
    )
}

struct ListSymbols: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-symbols",
        abstract: "List all symbols in the IndexStore database"
    )

    @Option(name: .shortAndLong, help: "name of the symbol")
    var name: String = "TodoListManager"

    @Option(name: .shortAndLong, help: "Path to the IndexStore")
    var storePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore database")
    var databasePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore library")
    var libraryPath: String = default_library_path

    func run() throws {
       let indexStoreDB = try openIndexStoreDB(storePath: storePath, databasePath: databasePath, libraryPath: libraryPath)

        // First, get all symbol names with their USRs
        print("Enumerating all symbols with USR and file info...")
        var symbolCount = 0
        indexStoreDB.forEachSymbolName { name in
            symbolCount += 1
            return true
        }

        print("Total symbols found: \(symbolCount)")
    }
}

let default_library_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

struct FindSymbol: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "find-symbol",
        abstract: "Find the symbol based on the name"
    )

    @Option(name: .shortAndLong, help: "symbol name")
    var name: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore")
    var storePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore database")
    var databasePath: String

    @Option(name: .shortAndLong, help: "Path to the IndexStore library")
    var libraryPath: String = default_library_path

    func run() throws {
        print("Opening IndexStore database at: \(databasePath)")

       let indexStoreDB = try openIndexStoreDB(storePath: storePath, databasePath: databasePath, libraryPath: libraryPath)

        if let symbolDetail = findSymbolDetails(symbolName: name, in: indexStoreDB) {
            symbolDetail.printDetails()
        } else {
            print("can't find the symbol with name: \(name)")
        }
    }

}

struct SymbolDetails {
    let name: String
    let usr: String
    let location: SymbolLocation
    let roles: SymbolRole
    let symbolProvider: SymbolProviderKind
    let relations: [SymbolRelation]

    func printDetails() {
        print("Symbol: \(name)")
        print("  USR: \(usr)")
        print("  Location: \(location)")
        print("  Role: \(roles)")
        print("  Provider: \(symbolProvider)")
        for relation in relations {
            print("  Relation: \(relation)")
        }
    }
}

func openIndexStoreDB(storePath: String, databasePath: String, libraryPath: String) throws -> IndexStoreDB{
     // Verify database path exists
        guard FileManager.default.fileExists(atPath: databasePath) else {
            throw ValidationError("IndexStore database not found at path: \(databasePath)")
        }

        // Create IndexStore library
        let library: IndexStoreLibrary
        do {
            library = try IndexStoreLibrary(dylibPath: libraryPath)
        } catch {
            throw ValidationError(
                "Failed to load IndexStore library: \(error.localizedDescription)")
        }

        // Open the IndexStore database
        let indexStoreDB: IndexStoreDB
        do {
            indexStoreDB = try IndexStoreDB(
                storePath: storePath,
                databasePath: databasePath,
                library: library,
                waitUntilDoneInitializing: true
            )
        } catch {
            throw ValidationError(
                "Failed to open IndexStore database: \(error.localizedDescription)")
        }

        print("Successfully opened IndexStore database")
        return indexStoreDB
}

func findSymbolDetails(symbolName: String, in indexStoreDB: IndexStoreDB) -> SymbolDetails? {
    var symbolDetails: SymbolDetails? = nil

    indexStoreDB.forEachCanonicalSymbolOccurrence(byName: symbolName) { occurrence in
        let usr = occurrence.symbol.usr
        let location = occurrence.location
        let roles = occurrence.roles
        let symbolProvider = occurrence.symbolProvider
        let relations = Array(occurrence.relations)

        symbolDetails = SymbolDetails(
            name: symbolName,
            usr: usr,
            location: location,
            roles: roles,
            symbolProvider: symbolProvider,
            relations: relations
        )

        return true  // Only need the first canonical occurrence
    }

    return symbolDetails
}
