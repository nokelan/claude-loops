# claude-loops

Claude Code용 루프 엔지니어링 스킬 모음.

`/dev-plan → /dev-loop → /dev-verify` 파이프라인으로 목표를 입력하면 자동으로 완료까지 실행합니다.

---

## 포함 Skills

| 스킬 | 트리거 | 역할 |
|------|--------|------|
| `dev-plan` | `/dev-plan` | 요구사항 인터뷰 + SPEC.md 생성 |
| `dev-loop` | `/dev-loop` | SPEC 기반 구현 → 검증 루프 |
| `dev-loopcode` | `/dev-loopcode` | 코드 타입 탐지 → 병렬 빌드 → 3단계 검증 |
| `dev-verify` | `/dev-verify` | 최종 품질 심사 |
| `dev` | `/dev` | plan→loop→verify 전체 파이프라인 |
| `dev-hwaloop` | `/dev-hwaloop` | 2-에이전트 토론 설계 + 루프 |
| `harness` | `/harness` | 프로젝트용 전문 에이전트 팀 구성 |
| `graphify` | `/graphify` | 지식 그래프 생성/갱신 |
| `design-page` | `/design-page` | 브랜드 기반 단일 HTML 페이지 생성 |
| `frontend-slides` | `/frontend-slides` | 16:9 HTML 프레젠테이션 생성 |
| `m-search` | `/m-search` | 과거 Claude 대화 DB 검색 |

---

## 설치

### Windows (PowerShell)
```powershell
git clone https://github.com/nokelan/claude-loops.git
cd claude-loops
.\install.ps1
```

### macOS / Linux
```bash
git clone https://github.com/nokelan/claude-loops.git
cd claude-loops
bash install.sh
```

기본 설치 경로: `~/.claude/skills/`  
다른 경로 사용 시:
```powershell
.\install.ps1 -ClaudeHome "C:\Users\YourName\.claude"
```

---

## 환경 설정

텔레그램 알림이나 m-search 기능 사용 시 `.env` 설정 필요:

```bash
cp .env.example .env
# 이후 .env에서 TELEGRAM_CHAT_ID 등 설정
```

---

## SPEC 템플릿

`templates/` 폴더에 프로젝트 타입별 SPEC.md 예시가 있습니다:

| 폴더 | 용도 |
|------|------|
| `templates/web/` | React / Next.js / Vanilla 웹 프로젝트 |
| `templates/desktop/` | WinForms / WPF / C# 데스크탑 앱 |
| `templates/server/` | REST API / FastAPI / ASP.NET 서버 |
| `templates/docs/` | HTML 보고서 / 문서 자동 생성 스크립트 |

`/dev-plan` 없이 바로 시작할 때 해당 템플릿을 SPEC.md로 복사 후 수정하세요.

---

## 파이프라인 흐름

```
/dev "할일 앱 만들어줘"
    ↓
[dev-plan]  요구사항 인터뷰 → SPEC.md
    ↓
[dev-loop]  구현 → 검증 루프 (최대 5회)
    ↓
[dev-verify] 최종 품질 심사
    ↓
완료 보고 (텔레그램)
```

코드/API/앱 타입에 특화된 검증이 필요하면 `/dev-loopcode` 사용:

```
/dev-loopcode "목표"
    ↓
[타입 탐지]  code | api | app
    ↓
[VERIFY-1]  빌드 · 문법 검증
    ↓
[VERIFY-2]  AC 기능 검증
    ↓
[VERIFY-3]  Adversarial 검증 (Claude or Codex)
```

---

## 라이선스

MIT
