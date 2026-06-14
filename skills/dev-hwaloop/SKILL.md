---
name: dev-hwaloop
description: "목표를 입력받아 2-에이전트 토론으로 설계하고, build→verify 루프를 자동 완주하는 오케스트레이터"
---

# /dev-hwaloop — 루프 오케스트레이터

목표 하나를 입력받아 완료될 때까지 전체 파이프라인을 자동 감독한다.
사람은 목표를 주고 결과만 받는다.

## Usage

```
/dev-hwaloop "목표 설명"
/dev-hwaloop "목표" --max-loops 5 --max-rounds 4
/dev-hwaloop --resume          (SPEC.md가 이미 있을 때 중간부터 재개)
```

## Pipeline

```
[입력: 목표]
     │
     ▼
 ┌────────────────────────────────────┐
 │  PLAN-DEBATE (핵심 — 설계 토론)    │
 │  Round N:                          │
 │    Agent-A (설계자) → draft        │
 │    Agent-B (비평가) → critique     │
 │  오케스트레이터 판단:              │
 │    미흡 → 다음 라운드              │
 │    충분 → SPEC.md + TASKS.md 확정  │
 └──────────────┬─────────────────────┘
                │
     [WSL tmux 3창 — 사용자 관전 가능]
                │
                ▼
 ┌─────────────────┐
 │ LOOP-SUPERVISOR │  갭 분석 + 자동 패치 ◄──────────────┐
 └────┬────────────┘                                     │
      │ PASS                                             │
      ▼                                                  │ FAIL
 ┌───────┐                                               │
 │ BUILD │  에이전트 분산 실행                             │
 └───┬───┘                                               │
     │                                                   │
     ▼                                                   │
 ┌────────┐                                              │
 │ VERIFY │  AC 검증 ─────────────────────────────────────┘
 └───┬────┘
     │ PASS
     ▼
  [완료 보고 + 텔레그램 알림]
```

## Instructions

사용자가 이 스킬을 호출하면 아래 단계를 **자동으로, 순서대로** 실행한다.
각 단계 사이에 허락을 구하지 않는다.
단, BLOCKED 또는 max-loops 초과 시에만 멈추고 사용자에게 보고한다.

---

### 0단계 — 초기화

파라미터 파싱:
- `목표`: 첫 번째 인수 또는 사용자 메시지
- `--max-loops N`: 빌드-검증 루프 최대 횟수 (기본 3)
- `--max-rounds N`: 토론 라운드 최대 횟수 (기본 3)
- `--resume`: SPEC.md가 있으면 plan-debate 스킵, 직전 상태부터 재개

출력:
```
[DEV-HWALOOP] 시작
목표: [목표]
작업 디렉토리: [CWD]
max-loops: N | max-rounds: N
```

`LOOP_STATE.md` 생성:
```markdown
# LOOP STATE
- goal: [목표]
- iteration: 0
- current_step: plan-debate
- debate_round: 0
- status: running
- started: [날짜]
- max_loops: N
- max_rounds: N
```

`DEBATE/` 디렉토리 생성.

---

### 1단계 — PLAN-DEBATE (tmux 뷰어 + 2-에이전트 토론)

#### 1-1. WSL tmux 뷰어 실행

PowerShell로 다음 실행:
```powershell
$wslDir = (wsl wslpath -u "[CWD]").Trim()
wsl -e bash "${CLAUDE_HOME}/skills/dev-hwaloop/scripts/start_tmux.sh" "$wslDir"
```

실행 후 텔레그램으로 알림:
```
[DEV-HWALOOP] 토론 시작
wsl -e tmux attach -t dev-hwaloop
으로 실시간 관전 가능합니다.
```

#### 1-2. 토론 라운드 실행

**라운드는 최대 max_rounds회 반복한다. (기본 3)**

각 라운드:

**Agent-A (설계자) 실행:**

다음 프롬프트로 Agent 호출:
```
역할: 소프트웨어 설계자 (Agent-A)

목표: [목표]
라운드: N

[라운드 1이면]
목표를 분석하여 초기 설계 초안을 작성하라.
포함 내용:
- 핵심 기능 목록
- 기술 접근 방식
- 주요 컴포넌트 구조
- 예상 Acceptance Criteria (측정 가능하게)
- 예상 위험 요소

[라운드 2+이면]
이전 비평을 반영하여 설계를 개선하라.
이전 설계: [DEBATE/round_{N-1}_designer.md 내용]
비평: [DEBATE/round_{N-1}_critic.md 내용]

개선 사항을 명확히 표시하라. (▶ 변경됨)
```

결과를 `DEBATE/round_N_designer.md`에 저장.
WSL 파일에도 동기 기록:
```powershell
wsl -e bash -c "echo '[라운드 N — Agent-A 설계]' >> [wslDir]/DEBATE/designer.md && cat [wslDir]/DEBATE/round_N_designer.md >> [wslDir]/DEBATE/designer.md && echo '' >> [wslDir]/DEBATE/designer.md"
```

