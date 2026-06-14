---
name: dev-loopcode
description: "코드/API/앱 대상으로 타입 탐지 → HARD GATE → 병렬 빌드 → 4단계 검증(기계/AC+도메인/Adversarial/Rescue) → ADR+리팩토링 제안 루프 오케스트레이터. '/dev-loopcode', '코드 루프', '테스트 루프 돌려줘' 입력 시 사용."
---

# /dev-loopcode — 코드 테스트 자동화 루프 오케스트레이터

목표 또는 SPEC.md를 입력받아 타입 탐지 → HARD GATE → 병렬 빌드 → 4단계 검증 루프를 자동 완주한다.  
모든 AC가 통과될 때까지 자율 반복. 완료 후 ADR 갱신 + 리팩토링 제안까지 수행한다.

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

## Pipeline (전체)

```
[0]   INIT       — 타입 탐지 + config.json + OPENAI_API_KEY + CONTEXT.md 탐지
[0.5] GOAL INTERVIEW — 목표 모호 시 사용자와 AC 확정 (SPEC.md 없을 때만, 루프 차감 없음)
[1]   PLAN       — 태스크 분해 + CONTEXT.md 도메인 언어 반영 → SPEC.md + TASKS.md
[1.5] HARD GATE  — AC 측정 가능성 검사 → FAIL → PLAN 루프백
[2]   BUILD      — 병렬 서브에이전트 (IMPLEMENTER × N, depends_on 기반)
                    ↑ FAIL: FAILED_AC.md 기반 범위 한정 재시도
[3]   VERIFY-1   — 기계적 검증 (서버기동 + 빌드/실행 + navigate 200)
[4]   VERIFY-2   — AC 기능 검증 + 도메인 언어 검사(/grill-with-docs)
[5]   VERIFY-3   — Adversarial (Codex CLI → rescue 모드 | Claude 폴백)
[5.5] RESCUE     — max-loops 임박 시 외부 시각 주입 (탈출 전략 제안)
[완료] ADR.md 갱신 + /improve-codebase-architecture 제안 + 사용자 보고 + 위키(선택)
       실패 → max-loops 초과 → 사용자 개입 요청
```

---

## Instructions

사용자가 이 스킬을 호출하면 아래 단계를 **자동으로, 순서대로** 실행한다.  
각 단계 사이에 사용자 허락을 구하지 않는다.  
BLOCKED 또는 max-loops 초과 시에만 멈추고 사용자에게 보고한다.

---

### 0단계 — INIT (초기화)

#### 파라미터 파싱

| 파라미터 | 기본값 | 설명 |
|---------|--------|------|
| 목표 | (SPEC.md에서 읽기) | 첫 번째 인수 또는 사용자 메시지 |
| --max-loops N | 5 | 빌드-검증 루프 최대 횟수 |
| --type X | auto | code / api / app (auto면 탐지) |
| --resume | false | LOOP_STATE.md 있으면 중간부터 재개 |

#### 0-1. SPEC.md 확인

- **있으면**: 목표(Goal)와 AC 목록 추출
- **없고 목표 인수 있으면**: 1단계에서 자동 생성
- **없고 목표도 없으면**: 중단 후 안내

#### 0-2. config.json 탐지

프로젝트 루트에서 `config.json` 또는 `.env` 파일을 찾는다.

```json
{
  "base_url": "http://localhost:5500",
  "server_cmd": "python -m http.server 5500",
  "server_cwd": "vue-sample",
  "verify_cmd": "python rpa_runner.py",
  "test_cmd": "pytest"
}
```

#### 0-3. CONTEXT.md 탐지 (도메인 언어 기반)

프로젝트 루트에서 `CONTEXT.md` 파일을 찾는다.

```
있으면:
  - 도메인 용어 사전 로드 (핵심 개념, 금지 표현, 약어 정의)
  - LOOP_STATE.md에 context_loaded: true 기록
  - PLAN 단계에서 TASKS.md 생성 시 도메인 언어 준수 지시
  - VERIFY-2 후 /grill-with-docs 검사 활성화

없으면:
  - context_loaded: false 기록
  - VERIFY-2 도메인 검사 단계 건너뜀
  - 완료 시 "CONTEXT.md 생성을 권장합니다" 사용자 안내
```

#### 0-4. 타입 탐지 (`--type auto`인 경우)

