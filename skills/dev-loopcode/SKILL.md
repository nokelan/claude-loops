---
name: dev-loopcode
description: "코드/API/앱 대상으로 타입 탐지 → 병렬 빌드 → 3단계 검증(기계/AC/Adversarial) 루프를 자동 완주하는 오케스트레이터. '/dev-loopcode', '코드 루프', '테스트 루프 돌려줘' 입력 시 사용."
---

# /dev-loopcode — 코드 테스트 자동화 루프 오케스트레이터

목표 또는 SPEC.md를 입력받아 타입 탐지 → 태스크 분해 → 병렬 빌드 → 3단계 검증 루프를 자동 완주한다.  
모든 AC가 통과될 때까지 자율 반복. 사람은 목표를 주고 결과만 받는다.

---

## Usage

```
/dev-loopcode
/dev-loopcode "목표 설명"
/dev-loopcode --max-loops 5
/dev-loopcode --type api
/dev-loopcode --resume        # LOOP_STATE.md 존재 시 중간부터 재개
```

---

## Pipeline

```
[0] INIT     — 타입 탐지 (code | api | app) + 환경 + OPENAI_API_KEY 확인
[1] PLAN     — 타입별 태스크 분해 → TASKS.md 생성
[2] BUILD    — 병렬 서브에이전트 실행 (IMPLEMENTER × N)
                 ↑ FAIL (VERIFY-1/2)
[3] VERIFY-1 — 기계적 검증 (빌드/실행/문법) → FAIL → BUILD 루프백
[4] VERIFY-2 — AC 기능 검증 → FAIL → BUILD 루프백
                 ↑ FAIL (VERIFY-3)
[5] VERIFY-3 — Adversarial 검증 (Codex | Claude) → 지적 → PLAN 루프백
[완료] 모든 검증 통과 → 위키 저장 + 텔레그램 알림
       실패 반복 시 → max-loops 초과 → 사용자 개입 요청
```

---

## Instructions

사용자가 이 스킬을 호출하면 아래 단계를 **자동으로, 순서대로** 실행한다.  
각 단계 사이에 사용자 허락을 구하지 않는다.  
BLOCKED 또는 max-loops 초과 시에만 멈추고 텔레그램으로 보고한다.

---

### 0단계 — INIT (초기화)

#### 파라미터 파싱

| 파라미터 | 기본값 | 설명 |
|---------|--------|------|
| 목표 | (SPEC.md에서 읽기) | 첫 번째 인수 또는 사용자 메시지 |
| --max-loops N | 5 | 빌드-검증 루프 최대 횟수 |
| --type X | auto | code / api / app (auto면 0-2에서 탐지) |
| --resume | false | LOOP_STATE.md 있으면 중간부터 재개 |
| --server-cmd CMD | (auto) | app/api 타입 서버 기동 명령 (예: `npm start`, `dotnet run`, `uvicorn app:app`) |

#### 0-1. SPEC.md 확인

프로젝트 루트에서 `SPEC.md`를 찾는다.
- **있으면**: 목표(Goal)와 AC 목록 추출 → 내부 저장
- **없고 목표 인수도 없으면**: 중단
  ```
  [DEV-LOOPCODE] SPEC.md가 없습니다.
  /dev-plan 으로 SPEC.md를 먼저 생성하거나
  목표를 직접 입력하세요: /dev-loopcode "목표 설명"
  ```
- **없고 목표 인수가 있으면**: 1단계(PLAN)에서 SPEC.md 자동 생성

#### 0-2. 타입 탐지 (`--type auto`인 경우)

프로젝트 루트의 파일 구조로 타입 판별:

| 탐지 기준 | 타입 | 실행 도구 |
|---------|------|---------|
| `package.json` / `.py` / `.cs` / `.gd` 존재 | `code` | 단위 테스트, 빌드 |
| `pom.xml` / `build.gradle` / `.java` 존재 | `code` | mvn/gradle 빌드 |
| `Gemfile` / `.rb` 존재 | `code` | bundle exec |
| `Cargo.toml` 존재 | `code` | cargo build |
| `go.mod` / `.go` 존재 | `code` | go build |
| `openapi.yaml` / `swagger.json` / REST endpoint 정의 | `api` | HTTP 호출 검증 |
| `index.html` / Electron / WPF / Godot `.tscn` | `app` | UI 동작 검증 |
| 판별 불가 | `code` | (기본값 적용) |

