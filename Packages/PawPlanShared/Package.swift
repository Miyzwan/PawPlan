// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PawPlanShared",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "PawPlanShared",
            targets: ["PawPlanShared"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PawPlanShared",
            dependencies: [],
            path: "Sources/PawPlanShared"
        ),
        .testTarget(
            name: "PawPlanSharedTests",
            dependencies: ["PawPlanShared"],
            path: "Tests/PawPlanSharedTests"
        )
    ]
)
