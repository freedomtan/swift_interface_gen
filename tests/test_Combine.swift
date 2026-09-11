import Combine
import Foundation

print("Starting Combine test")
print("AnyCancellable: \(AnyCancellable.self)")
print("AnyPublisher: \(AnyPublisher<Int, Never>.self)")
print("AnySubscriber: \(AnySubscriber<Int, Never>.self)")
print("Just: \(Just<Int>.self)")
print("Empty: \(Empty<Int, Never>.self)")
print("Fail: \(Fail<Int, Never>.self)")
print("Publisher: \((any Publisher).self)")
print("Subscriber: \((any Subscriber).self)")
print("Subscription: \((any Subscription).self)")
print("Types verified")
