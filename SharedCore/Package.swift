// swift-tools-version: 6.2
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SharedCore",
            targets: ["SharedCore"]
        )
    ],
    targets: [
        .target(
            name: "SharedCore",
            dependencies: []
        )
    ]
)

