// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "SwiftObfuscator",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftObfuscatorEngine",
            targets: ["SwiftObfuscator"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftObfuscator",
            path: "Sources"),
        .testTarget(
            name: "SwiftObfuscatorTests",
            dependencies: ["SwiftObfuscator"],
            path: "Tests")
    ]
)
