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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.1"),
  ],
  targets: [
    .target(
      name: "NewAndNowFeature",
      dependencies: [
        "ApiClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels"
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels"
      ]
    ),
    .target(
      name: "ApiClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "SharedModels"
      ],
      resources: [.process("Resources")]
    ),
    .target(name: "ViewHelper"),
    .target(name: "SharedModels")
  ]
)
