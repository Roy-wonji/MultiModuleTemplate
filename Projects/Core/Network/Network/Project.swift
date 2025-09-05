import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Network",
  bundleId: .appBundleID(name: ".Network"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Network(implements: .Service)
  ],
  sources: ["Sources/**"]
)
