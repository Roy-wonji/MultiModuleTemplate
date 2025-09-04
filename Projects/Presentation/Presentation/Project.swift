import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Presentation",
  bundleId: .appBundleID(name: ".Presentation"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Core(implements: .Core),
    .Shared(implements: .Shared),
  ],
  sources: ["Sources/**"]
)
