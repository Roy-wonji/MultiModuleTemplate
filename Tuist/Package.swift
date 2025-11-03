// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
  productTypes: [:]
)
#endif

let package = Package(
  name: "MultiModuleTemplate",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.18.0"),
    .package(url: "https://github.com/johnpatrickmorgan/TCACoordinators.git", exact: "0.11.1"),
    .package(url: "https://github.com/Roy-wonji/WeaveDI.git", from: "3.3.1")
  ]
)
