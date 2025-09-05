# MultiModuleTemplate

Tuist로 구성된 멀티 모듈 iOS 프로젝트입니다.

## 프로젝트 구조

```
MultiModuleTemplate/
├── Workspace.swift
├── Tuist.swift
├── Projects/
│   ├── Presentation/         # 화면 및 ViewModel 구성
│   ├── Core/
│   │   ├── Network/          # API 통신 계층
│   │   │   └── Service/      # 실제 API 호출 서비스
│   │   ├── UseCase/          # 도메인 UseCase 정의
│   │   ├── Repository/       # UseCase와 Data 연결 계층
│   │   └── DomainInterface/  # 도메인 인터페이스 계층
│   │       └── Model/        # 엔티티/도메인 모델
│   └── Shared/
│       ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트 등
│       ├── ThirdParty/       # 외부 라이브러리 래핑
│       └── Utill/            # 공통 유틸리티
├── Tuist/
│   ├── Package.swift
│   └── ProjectDescriptionHelpers/
└── Scripts/
```

## 시작하기

### 1) 개발환경 부트스트랩
```bash
tuist up        # 플러그인/툴 설치 등 환경 준비
tuist doctor    # 문제 진단
```

### 2) 프로젝트 생성
```bash
tuist generate
```

### 3) 빌드
```bash
tuist build
```

### 4) 테스트
```bash
tuist test
```

## 주요 모듈 설명

- **Presentation**: ViewController, ViewModel 등 UI 로직 담당  
- **Core**
  - **Network**: API 클라이언트 및 endpoint 관리
  - **Service**: Network 계층의 실제 요청 처리
  - **UseCase**: 도메인 규칙에 따른 비즈니스 로직 처리
  - **Repository**: UseCase와 실제 데이터 소스(API/DB 등) 연결
  - **DomainInterface/Model**: 도메인 객체 및 Interface 정의
- **Shared**
  - **DesignSystem**: 공통 UI 컴포넌트, 폰트, 색상 등 디자인 자산
  - **ThirdParty**: Alamofire, TCA, etc. 외부 라이브러리 래핑
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

# 🛠️ tuisttool (커스텀 CLI)

`tuisttool.swift`로 제공되는 프로젝트 전용 CLI입니다. `tuist` 명령을 래핑하고, 모듈 스캐폴딩 및 의존성 자동 삽입 등을 도와줍니다.

## 설치

프로젝트 루트에서 아래 명령으로 바이너리를 빌드합니다.

```bash
swiftc tuisttool.swift -o tuisttool
chmod +x ./tuisttool
```

> **경로 팁**: `./tuisttool`을 자주 쓴다면 PATH에 추가하거나 `make` 스크립트로 감싸서 사용하세요.

## 기본 사용법

```bash
./tuisttool <command>
```

### 지원 명령어 요약

| Command       | 설명 |
|---------------|------|
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

## 자주 쓰는 Tuist 명령어(치트시트)

```bash
# 프로젝트 생성/갱신
tuist generate

# 빌드/테스트
tuist build
tuist test

# 환경/설정 진단 & 부트스트랩
tuist up
tuist doctor

# 포커스 개발(대규모 멀티 모듈에서 유용)
tuist focus Presentation

# 그래프 시각화
tuist graph --format pdf --path ./graph.pdf

# 캐시 워밍
tuist cache warm

# 정리
tuist clean
rm -rf ~/Library/Developer/Xcode/DerivedData
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
