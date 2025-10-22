import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "DataInterface",
  bundleId: .appBundleID(name: ".DataInterface"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Data(implements: .Model)
  ],
  sources: ["Sources/**"]
)
