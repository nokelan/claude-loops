# ADR (Architecture Decision Record)

## 2026-06-14 Python CLI 단어통계 도구 구현 완료

### 결정 사항
- 타입: code
- 검증 모드: Claude adversarial
- 총 반복: 1회
- RESCUE 사용: no

### 채택한 접근 방식
- `re.findall(r"[a-zA-Z가-힣]+", text.lower())`: 단일 정규식으로 구두점 제거 + 소문자 정규화 동시 처리
- `collections.Counter.most_common(5)`: 표준 라이브러리만으로 TOP5 구현
- 표준 라이브러리만 사용: 외부 의존성 0

### 고려했지만 채택 안 한 방식
- `str.split()` 방식: 구두점이 단어에 붙어 "dog."처럼 계산되는 문제
- nltk 토크나이저: 외부 패키지라 SPEC 제약 위반

### 도메인 언어 변경 사항
- 없음 (CONTEXT.md 미사용)
