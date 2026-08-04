// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IONHealthFitnessLib",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "IONHealthFitnessLib",
            type: .dynamic,
            targets: ["IONHealthFitnessLib"]
        ),
    ],
    targets: [
        .target(
            name: "IONHealthFitnessLib",
            dependencies: [],
            resources: [
                .process("LocalStorage/BackgroundModel.xcdatamodeld"),
            ]
        ),
        .testTarget(
            name: "IONHealthFitnessLibTests",
            dependencies: ["IONHealthFitnessLib"]
        ),
    ]
)
