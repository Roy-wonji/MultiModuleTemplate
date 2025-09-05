import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: "UseCase",
  bundleId: .appBundleID(name: ".UseCase"),
  product: .staticFramework,
  settings:  .settings(),
  dependencies: [
    .Data(implements: .Repository),
//    .SPM.composableArchitecture,
    .Domain(implements: .DomainInterface)
  ],
  sources: ["Sources/**"]
)
