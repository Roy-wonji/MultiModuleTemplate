# MultiModuleTemplate

Tuist로 구성된 멀티 모듈 iOS 프로젝트 템플릿입니다.

> 🚀 **새 기능**: 이제 프로젝트 이름을 동적으로 설정할 수 있습니다! `./tuisttool newproject`로 원하는 이름의 프로젝트를 생성하세요.

## 프로젝트 구조

```
MultiModuleTemplate/
├── Workspace.swift
├── Tuist.swift
├── Projects/
│   ├── App/                  # 메인 애플리케이션
│   ├── Presentation/
│   │   └── Presentation/     # 화면 및 ViewModel 구성
│   ├── Core/
│   │   ├── Core/             # 핵심 공통 모듈
│   │   ├── Data/             # 데이터 계층
│   │   │   ├── API/          # API 정의 및 클라이언트
│   │   │   ├── Model/        # 데이터 모델
│   │   │   ├── Repository/   # Repository 구현체
│   │   │   └── Service/      # 데이터 서비스
│   │   ├── Domain/           # 도메인 계층
│   │   │   ├── Entity/       # 도메인 엔티티
│   │   │   ├── UseCase/      # 비즈니스 로직 UseCase
│   │   │   └── DomainInterface/ # 도메인 인터페이스
│   │   ├── Network/          # 네트워크 계층
│   │   │   ├── Network/      # 네트워크 기본 모듈
│   │   │   └── Service/      # 네트워크 서비스
│   │   └── ThirdParty/       # Core 레벨 외부 라이브러리
│   └── Shared/
│       ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트 등
│       ├── Shared/           # 공통 공유 모듈
│       ├── ThirdParty/       # 외부 라이브러리 래핑
│       └── Utill/            # 공통 유틸리티
├── Tuist/
│   ├── Package.swift
│   └── ProjectDescriptionHelpers/
└── Plugins/
```

## 🚀 빠른 시작

### 새 프로젝트 생성 (권장)

```bash
# 1. TuistTool 컴파일 (최초 1회만)
swiftc TuistTool.swift -o tuisttool

# 2. 새 프로젝트 생성 (대화형으로 이름 설정)
./tuisttool newproject
```

### 템플릿 그대로 사용

```bash
tuist up          # 개발환경 부트스트랩
tuist generate    # 프로젝트 생성
tuist build       # 빌드
tuist test        # 테스트
```

## 주요 모듈 설명

- **App**: 메인 애플리케이션 모듈
- **Presentation**: ViewController, ViewModel 등 UI 로직 담당
- **Core**
  - **Core**: 핵심 공통 기능 및 설정
  - **Data**: 데이터 계층 (Clean Architecture)
    - **API**: REST API 정의 및 클라이언트
    - **Model**: 데이터 전송 객체 (DTO)
    - **Repository**: Repository 패턴 구현체
    - **Service**: 데이터 처리 서비스
  - **Domain**: 도메인 계층 (Clean Architecture)
    - **Entity**: 도메인 엔티티 및 비즈니스 모델
    - **UseCase**: 비즈니스 로직 처리
    - **DomainInterface**: 도메인 인터페이스 정의
  - **Network**: 네트워크 통신 계층
    - **Network**: 네트워크 기본 설정 및 클라이언트
    - **Service**: 네트워크 서비스 구현체
  - **ThirdParty**: Core 레벨 외부 라이브러리
- **Shared**
  - **DesignSystem**: 공통 UI 컴포넌트, 폰트, 색상 등 디자인 자산
  - **Shared**: 공통 공유 모듈 및 기본 설정
  - **ThirdParty**: 외부 라이브러리 래핑 (TCA, Alamofire 등)
  - **Utill**: 날짜, 문자열, 로깅 등 공용 유틸리티

## 개발 환경

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Tuist 4.50+

## 사용 라이브러리

- **ComposableArchitecture**: 상태 관리
- **DiContainer**: 의존성 주입
- **SwiftLint**: 코드 스타일 체크

---

# 🛠️ TuistTool (커스텀 CLI)

프로젝트 전용 CLI 도구입니다. Tuist 명령을 래핑하고, 새 프로젝트 생성, 모듈 스캐폴딩 등을 지원합니다.

## 설치 및 사용법

```bash
# 컴파일
swiftc TuistTool.swift -o tuisttool

# 사용법
./tuisttool <command>
```

### 지원 명령어 요약

| Command       | 설명 |
|---------------|------|
| `newproject`  | **🚀 새 프로젝트 생성**: 프로젝트 이름을 동적으로 설정하여 새로운 프로젝트를 생성. 대화형 입력 또는 명령어 인자 지원. |
| `generate`    | `tuist generate` 실행. 내부적으로 `TUIST_ROOT_DIR` 환경변수를 현재 디렉토리로 설정합니다. |
| `fetch`       | `tuist fetch` 실행(SPM/패키지 재해석). |
| `build`       | **clean → fetch → generate** 순서로 실행(빠른 클린 빌드 워크플로우). |
| `clean`       | `tuist clean` 실행(Tuist 캐시/생성물 정리). |
| `edit`        | `tuist edit` 실행(Project.swift 편집용 Xcode 프로젝트 생성). |
| `install`     | `tuist install` 실행(프로젝트 정의에 필요한 플러그인/템플릿 설치). |
| `cache`       | `tuist cache DDDAttendance` 실행(지정 타깃을 프리빌드 캐시). 필요 시 대상 타깃으로 수정하세요. |
| `reset`       | **강력 클린**: Tuist 캐시, Xcode DerivedData, `.tuist`, `.build` 폴더 삭제 후 `fetch → generate` 재실행. |
| `moduleinit`  | **모듈 스캐폴딩 마법사**: 모듈 이름/의존성 입력을 받아 `tuist scaffold Module` 실행 및 `Project.swift`에 의존성 자동 삽입. Domain 모듈일 경우 Interface 폴더/템플릿 생성 옵션 제공. |

