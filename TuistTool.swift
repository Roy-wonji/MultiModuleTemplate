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
  case edit, generate, fetch, build, clean, install, cache, reset, moduleinit
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
}
