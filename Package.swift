// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "manta",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "NewAndNowFeature",
      targets: ["NewAndNowFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", branch: "main")
  ],
  targets: [
    .target(
      name: "NewAndNowFeature",
      dependencies: [
        "ApiClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .target(
      name: "ApiClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ],
      resources: [.process("Resources")]
    )
  ]
)
