import UnifiedAssetFramework
import Foundation

print("Starting UnifiedAssetFramework test")

// Verify ObjC class metatypes are accessible through Swift bridging
print("UAFAppleIntelligenceReporting: \(UAFAppleIntelligenceReporting.self)")
print("UAFAsset: \(UAFAsset.self)")
print("UAFAssetSet: \(UAFAssetSet.self)")
print("UAFAssetSetConsistencyToken: \(UAFAssetSetConsistencyToken.self)")
print("UAFAssetSetManager: \(UAFAssetSetManager.self)")
print("UAFAssetSetSubscription: \(UAFAssetSetSubscription.self)")
print("UAFAssetSetSubscriptionManager: \(UAFAssetSetSubscriptionManager.self)")
print("UAFAssetConfiguration: \(UAFAssetConfiguration.self)")
print("UAFAssetSetConfiguration: \(UAFAssetSetConfiguration.self)")
print("UAFAssetInfoCache: \(UAFAssetInfoCache.self)")

print("Types verified")
