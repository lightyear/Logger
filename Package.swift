// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [.macOS(.v10_12), .iOS(.v10)],
    products: [
        .library(name: "Logger", targets: ["Logger"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble", from: "10.0.0")
    ],
    targets: [
        .target(name: "Logger"),
        .testTarget(name: "LoggerTests", dependencies: ["Logger", "Nimble"])
    ]
)
