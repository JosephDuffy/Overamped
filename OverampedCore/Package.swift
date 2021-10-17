// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OverampedCore",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "OverampedCore", targets: ["OverampedCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/Persist.git", .branch("swiftui-support")),
    ],
    targets: [
        .target(name: "OverampedCore", dependencies: ["Persist"]),
        .testTarget(name: "OverampedCoreTests", dependencies: ["OverampedCore"]),
    ]
)
