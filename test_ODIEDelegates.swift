import Foundation
import ODIEDelegates
import ODIE

print("Starting ODIEDelegates test")
print("AneDelegate: \(AneDelegate.self)")
print("AneDelegate.Error: \(AneDelegate.Error.self)")

// Verify we can instantiate AneDelegate and handle its Error enum cases
let errorCase = AneDelegate.Error.modelLoadFailed("test error")
print("Error case created: \(errorCase)")

print("ODIEDelegates types verified successfully!")
