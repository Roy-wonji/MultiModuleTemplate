import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: Project.Environment.appName,
  bundleId: .mainBundleID(),
  product: .app,
  settings: .appMainSetting,
  scripts: [],
  dependencies: [
    .Shared(implements: .Shared),
    .Core(implements: .Core),
    .Presentation(implements: .Presentation),
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
//  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements"),
)

