import ArgumentParser
import Foundation
import IndexStoreDB

@main
struct IndexStoreDBViewer: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "indexstore-db-viewer",
        abstract: "A tool for viewing IndexStore database contents",
        subcommands: [ListSymbols.self]
    )
}

struct ListSymbols: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list-symbols",
        abstract: "List all symbols in the IndexStore database"
    )
    
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
            indexStoreDB = try IndexStoreDB(storePath: databasePath)
        } catch {
            throw ValidationError("Failed to open IndexStore database: \(error.localizedDescription)")
        }
        
        if verbose {
            print("Successfully opened IndexStore database")
        }
        
        var symbolCount = 0
        var filteredCount = 0
        
        // Enumerate all symbols
        try indexStoreDB.forEachSymbols { symbol in
            symbolCount += 1
            
            // Apply filter if specified
            if let filterPattern = filter {
                if !symbol.name.contains(filterPattern) {
                    return true // Continue enumeration
                }
            }
            
            filteredCount += 1
            
            // Check limit
            if let resultLimit = limit, filteredCount > resultLimit {
                return false // Stop enumeration
            }
            
            // Output symbol information
            if details {
                print("Symbol: \(symbol.name)")
                print("  Kind: \(symbol.kind)")
                print("  USR: \(symbol.usr)")
                if let codegen = symbol.codegen {
                    print("  Codegen: \(codegen)")
                }
                print("---")
            } else {
                print(symbol.name)
            }
            
            return true // Continue enumeration
        }
        
        if verbose {
            print("\nTotal symbols in database: \(symbolCount)")
            if filter != nil {
                print("Symbols matching filter: \(filteredCount)")
            }
        }
    }
}