| 탐지 기준 | 타입 | 기본 verify_cmd |
|---------|------|----------------|
| `package.json` / `.py` / `.cs` / `.gd` | `code` | pytest / dotnet test |
| `openapi.yaml` / REST endpoint 정의 | `api` | pytest / curl |
| `index.html` / Electron / `.tscn` / `rpa_runner.py` | `app` | python rpa_runner.py |

#### 0-5. OPENAI_API_KEY 탐지

`$env:OPENAI_API_KEY` 자동 확인. 매번 묻지 않는다.
- **있으면**: VERIFY-3에서 Codex CLI adversarial 모드, rescue 모드 사용 가능
- **없으면**: VERIFY-3에서 Claude adversarial 모드, RESCUE도 Claude fresh-perspective 사용

#### 0-6. LOOP_STATE.md 생성

```markdown
# LOOP STATE
- goal: [목표]
- type: code | api | app
- verify_mode: codex | claude
- context_loaded: true | false
- server_cmd: [서버 커맨드 or "none"]
- verify_cmd: [검증 커맨드]
- iteration: 0
- current_step: plan
- status: running
- started: YYYY-MM-DD
- max_loops: N
```

사용자에게 시작 보고 (목표 + 타입 + 검증 모드 + CONTEXT.md 여부).

---

### 0.5단계 — GOAL INTERVIEW (목표 명확화)

**SPEC.md가 없고 목표 인수만 있을 때 실행. SPEC.md가 이미 있으면 건너뜀.**

목표가 "측정 가능한 AC"로 바로 변환될 만큼 구체적인지 판단한다.  
모호하면 명확해질 때까지 사용자에게 반복 질문한다. **max-loops 차감 없음.**

#### 판단 기준

| 상태 | 조건 | 액션 |
|------|------|------|
| 즉시 진행 | 목표에 수치/판정/구체적 완료 조건 포함 | PLAN으로 직행 |
| 인터뷰 필요 | "잘 동작하는", "빠른", "편한" 등 모호한 표현 | 아래 인터뷰 루프 실행 |

#### 인터뷰 루프

```
Round 1 — 사용자에게 질문:
  "어떤 상태가 되면 이 작업이 완료됐다고 볼 수 있나요?
   숫자, 판정(PASS/FAIL), 특정 출력 등으로 표현해 주세요."

Round 2 — AC 초안 작성 후 확인:
  초안 AC 목록을 보여주고:
  "이 기준이 맞나요? 추가하거나 바꿀 항목이 있으면 말씀해 주세요."

Round N — 사용자가 "맞다" / "OK" / 확정 응답할 때까지 반복.
  각 라운드마다 이전 피드백을 반영하여 AC를 수정한다.
```

확정된 AC로 SPEC.md 생성 → PLAN 단계로 진행.

---

### 1단계 — PLAN (태스크 분해)

SPEC.md 없으면 목표로부터 생성:

```markdown
# SPEC

## Goal
[목표]

## Acceptance Criteria
- [ ] AC-1: [측정 가능한 완료 기준 — 수치/판정 가능]
- [ ] AC-2: ...

## Domain Language
[CONTEXT.md가 있으면 핵심 도메인 용어 3~5개 나열. 없으면 "N/A"]

## Constraints
- [제약]

## Environment
- base_url: [config.json 값 또는 N/A]
- server_cmd: [서버 커맨드 또는 N/A]
- verify_cmd: [검증 실행 커맨드]

## Out of Scope
- [제외 항목]
```

TASKS.md 생성 시 CONTEXT.md 도메인 언어 준수 지시:

```
IMPLEMENTER에게: CONTEXT.md의 도메인 용어를 그대로 사용하라.
임의로 동의어나 약어를 만들지 말 것.
```

---

### 1.5단계 — HARD GATE (AC 품질 검사)

**PLAN 완료 직후 반드시 실행. 통과하지 않으면 BUILD로 진행 불가.**

| 검사 항목 | PASS 기준 | FAIL 예시 |
|---------|---------|---------|
| 측정 가능성 | 수치/판정/URL/텍스트 등 객관적 확인 가능 | "잘 동작한다", "빠르다" |
| 구체성 | 어느 화면/함수/엔드포인트인지 명시 | "로그인이 된다" (어떻게?) |
| 독립성 | 다른 AC에 순환 의존하지 않음 | "AC-2가 통과되면 AC-1도 통과" |

