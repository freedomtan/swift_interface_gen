// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftInterfaceGen",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "swift-interface-gen", targets: ["SwiftInterfaceGen"])
    ],
    targets: [
        .executableTarget(
            name: "SwiftInterfaceGen",
            dependencies: []
        ),
        .testTarget(
            name: "SwiftInterfaceGenTests",
            dependencies: ["SwiftInterfaceGen"]
        )
    ]
)
