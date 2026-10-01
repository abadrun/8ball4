// swift-tools-version:5.9
//
// MR. SPICY — reusable customization layer for an authorized 8 Ball Pool host.
// Requires a macOS/Xcode toolchain (UIKit). Not buildable on Linux.
//
import PackageDescription

let package = Package(
    name: "MrSpicyUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MrSpicyUI", targets: ["MrSpicyUI"]),
        .library(name: "MrSpicyHostBridge", targets: ["MrSpicyHostBridge"]),
    ],
    targets: [
        .target(
            name: "MrSpicyUI",
            path: "mr-spicy-ui",
            exclude: ["Tests"],
            sources: ["Sources"],
            resources: [
                .process("Localization"),
                .process("Resources"),
            ]
        ),
        .target(
            name: "MrSpicyHostBridge",
            dependencies: ["MrSpicyUI"],
            path: "integration/host"
        ),
        .testTarget(
            name: "MrSpicyUITests",
            dependencies: ["MrSpicyUI"],
            path: "mr-spicy-ui/Tests"
        ),
    ]
)
