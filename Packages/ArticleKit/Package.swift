// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ArticleKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ArticleKit",
            targets: ["ArticleKit"]
        )
    ],
    targets: [
        .target(
            name: "ArticleKit",
            path: "Sources"
        ),
        .testTarget(
            name: "ArticleKitTests",
            dependencies: ["ArticleKit"],
            path: "Tests"
        )
    ]
)
