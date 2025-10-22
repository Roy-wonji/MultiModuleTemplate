//
//  tuisttool.swift
//

import Foundation

@discardableResult
func run(_ command: String, arguments: [String] = []) -> Int32 {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = FileHandle.standardOutput
  process.standardError = FileHandle.standardError
  do {
    try process.run()
    process.waitUntilExit()
    return process.terminationStatus
  } catch {
    print("❌ 실행 실패: \(error)")
    return -1
  }
}

func runCapture(_ command: String, arguments: [String] = []) throws -> String {
  let process = Process()
  let pipe = Pipe()
  process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  process.arguments = [command] + arguments
  process.standardOutput = pipe
  try process.run()
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
}

func prompt(_ message: String) -> String {
  print("\(message): ", terminator: "")
  return readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

// MARK: - Tuist 명령어
func generate() { setenv("TUIST_ROOT_DIR", FileManager.default.currentDirectoryPath, 1); run("tuist", arguments: ["generate"]) }

// MARK: - 새 프로젝트 생성
func newProject() {
    print("\n🚀 새 프로젝트 생성을 시작합니다.")

    let projectName = prompt("프로젝트 이름을 입력하세요")
    guard !projectName.isEmpty else {
        print("❌ 프로젝트 이름은 필수입니다.")
        return
    }

    let bundleIdPrefix = prompt("번들 ID 접두사를 입력하세요 (기본값: io.Roy.Module)")
    let finalBundleId = bundleIdPrefix.isEmpty ? "io.Roy.Module" : bundleIdPrefix

    let teamId = prompt("팀 ID를 입력하세요 (기본값: N94CS4N6VR)")
    let finalTeamId = teamId.isEmpty ? "N94CS4N6VR" : teamId

    print("\n📋 설정 정보:")
    print("📱 프로젝트명: \(projectName)")
    print("📦 번들 ID 접두사: \(finalBundleId)")
    print("👥 팀 ID: \(finalTeamId)")

    let confirm = prompt("\n위 설정으로 프로젝트를 생성하시겠습니까? (y/N)")
    guard confirm.lowercased() == "y" else {
        print("❌ 프로젝트 생성이 취소되었습니다.")
        return
    }

    generateProjectWithSettings(
        name: projectName,
        bundleIdPrefix: finalBundleId,
        teamId: finalTeamId
    )
}

func generateProjectWithArgs() {
    let args = Array(CommandLine.arguments.dropFirst(2)) // command와 하위 명령 제외

    guard args.count >= 1 else {
        print("사용법: ./tuisttool generate --name <프로젝트명> [--bundle-id <번들ID>] [--team-id <팀ID>]")
        return
    }

    var projectName = ""
    var bundleIdPrefix = "io.Roy.Module"
    var teamId = "N94CS4N6VR"

    var i = 0
    while i < args.count {
        switch args[i] {
        case "--name", "-n":
            if i + 1 < args.count {
                projectName = args[i + 1]
                i += 1
            }
        case "--bundle-id", "-b":
            if i + 1 < args.count {
                bundleIdPrefix = args[i + 1]
                i += 1
            }
        case "--team-id", "-t":
            if i + 1 < args.count {
                teamId = args[i + 1]
                i += 1
            }
        default:
            if projectName.isEmpty {
                projectName = args[i]
            }
        }
        i += 1
    }

    guard !projectName.isEmpty else {
        print("❌ 프로젝트 이름은 필수입니다.")
        print("사용법: ./tuisttool newproject <프로젝트명> [--bundle-id <번들ID>] [--team-id <팀ID>]")
        return
    }

    generateProjectWithSettings(
        name: projectName,
        bundleIdPrefix: bundleIdPrefix,
        teamId: teamId
    )
}

func generateProjectWithSettings(name: String, bundleIdPrefix: String, teamId: String) {
    print("\n⚙️ 환경변수 설정 중...")
    setenv("PROJECT_NAME", name, 1)
    setenv("BUNDLE_ID_PREFIX", bundleIdPrefix, 1)
    setenv("TEAM_ID", teamId, 1)

    print("🔧 Tuist 프로젝트 생성 중...")
    let result = run("tuist", arguments: ["generate"])

    if result == 0 {
        print("\n✅ 프로젝트 '\(name)'이 성공적으로 생성되었습니다!")
        print("💡 .xcworkspace 파일을 열어서 작업을 시작하세요.")

        // 생성된 workspace 파일 찾기
        let workspaceName = "\(name).xcworkspace"
        if FileManager.default.fileExists(atPath: workspaceName) {
            print("🚀 자동으로 Xcode에서 열까요? (y/N)")
            let openXcode = prompt("").lowercased()
            if openXcode == "y" {
                run("open", arguments: [workspaceName])
            }
        }
    } else {
        print("❌ 프로젝트 생성에 실패했습니다.")
    }
}

func fetch()    { run("tuist", arguments: ["fetch"]) }
func build()    { clean(); fetch(); generate() }
func edit()     { run("tuist", arguments: ["edit"]) }
func clean()    { run("tuist", arguments: ["clean"]) }
func install()  { run("tuist", arguments: ["install"]) }
func cache()    { run("tuist", arguments: ["cache", "DDDAttendance"]) }
func reset() {
  print("🧹 캐시 및 로컬 빌드 정리 중...")
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Caches/Tuist"])
  run("rm", arguments: ["-rf", "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"])
  run("rm", arguments: ["-rf", ".tuist", ".build"])
  fetch(); generate()
}

// MARK: - Parsers (Modules.swift / SPM 목록에서 자동 파싱)
func availableModuleTypes() -> [String] {
  let filePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else { return [] }
  let pattern = "enum (\\w+):"
  let regex = try? NSRegularExpression(pattern: pattern)
  let matches = regex?.matches(in: content, range: NSRange(content.startIndex..., in: content)) ?? []
  return matches.compactMap {
    guard let range = Range($0.range(at: 1), in: content) else { return nil }
    let name = String(content[range])
    return name.hasSuffix("s") ? String(name.dropLast()) : name
  }
}

func parseModulesFromFile(keyword: String) -> [String] {
  let filePath = "Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("❗️ Modules.swift 파일을 읽을 수 없습니다.")
    return []
  }
  let pattern = "enum \(keyword).*?\\{([\\s\\S]*?)\\}"
  guard let regex = try? NSRegularExpression(pattern: pattern),
        let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
        let innerRange = Range(match.range(at: 1), in: content) else {
    return []
  }
  let innerContent = content[innerRange]
  let casePattern = "case (\\w+)"
  let caseRegex = try? NSRegularExpression(pattern: casePattern)
  let lines = innerContent.components(separatedBy: .newlines)
  return lines.compactMap { line in
    guard let match = caseRegex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
          let range = Range(match.range(at: 1), in: line) else { return nil }
    return String(line[range])
  }
}