**Agent-B (비평가) 실행:**

다음 프롬프트로 Agent 호출:
```
역할: 소프트웨어 비평가 (Agent-B)

목표: [목표]
라운드: N
설계 초안: [DEBATE/round_N_designer.md 내용]

설계의 약점을 날카롭게 지적하라.
다음 관점에서 검토:
1. 모호한 요구사항 — 측정 불가 기준
2. 기술 위험 — 구현 난이도 과소평가
3. 누락된 기능 — 목표 달성에 필수인데 빠진 것
4. 과도한 범위 — 지금 당장 불필요한 것
5. 의존성 위험 — 외부 의존성, 환경 가정

각 지적마다: [문제] → [구체적 개선 방향] 형식으로 작성.
건설적이되 타협하지 말 것.
```

결과를 `DEBATE/round_N_critic.md`에 저장 및 WSL 동기.

**오케스트레이터 판단:**

두 파일을 읽고 판단:
```
설계: [DEBATE/round_N_designer.md]
비평: [DEBATE/round_N_critic.md]

판단 기준:
- Acceptance Criteria가 모두 측정 가능한가?
- 비평의 치명적 지적이 해소되었는가?
- 목표 달성에 충분한 설계인가?
```

판단 결과를 `DEBATE/orchestrator.md`에 추가:
```markdown
## 라운드 N 판단
상태: 충분 / 미흡
미흡 이유: [있으면 기재]
다음 라운드 지시: [있으면 구체적으로]
```

- **충분** → 1-3으로 이동
- **미흡 + 라운드 < max_rounds** → 다음 라운드
- **미흡 + 라운드 >= max_rounds** → 최선의 초안으로 강제 확정 후 계속

#### 1-3. SPEC.md + TASKS.md 확정

최종 설계 초안(마지막 round_N_designer.md)과 비평을 종합하여
${CLAUDE_HOME}/skills/plan\SKILL.md의 Step 2~3 형식으로
**SPEC.md**와 **TASKS.md**를 생성한다.

완료 후:
- LOOP_STATE.md 업데이트: `current_step: loop-supervisor`
- 텔레그램 알림: `[DEV-HWALOOP] PLAN-DEBATE 완료 (N라운드) → LOOP-SUPERVISOR 시작`

출력:
```
[DEV-HWALOOP] Iteration 1 | PLAN-DEBATE 완료
총 N라운드 토론 → SPEC.md + TASKS.md 확정
→ LOOP-SUPERVISOR 시작
```

---

### 2단계 — LOOP-SUPERVISOR

${CLAUDE_HOME}/skills/loop-supervisor\SKILL.md 를 Read하여 Instructions를 수행한다.

**PASS** → LOOP_STATE.md 업데이트: `current_step: build` → 3단계로
**BLOCKED** → 즉시 중단:
```
[DEV-HWALOOP] BLOCKED (Iteration N)
해결 불가 갭 — 수동 개입 필요:
[갭 목록]
```
텔레그램으로 동일 내용 전송.

---

### 3단계 — BUILD

${CLAUDE_HOME}/skills/build\SKILL.md 를 Read하여 Instructions를 수행한다.

LOOP_STATE.md 업데이트: `current_step: verify`

---

### 4단계 — VERIFY

${CLAUDE_HOME}/skills/verify\SKILL.md 를 Read하여 Instructions를 수행한다.

**PASS** → 5단계로
**FAIL + iteration < max_loops** → iteration++ 후 2단계로 루프백
**FAIL + iteration >= max_loops** → 중단:
```
[DEV-HWALOOP] MAX LOOPS REACHED (N회)
미충족 AC: [목록]
수동 개입이 필요합니다.
```
텔레그램으로 동일 내용 전송.

---

### 5단계 — 완료

```
[DEV-HWALOOP] COMPLETE
목표: [목표]
총 토론 라운드: N회
총 빌드 반복: N회

완료된 AC:
- [AC-1]: PASS
- [AC-2]: PASS

생성된 파일:
- [파일 목록]
```

LOOP_STATE.md: `status: done`

텔레그램으로 동일 내용 전송.

tmux 세션은 유지 (사용자가 `tmux kill-session -t dev-hwaloop`로 종료).

---

## 진행상황 출력 형식

```
[DEV-HWALOOP] Iteration N | PLAN-DEBATE Round M
[DEV-HWALOOP] Agent-A 설계 완료 → Agent-B 비평 시작
[DEV-HWALOOP] 오케스트레이터 판단: 미흡 → Round 2
[DEV-HWALOOP] PLAN-DEBATE 완료 (3라운드) → LOOP-SUPERVISOR 시작
[DEV-HWALOOP] LOOP-SUPERVISOR PASS → BUILD 시작
[DEV-HWALOOP] BUILD DONE (성공 5/실패 1) → VERIFY 시작
[DEV-HWALOOP] VERIFY FAIL → Iteration 2 재시작
[DEV-HWALOOP] COMPLETE
```

