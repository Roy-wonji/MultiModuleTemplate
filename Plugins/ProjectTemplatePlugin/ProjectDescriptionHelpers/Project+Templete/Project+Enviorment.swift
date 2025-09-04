//
//  Project+Enviorment.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import Foundation
import ProjectDescription

public extension Project {
  enum Environment {
    public static let appName = "MultiModuleTemplate"
    public static let appStageName = "MultiModuleTemplate-Stage"
    public static let appProdName = "MultiModuleTemplate-Prod"
    public static let appDevName = "MultiModuleTemplate-Dev"
    public static let deploymentTarget : ProjectDescription.DeploymentTargets = .iOS("17.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let organizationTeamId = "N94CS4N6VR"
    public static let bundlePrefix = "io.Roy.Module"
    public static let appVersion = "1.0.0"
    public static let mainBundleId = "io.Roy.Module"
  }
}