func parseSPMLibraries() -> [String] {
  let filePath = "Plugins/DependencyPackagePlugin/ProjectDescriptionHelpers/DependencyPackage/Extension+TargetDependencySPM.swift"
  guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else {
    print("❗️ SPM 목록 파일을 읽을 수 없습니다.")
    return []
  }
  let pattern = "static let (\\w+)"
  let regex = try? NSRegularExpression(pattern: pattern)
  let lines = content.components(separatedBy: .newlines)
  return lines.compactMap { line in
    guard let match = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
          let range = Range(match.range(at: 1), in: line) else { return nil }
    return String(line[range])
  }
}

// MARK: - registerModule
func registerModule() {
  print("\n🚀 새 모듈 등록을 시작합니다.")
  let moduleInput = prompt("모듈 이름을 입력하세요 (예: Presentation_Home, Shared_Logger, Domain_Auth 등)")
  let moduleName = prompt("생성할 모듈 이름을 입력하세요 (예: Home)")

  var dependencies: [String] = []
  while true {
    print("의존성 종류 선택:")
    print("  1) SPM")
    print("  2) 내부 모듈")
    print("  3) 종료")
    let choice = prompt("번호 선택")
    if choice == "3" { break }

    if choice == "1" {
      let options = parseSPMLibraries()
      for (i, lib) in options.enumerated() { print("  \(i + 1). \(lib)") }
      let selected = Int(prompt("선택할 번호 입력")) ?? 0
      if (1...options.count).contains(selected) {
        dependencies.append(".SPM.\(options[selected - 1])")
      }
    } else if choice == "2" {
      let types = availableModuleTypes()
      for (i, type) in types.enumerated() { print("  \(i + 1). \(type)") }
      let typeIndex = Int(prompt("의존할 모듈 타입 번호 입력")) ?? 0
      guard (1...types.count).contains(typeIndex) else { continue }
      let keyword = types[typeIndex - 1]

      let options = parseModulesFromFile(keyword: keyword)
      for (i, opt) in options.enumerated() { print("  \(i + 1). \(opt)") }
      let moduleIndex = Int(prompt("선택할 번호 입력")) ?? 0
      if (1...options.count).contains(moduleIndex) {
        dependencies.append(".\(keyword)(implements: .\(options[moduleIndex - 1]))")
      }
    }
  }

  let author = (try? runCapture("git", arguments: ["config", "--get", "user.name"])) ?? "Unknown"
  let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
  let currentDate = formatter.string(from: Date())

  let layer: String = {
    let lower = moduleInput.lowercased()
    if lower.starts(with: "presentation") { return "Presentation" }
    else if lower.starts(with: "shared")   { return "Shared" }
    else if lower.starts(with: "domain")   { return "Core/Domain" }
    else if lower.starts(with: "interface"){ return "Core/Interface" }
    else if lower.starts(with: "network"){ return "Core/Network" }
    else if lower.starts(with: "data")     { return "Core/Data" }
    else { return "Core" }
  }()

  let result = run("tuist", arguments: [
    "scaffold", "Module",
    "--layer", layer,
    "--name", moduleName,
    "--author", author,
    "--current-date", currentDate
  ])

  if result == 0 {
    let projectFile = "Projects/\(layer)/\(moduleName)/Project.swift"
    if var content = try? String(contentsOfFile: projectFile, encoding: .utf8),
       let range = content.range(of: "dependencies: [") {
      let insertIndex = content.index(after: range.upperBound)
      let dependencyList = dependencies.map { "  \($0)" }.joined(separator: ",\n")
      content.insert(contentsOf: "\n\(dependencyList),", at: insertIndex)
      try? content.write(toFile: projectFile, atomically: true, encoding: .utf8)
      print("✅ 의존성 추가 완료:\n\(dependencyList)")
    }
    print("✅ 모듈 생성 완료: Projects/\(layer)/\(moduleName)")

    // ──────────────────────────────
    // ✅ Domain 모듈일 경우 Interface 폴더 생성 여부 확인
    if layer == "Core/Domain" {
      let askInterface = prompt("이 Domain 모듈에 Interface 폴더를 생성할까요? (y/N)").lowercased()
      if askInterface == "y" {
        let interfaceDir = "Projects/Core/Domain/\(moduleName)/Interface/Sources"
        let baseFilePath = "\(interfaceDir)/Base.swift"

        if !FileManager.default.fileExists(atPath: interfaceDir) {
          do {
            try FileManager.default.createDirectory(atPath: interfaceDir, withIntermediateDirectories: true, attributes: nil)
            print("📂 Interface 폴더 생성 → \(interfaceDir)")
          } catch {
            print("❌ Interface 폴더 생성 실패: \(error)")
          }
        } else {
          print("ℹ️ Interface 폴더 이미 존재 → 건너뜀")
        }

        // Base.swift 생성(없으면)
        if !FileManager.default.fileExists(atPath: baseFilePath) {
          let baseTemplate = """
          //
          //  Base.swift
          //  Domain.\(moduleName).Interface
          //
          //  Created by \(author) on \(currentDate).
          //
          
          import Foundation
          
          public protocol \(moduleName)Interface {
              // TODO: 정의 추가
          }
          """
          do {
            try baseTemplate.write(toFile: baseFilePath, atomically: true, encoding: .utf8)
            print("✅ Base.swift 생성 → \(baseFilePath)")
          } catch {
            print("❌ Base.swift 생성 실패: \(error)")
          }
        } else {
          print("ℹ️ Base.swift 이미 존재 → 건너뜀")
        }
      }
    }
  } else {
    print("❌ 모듈 생성 실패")
  }
}

