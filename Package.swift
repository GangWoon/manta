// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "manta",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "AppFeature",
      targets: [
        "NewAndNowFeature",
        "WebtoonDetailFeature"
      ]
    ),
    .library(
      name: "WebtoonDetail",
      targets: ["WebtoonDetailFeature"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.1"),
    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "1.3.2")
  ],
  targets: [
    .target(
      name: "NewAndNowFeature",
      dependencies: [
        "ApiClient",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "WebtoonDetailFeature",
        "SharedModels",
        "ViewHelper"
      ]
    ),
    .target(
      name: "WebtoonDetailFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "SharedModels",
        "ViewHelper"
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
    .target(
      name: "ViewHelper",
      dependencies: [
        .product(name: "Perception", package: "swift-perception")
      ]
    ),
    .target(name: "SharedModels")
  ]
)
