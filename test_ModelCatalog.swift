import ModelCatalog
import Foundation

print("Starting test")
print("LocalCatalogClient: \(LocalCatalogClient.self)")
print("CatalogResource: \((any CatalogResource).self)")
print("CatalogAsset: \(CatalogAsset<Any, Any>.self)")
print("ResourceBundleIdentifier: \(ResourceBundleIdentifier<String>.self)")
print("Types verified")