// MARK: - Entrypoint
enum Command: String {
  case edit, generate, fetch, build, clean, install, cache, reset, moduleinit, newproject
}

let args = CommandLine.arguments.dropFirst()
guard let cmd = args.first, let command = Command(rawValue: cmd) else {
  print("""
    사용법:
      ./tuisttool generate
      ./tuisttool build
      ./tuisttool cache
      ./tuisttool clean
      ./tuisttool reset
      ./tuisttool moduleinit
      ./tuisttool newproject [<프로젝트명>] [--bundle-id <번들ID>] [--team-id <팀ID>]

    예시:
      ./tuisttool newproject                          # 대화형으로 입력
      ./tuisttool newproject MyAwesomeApp             # 간단한 사용법
      ./tuisttool newproject MyApp --bundle-id com.company.app --team-id ABC123DEF
    """)
  exit(1)
}

switch command {
  case .edit:       edit()
  case .generate:   generate()
  case .fetch:      fetch()
  case .build:      build()
  case .clean:      clean()
  case .install:    install()
  case .cache:      cache()
  case .reset:      reset()
  case .moduleinit: registerModule()
  case .newproject:
    // 인자가 있으면 인자로 처리, 없으면 대화형으로 처리
    if CommandLine.arguments.count > 2 {
        generateProjectWithArgs()
    } else {
        newProject()
    }
}
