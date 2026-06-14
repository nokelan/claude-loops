# SPEC — 데스크탑 앱 템플릿 (WinForms / WPF / C#)

## Goal
<!-- 예: 엑셀 파일을 읽어 DB에 자동 업로드하는 Windows 트레이 앱 -->

## Acceptance Criteria
- [ ] AC-1: (측정 가능 — 예: 파일 1,000행 처리 5초 이하)
- [ ] AC-2: .NET 8 이상, 싱글 EXE 배포 가능
- [ ] AC-3: 오류 발생 시 로그 파일(logs/app.log) 기록

## Tech Stack
- Framework: <!-- WinForms / WPF / Console -->
- Language: C# (.NET 8)
- UI: <!-- Designer.cs 분리 필수 -->

## Constraints
- Designer.cs 파일 필수 분리 (UI 코드 Form1.Designer.cs)
- 빌드 결과물: bin\Release\net8.0-windows\publish\app.exe (single file)
- 외부 DLL 의존성 최소화

## Out of Scope
- 웹 서버 통신
- 자동 업데이트
