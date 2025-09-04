import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Core",
  bundleId: .appBundleID(name: ".Core"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .UseCase),
    .Network(implements: .Network)
  ],
  sources: ["Sources/**"]
)