### 상세 동작

- **newproject**
  - 환경변수 `PROJECT_NAME`, `BUNDLE_ID_PREFIX`, `TEAM_ID`를 설정하고 `tuist generate`를 실행합니다.
  - 대화형 모드: 프로젝트 이름, 번들 ID 접두사, 팀 ID를 순차적으로 입력받습니다.
  - 명령어 인자 모드: `--name`, `--bundle-id`, `--team-id` 옵션으로 바로 설정 가능합니다.
  - 생성 완료 후 자동으로 Xcode 실행 옵션을 제공합니다.
- **generate**
  - `TUIST_ROOT_DIR`를 현재 경로로 설정 후 `tuist generate` 수행.
- **build**
  - 내부적으로 `clean → fetch → generate` 호출. CI 로컬 재현에 유용.
- **reset**
  - 아래 경로를 삭제합니다.
    - `~/Library/Caches/Tuist`
    - `~/Library/Developer/Xcode/DerivedData`
    - 프로젝트 루트의 `.tuist`, `.build`
  - 이후 `fetch`, `generate`를 순차 실행.
- **moduleinit**
  - `Plugins/DependencyPlugin/ProjectDescriptionHelpers/TargetDependency+Module/Modules.swift`에서 **모듈 타입** 및 **케이스 목록**을 파싱합니다.
  - `Plugins/DependencyPackagePlugin/ProjectDescriptionHelpers/DependencyPackage/Extension+TargetDependencySPM.swift`에서 **SPM 의존성 목록**을 파싱합니다.
  - 입력 받은 의존성들을 `Projects/<Layer>/<ModuleName>/Project.swift`의 `dependencies: [` 영역에 자동 삽입합니다.
  - Domain 계층 생성 시, `Interface/Sources/Base.swift`를 템플릿으로 생성하도록 선택 가능.

> ⚠️ **파일 경로 전제**  
> - 위 파서는 특정 경로의 파일 구조/포맷을 기대합니다. 경로가 다르거나 파일 포맷이 변경되면 파싱이 실패할 수 있습니다.  
> - 경로가 다르다면 `availableModuleTypes()`, `parseModulesFromFile()`, `parseSPMLibraries()`의 파일 경로를 프로젝트에 맞게 수정하세요.

## 🚀 동적 프로젝트 이름 설정

"MultiModuleTemplate" 대신 원하는 이름으로 프로젝트를 생성할 수 있습니다.

### 사용 방법

#### 🎯 방법 1: TuistTool 사용 (권장)

```bash
# 대화형 입력
./tuisttool newproject

# 명령어 인자로 바로 설정
./tuisttool newproject MyAwesomeApp --bundle-id com.company.app
```

#### 🎯 방법 2: 환경변수 (CI/CD용)

```bash
export PROJECT_NAME="MyAwesomeApp"
export BUNDLE_ID_PREFIX="com.company.awesome"
tuist generate
```

#### 🎯 방법 3: Tuist 템플릿 (완전히 새 프로젝트)

```bash
mkdir MyNewProject && cd MyNewProject
tuist scaffold multi-module-project --name MyNewProject
```

### 설정 가능한 항목

| 항목 | 설명 | 기본값 |
|------|------|--------|
| `PROJECT_NAME` | 앱 이름 | MultiModuleTemplate |
| `BUNDLE_ID_PREFIX` | 번들 ID 접두사 | io.Roy.Module |
| `TEAM_ID` | 개발팀 ID | N94CS4N6VR |

---

## 자주 쓰는 명령어

```bash
# 새 프로젝트 생성
./tuisttool newproject

# 기본 워크플로우
./tuisttool build      # clean → fetch → generate
tuist test

# 개발 환경
tuist up               # 부트스트랩
tuist doctor           # 문제 진단

# 고급 기능
tuist focus <모듈>     # 특정 모듈만 포커스
tuist graph --format pdf --path ./graph.pdf
```

## CI 예시 (로컬 재현과 동일한 단계)
```bash
./tuisttool reset
./tuisttool build
tuist test
```

---

## 기여 방법

1. 브랜치를 생성합니다 (`git checkout -b feature/my-feature`)  
2. 변경사항을 커밋합니다 (`git commit -m 'Add feature'`)  
3. 브랜치에 푸시합니다 (`git push origin feature/my-feature`)  
4. Pull Request를 생성합니다

## 라이선스

이 프로젝트는 [MIT License](LICENSE) 하에 배포됩니다.