HARD GATE FAIL:
```
[DEV-LOOPCODE] HARD GATE FAIL
모호한 AC: AC-N "[원문]" — 이유: 측정 불가 기준
수정 방향: [구체적 개선 안]
→ PLAN 재실행
```
사용자에게 안내 후 1단계 루프백. max-loops 차감 없음.

HARD GATE PASS → `current_step: build`

---

### 2단계 — BUILD (병렬 서브에이전트 실행)

FAILED_AC.md 있으면 (루프백): 해당 태스크만 선택 실행.  
없으면 (최초): TASKS.md 전체 실행.

depends_on 그래프 분석:
- `depends_on: []` → **병렬** Agent 호출
- `depends_on: [TXxx]` → 선행 완료 후 실행

각 태스크 IMPLEMENTER 프롬프트:
```
역할: IMPLEMENTER
태스크: [T00N 설명]
목표: [SPEC Goal]
타입: [code|api|app]
도메인 언어: [CONTEXT.md 핵심 용어 or "N/A"]
실패 AC (재시도 시): [FAILED_AC.md 내용]
제약: [SPEC Constraints]

지시:
1. 이 태스크만 구현. 범위 초과 금지.
2. 도메인 언어를 임의로 변경하지 말 것.
3. TASK_RESULTS/T00N.md에 결과 기록.
   형식: ## 결과 / ## 변경 파일 / ## 이슈
```

완료 후 `current_step: verify-1`

---

### 3단계 — VERIFY-1 (기계적 검증)

#### 3-0. 서버 기동 (app 타입 + server_cmd 있을 때)

```
config.json server_cmd 백그라운드 실행 (server_cwd 기준)
→ 3초 대기 → GET base_url → 200 확인
200 아니면 VERIFY-1 FAIL (서버 기동 실패)
```

#### 3-1. 타입별 검증

**code:** 언어 자동 탐지 후 빌드 커맨드 실행:

| 언어/프레임워크 | 탐지 파일 | 빌드 커맨드 |
|-------------|---------|-----------|
| Node.js/TS | package.json | `npm run build` / `npx tsc` |
| Python | *.py | `python -m py_compile **/*.py` |
| C# / .NET | *.csproj | `dotnet build` |
| Java (Maven) | pom.xml | `mvn package -q` |
| Java (Gradle) | build.gradle | `gradle build -q` |
| Rust | Cargo.toml | `cargo build` |
| Go | go.mod | `go build ./...` |
| Ruby | Gemfile | `bundle exec rake` |
| GDScript | project.godot | Godot --headless --export-debug (있으면) |

빌드 성공 → 테스트 파일 수집 (pytest/npm test/dotnet test 등)

**api:** 서버 기동 + 기본 엔드포인트 200  
**app:** 서버 200 + 주요 URL navigate 후 expected element 존재 확인

결과:
- `[VERIFY-1 PASS]` → 4단계
- `[VERIFY-1 FAIL]` → iteration++ → BUILD 루프백

---

### 4단계 — VERIFY-2 (AC 기능 검증 + 도메인 언어 검사)

#### 4-1. AC 기능 검증

SPEC.md의 각 AC 실행 검증 후 **FAILED_AC.md 생성** (실패 항목):

```markdown
# FAILED AC (Iteration N)

## 미충족 항목
- AC-2: [내용]
  - 실패 원인: [설명]
  - 관련 파일: [경로]
  - 수정 힌트: [구체적 방향]

## 관련 태스크
- T002: 재시도 대상
```

#### 4-2. /grill-with-docs (CONTEXT.md 있을 때만)

AC 기능 검증 통과 후 도메인 언어 일관성 검사:

```
역할: 도메인 언어 감사자 (/grill-with-docs 패턴)

참조:
- CONTEXT.md: [도메인 용어 사전 전문]
- 변경된 파일: [코드/문서 목록]

검사 항목:
1. CONTEXT.md에 정의된 용어가 코드/변수명/주석에 일관되게 사용되는가?
2. CONTEXT.md에 없는 임의 동의어나 약어가 새로 생겼는가?
3. 도메인 개념을 잘못 표현한 함수명/클래스명이 있는가?

출력:
- DOMAIN PASS: 위반 없음
- DOMAIN FAIL: [위반 목록 + 파일:라인 + 권장 수정]
```

DOMAIN FAIL → BUILD 루프백 (코드/변수명 수정 요청)  
DOMAIN PASS → 5단계

