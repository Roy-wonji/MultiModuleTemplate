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
    // 환경변수에서 프로젝트 이름을 읽어오고, 없으면 기본값 사용
    private static let projectName = ProcessInfo.processInfo.environment["PROJECT_NAME"] ?? "MultiModuleTemplate"
    private static let bundleIdPrefix = ProcessInfo.processInfo.environment["BUNDLE_ID_PREFIX"] ?? "io.Roy.Module"
    private static let teamId = ProcessInfo.processInfo.environment["TEAM_ID"] ?? "N94CS4N6VR"

    public static let appName = projectName
    public static let appStageName = "\(projectName)-Stage"
    public static let appProdName = "\(projectName)-Prod"
    public static let appDevName = "\(projectName)-Dev"
    public static let deploymentTarget : ProjectDescription.DeploymentTargets = .iOS("17.0")
    public static let deploymentDestination: ProjectDescription.Destinations = [.iPhone]
    public static let organizationTeamId = teamId
    public static let bundlePrefix = bundleIdPrefix
    public static let appVersion = "1.0.0"
    public static let mainBundleId = bundleIdPrefix
  }
}
