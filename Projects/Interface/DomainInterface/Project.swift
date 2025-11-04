import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "DomainInterface",
  bundleId: .appBundleID(name: ".DomainInterface"),
  product: .framework,
  settings:  .settings(),
  dependencies: [
    .Domain(implements: .Entity)
  ],
  sources: ["Sources/**"]
)
