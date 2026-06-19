import ModelCatalog
import Foundation

print("Starting test")
print("LocalCatalogClient: \(LocalCatalogClient.self)")
print("CatalogResource: \((any CatalogResource).self)")
print("CatalogAsset: \(CatalogAsset<AppleDeviceTrackingAssetMetadata, AppleDeviceTrackingAssetContents>.self)")
print("ResourceBundleIdentifier: \(ResourceBundleIdentifier<String>.self)")
print("Types verified")