세션 크래시 복구 (app 타입):
```
"invalid session id" 감지 → 드라이버 재시작 → 해당 케이스부터 재시도 (1회)
재시도 실패 시 해당 AC: FAIL 기록 후 계속
```

---

### 5단계 — VERIFY-3 (Adversarial 검증)

#### verify_mode = codex

```
1. codex --version 확인 → 미설치 시 claude 폴백
2. codex review --mode adversarial [변경 파일]
3. 결과 폴링 (최대 60초, 5초 간격)
4. 타임아웃 시 Claude 폴백 전환
```

#### verify_mode = claude

```
역할: Adversarial Reviewer — 결함 탐색 전문가

검토 관점:
1. AC 통과했지만 목표 의도에서 벗어난 구현
2. 엣지 케이스 / 경계 조건 누락
3. 보안/성능 명백한 결함
4. SPEC 범위 초과 또는 부족
5. 환경 가정 위반 (하드코딩 URL, 고정 경로 등)

출력: ADVERSARIAL PASS 또는 [결함 목록 + HIGH/MED/LOW]
```

결과:
- ADVERSARIAL PASS → 완료 단계 (or 5.5 RESCUE 거치지 않음)
- HIGH 결함 → PLAN 루프백
- MED/LOW 결함 → BUILD 루프백

---

### 5.5단계 — RESCUE (max-loops 임박 시 자동 실행)

**`iteration == max_loops - 1` 이고 VERIFY-3 FAIL 시 자동 진입.**  
마지막 루프 소진 전에 외부 시각으로 탈출 전략을 주입한다.

#### rescue_mode = codex (OPENAI_API_KEY 있을 때)

```
codex review --mode rescue [SPEC.md + FAILED_AC.md + 변경 파일]
```

Codex rescue 모드: "막힌 문제에서 빠져나올 전략을 제안하라"

#### rescue_mode = claude

```
역할: 구원 분석가 — 기존 접근의 근본 문제 탐색

현황:
- 목표: [SPEC Goal]
- 반복 횟수: N회 (마지막 기회)
- 계속 실패하는 AC: [FAILED_AC.md]
- 시도한 수정 이력: [TASK_RESULTS/ 요약]

분석 요청:
1. 현재 접근 방식의 근본적 결함이 무엇인가?
2. 완전히 다른 구현 전략이 있다면 제시하라
3. AC 자체가 잘못 정의된 것은 아닌가?
4. 더 단순한 해결책이 있는가?

출력:
- RESCUE_STRATEGY: [구체적 대안 + 왜 기존 방법이 막혔는지]
- 권장 액션: [PLAN 재설계 | AC 재정의 | 접근법 전환]
```

RESCUE 결과 → LOOP_STATE.md에 `rescue_applied: true` 기록 → 마지막 BUILD-VERIFY 사이클 진행

RESCUE 후에도 실패 → max-loops 초과 처리

---

### max-loops 초과

```
[DEV-LOOPCODE] MAX LOOPS REACHED (N회, RESCUE 시도 포함)
미충족 AC: [FAILED_AC.md]
마지막 VERIFY: VERIFY_REPORT.md
수동 개입이 필요합니다.
```
LOOP_STATE.md: `status: blocked` + 사용자에게 보고.

---

### 6단계 — 완료

#### 6-1. 기본 완료 처리

1. SPEC.md AC `[ ]` → `[x]`
2. FAILED_AC.md 삭제
3. LOOP_STATE.md: `status: done`

#### 6-2. ADR.md 갱신

`ADR.md` 파일이 있으면 완료 시 자동 업데이트. 없으면 새로 생성:

```markdown
# ADR (Architecture Decision Record)

## [날짜] [목표 요약] 구현 완료

### 결정 사항
- 타입: [code|api|app]
- 검증 모드: [Codex|Claude]
- 총 반복: N회
- RESCUE 사용: [yes|no]

### 채택한 접근 방식
[BUILD에서 실제 사용한 핵심 구현 패턴]

### 고려했지만 채택 안 한 방식
[RESCUE 또는 VERIFY에서 나온 대안들]

### 도메인 언어 변경 사항
[CONTEXT.md에 추가/수정이 필요한 용어 (있으면)]
```

#### 6-3. /improve-codebase-architecture 제안

완료된 구현을 검토하여 리팩토링 기회를 제안한다 (적용은 하지 않음):

