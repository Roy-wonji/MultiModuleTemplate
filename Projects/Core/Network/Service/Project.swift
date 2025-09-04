import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Service",
  bundleId: .appBundleID(name: ".Service"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [

  ],
  sources: ["Sources/**"]
)
