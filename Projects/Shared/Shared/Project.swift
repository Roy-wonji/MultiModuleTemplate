import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "Shared",
  bundleId: .appBundleID(name: ".Shared"),
  product: .framework,
  settings:  .settings(),
  dependencies: [
    .Shared(implements: .ThirdParty),
    .Shared(implements: .DesignSystem),
    .Shared(implements: .Utill),
  ],
  sources: ["Sources/**"]
)