#### 0-2-1. 환경 설정 파일 탐지

프로젝트 루트에서 환경 설정 파일을 자동 탐지한다:
- `.env`, `.env.local`, `.env.development` → `env_file` 기록
- `config.json`, `appsettings.json`, `application.properties` → `config_file` 기록
- 탐지 결과를 LOOP_STATE.md에 기록 (`env_file`, `config_file`)
- 빌드/실행 명령 전 해당 파일 경로를 서브에이전트에 전달

#### 0-3. OPENAI_API_KEY 탐지

`$env:OPENAI_API_KEY` 환경변수를 자동 확인한다. 매번 묻지 않는다.
- **있으면**: VERIFY-3에서 Codex(GPT-5) adversarial 모드 사용
- **없으면**: VERIFY-3에서 Claude adversarial 모드 사용

결과를 `LOOP_STATE.md`에 기록한다 (`verify_mode: codex | claude`).

#### 0-4. --resume 처리

`--resume` 플래그가 있고 `LOOP_STATE.md`가 존재하면:
- 파일을 읽어 `current_step`을 확인
- 해당 단계부터 재개 (0~2단계는 재실행하지 않음)

#### 0-5. LOOP_STATE.md 생성 (또는 갱신)

```markdown
# LOOP STATE
- goal: [목표]
- type: [code | api | app]
- verify_mode: [codex | claude]
- iteration: 0
- current_step: plan
- status: running
- started: [날짜 YYYY-MM-DD]
- max_loops: N
```

출력:
```
[DEV-LOOPCODE] 시작
목표: [목표]
타입: [code | api | app]
검증 모드: [Codex(GPT-5) | Claude adversarial]
max-loops: N
```

텔레그램으로 시작 알림 전송 (목표 + 타입 + 검증 모드 포함).

---

### 1단계 — PLAN (태스크 분해)

`SPEC.md`가 없으면 목표 인수로부터 SPEC.md를 생성한다:

```markdown
# SPEC

## Goal
[목표]

## Acceptance Criteria
- [ ] AC-1: [측정 가능한 완료 기준]
- [ ] AC-2: ...

## Constraints
- [제약 사항]

## Out of Scope
- [제외 항목]
```

#### HARD GATE — AC 품질 검증

SPEC.md 생성 또는 읽기 완료 후, AC 목록 전체를 아래 기준으로 검증한다.

각 AC에 대해:
- 측정 가능한가? ("잘 작동한다", "빠르다" 같은 모호한 기준 → FAIL)
- 완료 판별 가능한가? (실행/테스트/숫자로 확인 가능한가?)
- 범위가 명확한가? (무엇을, 어떤 조건에서 검증하는지 특정 가능한가?)

기준 미충족 AC가 하나라도 있으면:

```
[DEV-LOOPCODE] HARD GATE FAIL
다음 AC가 측정 불가합니다:
- AC-N: [원인]

수정 방법: SPEC.md의 해당 AC를 측정 가능하게 재작성하세요.
예) "빠르게 응답한다" → "응답 시간 500ms 이하 (p95)"
예) "잘 작동한다" → "로그인 성공 시 JWT 토큰 반환 + HTTP 200"

수정 후 /dev-loopcode --resume 으로 재개하세요.
```

LOOP_STATE.md: `status: blocked`, `current_step: hard-gate-fail`  
텔레그램으로 동일 내용 전송.  
**모든 AC 통과 시에만 TASKS.md 생성으로 진행.**

---

이후 타입별로 `TASKS.md` 생성:

**code 타입:**
```markdown
# TASKS

- T001: [모듈/함수 구현] (depends_on: [])
- T002: [단위 테스트 작성] (depends_on: [T001])
- T003: [통합 테스트] (depends_on: [T002])
```

**api 타입:**
```markdown
# TASKS

- T001: [엔드포인트 구현] (depends_on: [])
- T002: [요청/응답 스키마 검증] (depends_on: [T001])
- T003: [에러 케이스 처리] (depends_on: [T001])
```

