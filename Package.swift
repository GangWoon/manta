// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "manta",
  platforms: [.iOS(.v16)],
  products: [
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "NewAndNowFeature",
      targets: ["NewAndNowFeature"]
    ),
    .library(
      name: "WebtoonDetail",
      targets: ["WebtoonDetailFeature"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.11.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.1"),
    .package(url: "https://github.com/pointfreeco/swift-perception.git", from: "1.3.2"),
    .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", from: "1.5.0"),
    .package(url: "https://github.com/stephencelis/SQLite.swift.git", branch: "master")
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        "NewAndNowFeature",
        "UserNotificationClient"
      ]
    ),
    .target(
      name: "NewAndNowFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Shimmer", package: "swiftui-shimmer"),
        "WebtoonDetailFeature",
        "ApiClient",
        "LocalDatabaseClient",
        "UserNotificationClient",
        "SharedModels",
        "ViewHelper"
      ]
    ),
    .target(
      name: "WebtoonDetailFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Shimmer", package: "swiftui-shimmer"),
        "SharedModels",
        "ViewHelper"
      ]
    ),
    .target(
      name: "ApiClient",
      dependencies: [
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        "SharedModels"
      ],
      resources: [.process("Resources")]
    ),
    .target(
      name: "LocalDatabaseClient",
      dependencies: [
        .product(name: "SQLite", package: "sqlite.swift"),
        .product(name: "DependenciesMacros", package: "swift-dependencies")
      ]
    ),
    .target(
      name: "UserNotificationClient",
      dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture")]
    ),
    .target(
      name: "ViewHelper",
      dependencies: [
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "Shimmer", package: "swiftui-shimmer")
      ]
    ),
    .target(name: "SharedModels")
  ]
)
