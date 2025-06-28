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
    var libraryPath: String =
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

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

        // First, get all symbol names with their USRs
        print("Enumerating all symbols with USR and file info...")
        var symbolCount = 0
        indexStoreDB.forEachSymbolName { name in
            print(name)
            symbolCount += 1
            return true
        }

        var symbolUSRs: [String: String] = [:]  // name -> USR mapping
        // Get canonical symbol occurrence to find USR
        indexStoreDB.forEachCanonicalSymbolOccurrence(byName: "BazelView") { occurrence in
            let usr = occurrence.symbol.usr
            let loc = occurrence.location
            let role = occurrence.roles
            let provider = occurrence.symbolProvider
            symbolUSRs["BazelView"] = usr
            print("Symbol: BazelView")
            print("  USR: \(usr)")
            print("  Location: \(loc)")
            print("  Role: \(role)")
            print("  Provider: \(provider)")
            for relation in occurrence.relations {
                print("  Relation: \(relation)")
            }
            return false  // Only need the first canonical occurrence
        }

        print("Total symbols found: \(symbolCount)")
    }
}