**app 타입:**
```markdown
# TASKS

- T001: [핵심 기능 구현] (depends_on: [])
- T002: [UI 연결] (depends_on: [T001])
- T003: [엣지 케이스 처리] (depends_on: [T001])
```

LOOP_STATE.md 업데이트: `current_step: build`

---

### 2단계 — BUILD (병렬 서브에이전트 실행)

TASKS.md의 의존성 그래프를 분석한다.
- `depends_on: []` 태스크 → **병렬** 실행 (동시 에이전트)
- `depends_on: [TXxx]` 태스크 → 선행 태스크 완료 후 실행

각 태스크에 대해 Agent 호출 (IMPLEMENTER 역할):

```
역할: IMPLEMENTER (태스크 실행 에이전트)

태스크: [T00N 설명]
목표: [SPEC Goal]
타입: [code | api | app]
제약: [SPEC Constraints]

지시:
1. 이 태스크만 구현하라. 범위를 벗어나지 말 것.
2. 구현 완료 후 결과를 TASK_RESULTS/T00N.md에 기록하라.
3. 형식: ## 결과 / ## 변경 파일 / ## 이슈
```

모든 태스크 완료 후:
- `[BUILD DONE] N개 태스크 완료` 출력
- LOOP_STATE.md 업데이트: `current_step: verify-1`

---

### 3단계 — VERIFY-1 (기계적 검증)

타입별로 빌드/실행 가능 여부를 확인한다.

**code 타입 — 언어별 빌드 커맨드:**

| 언어/프레임워크 | 빌드 커맨드 |
|---------------|-----------|
| Node.js | `npm run build` 또는 `npx tsc` |
| Python | `python -m py_compile $(find . -name '*.py')` |
| C# / .NET | `dotnet build` |
| Java (Maven) | `mvn package -q` |
| Java (Gradle) | `./gradlew build` 또는 `gradle build` |
| Ruby | `bundle exec rake` 또는 `bundle exec ruby -c *.rb` |
| Rust | `cargo build` |
| Go | `go build ./...` |
| Godot | `.gd` 파일 문법 확인 (빌드 불필요) |

- 문법 오류, 누락 임포트 확인
- 빌드 커맨드를 찾지 못하면 `code 타입 기본값(dotnet build)` 사용 후 텔레그램 경고

**api 타입:**
- `--server-cmd` 가 있으면 실행, 없으면 프로젝트 타입으로 자동 추정
- 서버 기동 후 `/health` 또는 루트 엔드포인트 GET 요청 → HTTP 상태 코드 확인
- **200 응답만 PASS** — 404/500/연결실패는 FAIL 처리 (navigate만으로 PASS 판정 금지)

**app 타입:**
- `--server-cmd` 가 있으면 백그라운드 실행, 없으면 자동 추정 (`npm start`, `dotnet run` 등)
- 실행 파일 빌드 확인 (크래시 없이 기동 확인)
- 세션 크래시 복구: 기동 실패 시 3초 대기 후 1회 재시도. 재시도도 실패 시 FAIL 처리
- 검증 도구: `Playwright` / `Selenium` / `Cypress` 중 프로젝트 내 설치된 것 자동 탐지
  - `playwright.config.*` 존재 → `npx playwright test`
  - `cypress.config.*` 존재 → `npx cypress run`
  - Selenium 기반 `.cs`/`.py` 테스트 존재 → 해당 커맨드 실행
  - 없으면 기동 확인만 수행 후 경고 텔레그램 전송

**결과 판정:**
- `[VERIFY-1 PASS]` → 4단계로
- `[VERIFY-1 FAIL]` + 오류 내용 → iteration 증가 후 2단계(BUILD) 루프백

루프백 전 텔레그램 보고:
```
[DEV-LOOPCODE 루프 N/max] VERIFY-1 FAIL
오류: [내용]
→ BUILD 재시도
```

---

### 4단계 — VERIFY-2 (AC 기능 검증)

SPEC.md의 각 AC 항목을 하나씩 실행하여 검증한다.

각 AC에 대해:
- 실행/테스트/확인 수행
- `[PASS] AC-N: [내용]` 또는 `[FAIL] AC-N: [내용] — 원인: [설명]`

