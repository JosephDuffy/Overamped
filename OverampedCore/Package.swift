// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OverampedCore",
    products: [
        .library(name: "OverampedCore", targets: ["OverampedCore"]),
    ],
    targets: [
        .target(name: "OverampedCore"),
        .testTarget(name: "OverampedCoreTests", dependencies: ["OverampedCore"]),
    ]
)
