import ModelCatalog
import Foundation

@main
struct TestMain {
    static func main() {
        runTest()
    }
}

func runTest() {
    print("Starting ModelCatalog test...")
    let client = CatalogClient()
    print("Successfully instantiated CatalogClient")
    
    do {
        let resources = try client.resources()
        print("Fetched \(resources.count) resources")
        for resource in resources {
            print(" - Resource ID: \(resource.id)")
        }
    } catch {
        print("Failed to fetch resources: \(error)")
    }
}