```markdown
# VERIFY REPORT (Iteration N)

## AC 검증 결과
| AC | 결과 | 원인 (FAIL 시) |
|----|------|---------------|
| AC-1 | PASS | - |
| AC-2 | FAIL | [설명] |

## 판정: PASS N/전체 | FAIL N개
```

**결과 판정:**
- 모든 AC `PASS` → 5단계(VERIFY-3)로
- FAIL 존재 → iteration 증가 후 2단계(BUILD) 루프백
  - 루프백 전 `TASK_RESULTS/FAILED_AC.md` 파일 생성/갱신:
    ```markdown
    # FAILED AC (Iteration N)
    
    | AC | 원인 | 관련 파일 |
    |----|------|---------|
    | AC-2 | [설명] | [파일경로:라인] |
    ```
  - BUILD 에이전트 프롬프트에 FAILED_AC.md 내용 포함: "다음 AC만 수정하라: [목록]"
  - 수정 범위를 실패 AC 관련 파일로 한정

---

### 5단계 — VERIFY-3 (Adversarial 검증)

VERIFY-1, VERIFY-2를 모두 통과한 코드에 대해 외부 시각으로 반론 검증을 수행한다.

#### verify_mode = codex (OPENAI_API_KEY 있을 때)

**Step 1 — codex-plugin-cc 설치 확인:**

```bash
codex --version 2>$null
```
- 명령 성공 → codex 사용 가능
- 실패(NOT_INSTALLED) → `verify_mode = claude` 자동 폴백, 텔레그램 알림:
  ```
  [DEV-LOOPCODE] codex-plugin-cc 미설치 → Claude adversarial 모드로 폴백
  설치: npm install -g @openai/codex && codex login
  ```

**Step 2 — `/codex:adversarial-review` 호출 (Skill 도구):**

```
/codex:adversarial-review
```

codex에 전달할 컨텍스트를 현재 디렉토리 `SPEC.md`와 변경 파일 목록으로 준비한다. codex는 SPEC.md를 읽고 adversarial 검토를 수행한다.

**Step 3 — 결과 확인:**

```bash
codex status          # 백그라운드 작업 상태 확인
codex result <id>     # 결과 가져오기
```

결과가 나오기까지 최대 60초 폴링 (10초 간격). 60초 초과 시 → `/codex:cancel <id>` 후 `verify_mode = claude` 폴백.

**Step 4 — 결과 파싱:**

codex 결과에서:
- `ADVERSARIAL PASS` 또는 결함 없음 텍스트 포함 → PASS
- 결함 목록 포함 → 심각도별 분류 후 판정

#### verify_mode = claude (OPENAI_API_KEY 없을 때)

Claude 자신에게 adversarial 역할을 부여하여 동일한 검토 수행:

```
역할: 코드 비평가 (Adversarial Reviewer)

지금까지 구현한 코드를 최대한 비판적으로 검토하라.
"잘 됐다"는 반응은 허용하지 않는다. 문제를 찾아내는 것이 목표다.

[동일 검토 관점 적용]
```

**결과 판정:**
- `ADVERSARIAL PASS` 또는 결함 없음 → 6단계(완료)로
- HIGH 심각도 결함 → PLAN 루프백 (설계 수정)
- MED/LOW 결함 → BUILD 루프백 (코드 수정)

루프백 전 텔레그램 보고:
```
[DEV-LOOPCODE 루프 N/max] VERIFY-3 지적
심각도: [HIGH|MED]
지적 사항: [내용]
→ [PLAN|BUILD] 루프백
```

---

### max-loops 초과 처리

iteration이 max-loops를 초과하면 즉시 중단:

```
[DEV-LOOPCODE] MAX LOOPS REACHED (N회)
자동 해결 불가능.

미충족 AC:
- [AC-N]: [원인]

마지막 VERIFY 리포트: VERIFY_REPORT.md
수동 개입이 필요합니다.
```

LOOP_STATE.md: `status: blocked`  
텔레그램으로 동일 내용 전송.

---

### 6단계 — 완료

모든 검증 통과 시:

