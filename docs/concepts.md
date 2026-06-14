# 루프 엔지니어링 개념과 dev-loopcode 구현 대조

루프 엔지니어링의 5가지 핵심 구성 요소를 기준으로 dev-loopcode가 각각을 어떻게 구현했는지, 그리고 현재 공백이 어디인지 정리한다.

---

## 5가지 구성 요소 대조표

| 요소 | 설명 | dev-loopcode 구현 | 상태 |
|------|------|-------------------|------|
| **자동화(Automations)** | 정지 조건이 달성될 때까지 AI 반복 실행 | SPEC.md AC 전체 통과 = 루프 종료. HARD GATE + VERIFY 루프가 정지 조건 역할 | 있음 |
| **워크트리(Worktrees)** | 에이전트 간 파일 충돌 없는 격리 환경 | 미구현. `depends_on` 그래프로 실행 순서를 제어해 충돌 우회 중 | 없음 |
| **스킬(Skills)** | 외부화된 지식 — 에이전트가 매번 처음부터 추측 불필요 | SKILL.md + CONTEXT.md + SPEC.md + ADR.md + LOOP_STATE.md | 있음 |
| **플러그인/커넥터** | Linear, Jira, Slack, DB 등 외부 도구 연결 | 텔레그램 MCP, GodotMCP. 이슈트래커 연동은 미구현 | 부분 |
| **서브에이전트(Sub-agents)** | 코드 작성 모델과 검증 모델 분리 (Maker-Checker) | BUILD: IMPLEMENTER 에이전트 × N / VERIFY-3: Adversarial Reviewer / PLAN-DEBATE: Agent-A(설계자) vs Agent-B(비평가) | 있음 |
| **영속적 메모리** | 대화 종료 후에도 상태 유지 | LOOP_STATE.md (--resume 지원) + MEMORY 시스템 + ADR.md | 있음 |

---

## 자동화 — `/goal` 없이 AC로 대체하는 이유

외부에서는 `/goal "테스트 통과"` 같은 명령으로 정지 조건을 선언하는 방식을 쓰기도 한다.  
dev-loopcode는 별도 `/goal` 명령 대신 **SPEC.md의 AC(Acceptance Criteria)** 를 정지 조건으로 삼는다.

```
# SPEC.md
## Acceptance Criteria
- [ ] AC-1: pytest 실행 시 5/5 PASS
- [ ] AC-2: 동점 단어 알파벳 오름차순 출력
```

모든 `[ ]`가 `[x]`로 바뀌면 루프 종료.  
AC가 모호하면 HARD GATE에서 막히고, GOAL INTERVIEW 단계에서 명확해질 때까지 사용자와 재협의한다.

**AC 작성 원칙**: 수치, URL, 파일명, 판정 가능한 텍스트로만 작성한다.  
"잘 동작한다" → HARD GATE FAIL  
"로그인 후 URL이 `#/dashboard`여야 한다" → PASS

---

## 워크트리 — 현재 공백과 우회 전략

여러 IMPLEMENTER 에이전트가 동시에 같은 파일을 수정하면 충돌이 발생할 수 있다.  
현재는 `depends_on` 그래프로 실행 순서를 제어해 충돌을 방지한다:

```
# TASKS.md 예시
T001: 데이터 모델 정의     depends_on: []       → 병렬 가능
T002: API 엔드포인트 구현  depends_on: [T001]   → T001 완료 후
T003: 프론트엔드 연결      depends_on: [T002]   → T002 완료 후
```

같은 파일을 건드리는 태스크는 `depends_on`으로 순차 실행을 강제한다.  
향후 병렬 에이전트 수가 늘어나면 Git worktree 기반 격리 도입을 고려한다.

---

## 서브에이전트 — Maker-Checker 구조

dev-loopcode의 서브에이전트 구조:

```
[PLAN-DEBATE]
  Agent-A (설계자)  →  초안 설계
  Agent-B (비평가)  →  반박 및 개선 요청
  → 사용자 확정 → SPEC.md

[BUILD]
  IMPLEMENTER-1  →  T001 구현
  IMPLEMENTER-2  →  T002 구현 (병렬)
  ...

[VERIFY-3]
  Adversarial Reviewer  →  구현자와 독립된 시각으로 결함 탐색
```

"만드는 에이전트"와 "검증하는 에이전트"를 분리함으로써 구현자 편향 없이 품질을 검사한다.

---

## 현재 미구현 — 추가 고려 항목

| 항목 | 현재 우회 방법 | 추가 시 이점 |
|------|-------------|------------|
| Worktrees | depends_on 순서 제어 | 진짜 병렬 구현 가능, 충돌 원천 차단 |
| Linear/Jira 연동 | 없음 | 이슈 트래커에서 직접 AC 가져오기 |
| `/goal` 명령 | SPEC.md AC로 대체 | 빠른 일회성 목표 설정 편의성 |
