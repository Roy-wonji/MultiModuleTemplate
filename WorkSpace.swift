//
//  WorkSpace.swift
//  Manifests
//
//  Created by 서원지 on 6/7/24.
//

import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let workspaceName: String = {
    if let projectName = ProcessInfo.processInfo.environment["PROJECT_NAME"] {
        print("🔍 PROJECT_NAME 환경변수 발견: \(projectName)")
        return projectName
    } else {
        print("🔍 PROJECT_NAME 환경변수 없음, 기본값 사용")
        return "MultiModuleTemplate"
    }
}()

let workspace = Workspace(
name: workspaceName,
projects: [
    "Projects/**"
])