1. **SPEC.md AC 체크박스 업데이트**: `[ ]` → `[x]`
2. **VERIFY_REPORT.md 최종 저장**
3. **LOOP_STATE.md**: `status: done`
4. **완료 보고 출력**:
   ```
   [DEV-LOOPCODE] COMPLETE
   목표: [목표]
   타입: [code | api | app]
   검증 모드: [Codex | Claude adversarial]
   총 반복: N회
   통과 AC: N/N

   생성/변경 파일:
   - [파일 목록]
   ```
5. **결과 저장** (선택): 결과 요약을 `C:\temp\dev-loopcode\` 에 저장  
   - 디렉토리 없으면 자동 생성: `New-Item -ItemType Directory -Force C:\temp\dev-loopcode`  
   - 파일명: `[프로젝트명]_[날짜].md`
6. **텔레그램 완료 알림 전송**

---

## 상태 파일 구조

```
프로젝트 루트/
├── SPEC.md              # 목표 + AC + 제약
├── TASKS.md             # 태스크 목록 + 의존성
├── LOOP_STATE.md        # 현재 루프 상태 (resume 지원)
├── VERIFY_REPORT.md     # 검증 결과 누적
└── TASK_RESULTS/
    ├── T001.md
    ├── T002.md
    ├── FAILED_AC.md     # VERIFY-2 실패 AC 목록 (루프백 시 BUILD에 전달)
    └── ...
```

### LOOP_STATE.md 스키마

```markdown
# LOOP STATE
- goal: [목표]
- type: code | api | app
- verify_mode: codex | claude
- iteration: N
- current_step: init | plan | build | verify-1 | verify-2 | verify-3 | done | blocked
- status: running | done | blocked
- started: YYYY-MM-DD
- max_loops: N
- last_fail_reason: [최근 실패 원인]
- env_file: [탐지된 .env 경로 또는 none]
- config_file: [탐지된 config 파일 경로 또는 none]
- server_cmd: [app/api 서버 기동 명령 또는 none]
- server_pid: [실행 중인 서버 PID 또는 none]
```

**세션 크래시 복구 패턴:**
VERIFY 루프 재진입 시 LOOP_STATE.md를 읽어:
- `server_pid` 가 있으면 프로세스 생존 여부 확인 → 죽어있으면 `server_cmd`로 재기동
- `current_step` 이 verify-1/2/3 인데 status=running 이면 → 해당 단계부터 재개
- `iteration` 카운트 유지 (재기동이 반복 카운트에 포함되지 않도록)

---

## 진행 상황 출력 형식

```
[DEV-LOOPCODE] 시작 | 타입: code | 검증: Claude adversarial | max-loops: 5
[DEV-LOOPCODE] PLAN 완료 → TASKS.md 생성 (T001~T003)
[DEV-LOOPCODE] BUILD 시작 | 병렬 태스크: T001, T002
[DEV-LOOPCODE] BUILD DONE (3/3 태스크)
[DEV-LOOPCODE] VERIFY-1 PASS → VERIFY-2 시작
[DEV-LOOPCODE] VERIFY-2 | AC-1 PASS | AC-2 FAIL
[DEV-LOOPCODE] 루프 2/5 | VERIFY-2 FAIL → BUILD 루프백
[DEV-LOOPCODE] VERIFY-3 adversarial 시작
[DEV-LOOPCODE] VERIFY-3 PASS → COMPLETE
[DEV-LOOPCODE] COMPLETE | 총 2회 반복 | AC 3/3 통과
```

---

## 흡수한 패턴

| 출처 | 흡수 패턴 |
|------|---------|
| superpowers/subagent-driven-development | IMPLEMENTER 서브에이전트 역할 분리 |
| superpowers/dispatching-parallel-agents | depends_on 기반 병렬 BUILD 디스패치 |
| codex-plugin-cc | OPENAI_API_KEY 자동 탐지 → Codex adversarial |
| superpowers/verification-before-completion | VERIFY-3 adversarial 없이 완료 불가 |
| dev-loop | SPEC.md/AC 기반 루프, 텔레그램 중간 보고 |
| dev-hwaloop | LOOP_STATE.md 상태 추적, --resume, max-loops |

---

## 사용 예시

```
/dev-loopcode
/dev-loopcode "로그인 API 구현 — JWT 인증, 실패 시 401 반환"
/dev-loopcode --max-loops 3 --type api
/dev-loopcode --resume
```
