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
  targets: [
    .target(
      name: "NewAndNowFeature",
      dependencies: [
        "ApiClient"
      ]
    ),
    .target(
      name: "ApiClient",
      resources: [
        .process("Resources")
      ]
    )
  ]
)
