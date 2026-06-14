# SPEC — 서버/API 프로젝트 템플릿

## Goal
<!-- 예: 세금 신고 데이터를 받아 PDF 생성 후 반환하는 REST API -->

## Acceptance Criteria
- [ ] AC-1: POST /api/generate → 200 OK + PDF binary (500ms 이하, p95)
- [ ] AC-2: 잘못된 입력 → 400 + {"error": "메시지"} 반환
- [ ] AC-3: /health 엔드포인트 → 200 {"status":"ok"}

## Tech Stack
- Runtime: <!-- Python 3.11 / Node 20 / .NET 8 -->
- Framework: <!-- FastAPI / Express / ASP.NET Core -->
- DB: <!-- PostgreSQL / SQLite / 없음 -->

## API Endpoints
| Method | Path | 설명 |
|--------|------|------|
| POST | /api/generate | 메인 기능 |
| GET | /health | 헬스체크 |

## Constraints
- 인증: JWT Bearer 또는 API Key 헤더
- 환경변수로 설정 주입 (.env 파일, 하드코딩 금지)
- Docker Compose 또는 단순 실행 스크립트 포함

## Out of Scope
- 관리자 대시보드
- 이메일 발송
