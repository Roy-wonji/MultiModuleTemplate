//
//  Project+Environment.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import Foundation
import ProjectDescription

public extension Project {
  enum Environment {
    // 환경변수에서 프로젝트 이름을 읽어오고, 없으면 기본값 사용
    private static let projectName: String = {
      if let envProjectName = ProcessInfo.processInfo.environment["PROJECT_NAME"] {
        print("🔍 [Project+Environment] PROJECT_NAME 환경변수 발견: \(envProjectName)")
        return envProjectName
      } else {
        print("🎵 [Project+Environment] ProjectConfig에서 프로젝트 이름 사용: \(ProjectConfig.projectName)")
        return ProjectConfig.projectName
      }
    }()
    // 🎯 모든 설정을 ProjectConfig에서 가져오거나 환경변수 우선 적용
    private static let bundleIdPrefix = ProcessInfo.processInfo.environment["BUNDLE_ID_PREFIX"] ?? ProjectConfig.bundleIdPrefix
    private static let teamId = ProcessInfo.processInfo.environment["TEAM_ID"] ?? ProjectConfig.teamId

    public static let appName = projectName
    public static let appStageName = "\(projectName)-Stage"
    public static let appProdName = "\(projectName)-Prod"
    public static let appDevName = "\(projectName)-Dev"
    public static let deploymentTarget = ProjectConfig.deploymentTarget
    public static let deploymentDestination = ProjectConfig.deploymentDestination
    public static let organizationTeamId = teamId
    public static let bundlePrefix = bundleIdPrefix
    public static let appVersion = ProjectConfig.appVersion
    public static let mainBundleId = bundleIdPrefix
  }
}
