//
//  Extension+TargetDependencySPM.swift
//  DependencyPackagePlugin
//
//  Created by 서원지 on 4/19/24.
//

import ProjectDescription

public extension TargetDependency.SPM {
  static let asyncMoya = TargetDependency.external(name: "AsyncMoya", condition: .none)
  static let composableArchitecture = TargetDependency.external(name: "ComposableArchitecture", condition: .none)
  static let tcaCoordinator = TargetDependency.external(name: "TCACoordinators", condition: .none)
  static let weaveDI = TargetDependency.external(name: "WeaveDI", condition: .none)
}