```
역할: 아키텍처 개선 분석가

검토 대상: [변경된 파일 목록]
원칙: Deep Module (복잡한 구현을 단순한 인터페이스 뒤에 숨긴다)

분석 항목:
1. 과도하게 노출된 내부 구현이 있는가?
2. 단일 책임 원칙 위반 함수/클래스가 있는가?
3. 코드 중복 제거로 단순화할 수 있는 부분
4. CONTEXT.md 도메인 개념으로 표현을 더 명확히 할 수 있는 부분

출력: 우선순위 TOP 3 개선 제안 (변경하지 말고 제안만)
```

제안은 VERIFY_REPORT.md 마지막 `## 리팩토링 제안` 섹션으로 기록하고 사용자에게 요약 보고.

#### 6-4. 최종 보고

```
[DEV-LOOPCODE] COMPLETE
목표: [목표]
타입: [code|api|app] | 검증: [Codex|Claude adversarial]
총 반복: N회 | RESCUE 사용: [yes|no]
통과 AC: N/N

ADR.md 갱신 완료
리팩토링 제안: TOP 3 (VERIFY_REPORT.md 참고)

생성/변경 파일: [목록]
```

5. **위키 저장 (선택)**: SPEC.md의 `wiki_path` 항목 있으면 저장.
6. 사용자에게 완료 보고.

---

## 상태 파일 구조

```
프로젝트 루트/
├── config.json          # 환경 설정 (base_url, server_cmd 등)
├── CONTEXT.md           # 도메인 언어 사전 (선택 — 있으면 grill-with-docs 활성화)
├── ADR.md               # 아키텍처 결정 기록 (완료 시 자동 갱신)
├── SPEC.md              # 목표 + AC + 환경 + 제약
├── TASKS.md             # 태스크 목록 + 의존성
├── LOOP_STATE.md        # 루프 상태 (--resume 지원)
├── FAILED_AC.md         # VERIFY-2 실패 항목 (루프백 시 존재)
├── VERIFY_REPORT.md     # 검증 결과 누적 + 리팩토링 제안
└── TASK_RESULTS/
    ├── T001.md
    └── ...
```

---

## 진행 상황 출력

```
[DEV-LOOPCODE] 시작 | 타입: app | 검증: Claude | CONTEXT.md: 로드됨 | max-loops: 5
[DEV-LOOPCODE] PLAN 완료 → HARD GATE 검사
[DEV-LOOPCODE] HARD GATE PASS (AC 3개 측정 가능)
[DEV-LOOPCODE] BUILD | 병렬: T001, T002 | 순차: T003
[DEV-LOOPCODE] VERIFY-1 | 서버 OK | navigate OK
[DEV-LOOPCODE] VERIFY-2 | AC PASS | DOMAIN PASS (CONTEXT.md 일관성 확인)
[DEV-LOOPCODE] VERIFY-3 adversarial → PASS
[DEV-LOOPCODE] ADR.md 갱신 완료
[DEV-LOOPCODE] 리팩토링 제안 3건 → VERIFY_REPORT.md
[DEV-LOOPCODE] COMPLETE | 총 1회 | AC 3/3

# RESCUE 발동 예시
[DEV-LOOPCODE] 루프 4/5 | RESCUE 발동 — 근본 문제 분석 중
[DEV-LOOPCODE] RESCUE: 접근법 전환 제안 → 마지막 BUILD-VERIFY 시작
```

---

## 흡수한 패턴

| 출처 | 흡수 패턴 | 단계 |
|------|---------|------|
| superpowers/subagent-driven-development | IMPLEMENTER 역할 분리 | BUILD |
| superpowers/dispatching-parallel-agents | depends_on 기반 병렬 | BUILD |
| codex-plugin-cc (review) | adversarial 검토 | VERIFY-3 |
| codex-plugin-cc (rescue) | 막힌 문제 탈출 전략 | RESCUE |
| superpowers/verification-before-completion | VERIFY 없이 완료 불가 | VERIFY-3 |
| gstack/brainstorming (HARD GATE) | AC 품질 게이트 | HARD GATE |
| mattpocock/grill-with-docs | 도메인 언어 일관성 검사 | VERIFY-2 |
| mattpocock/improve-codebase-architecture | 리팩토링 제안 | 완료 |
| mattpocock/adr-writer | 아키텍처 결정 기록 | 완료 |
| dev-loop | SPEC/AC 루프, 사용자 보고 | 전체 |
| dev-hwaloop | LOOP_STATE.md, --resume | 전체 |
