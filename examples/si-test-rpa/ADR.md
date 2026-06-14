# ADR (Architecture Decision Record)

## 2026-06-14 SI 테스트 자동화 RPA 구현 완료

### 결정 사항
- 타입: app
- 검증 모드: Claude adversarial
- 총 반복: 1회
- RESCUE 사용: no

### 채택한 접근 방식
- Hash routing (#/login, #/dashboard 등): Vue.js SPA를 단일 index.html로 구현, history.pushState 대신 window.location.hash 기반 라우팅으로 Selenium 안정성 확보
- selenium-manager: webdriver_manager 제거, Selenium 4.6+ 내장 아키텍처 자동 탐지 사용 (win64/win32 불일치 해소)
- Select 드롭다운 처리: el.tag_name == "select" 분기 → Select(el).select_by_visible_text()
- navigate_and_verify(): navigate 후 element 존재 확인으로 404 silent fail 방지
- InvalidSessionIdException RETRY: 세션 크래시 시 드라이버 재생성 후 해당 케이스 재시도

### 고려했지만 채택 안 한 방식
- webdriver_manager: win32/win64 불일치로 세션 크래시 → 제거
- Vue Router history 모드: Selenium navigate 불안정 → hash routing 전환
- BASE_URL에 /vue-sample 포함: 서버 루트가 vue-sample/ 자체라 404 → 제거

### 도메인 언어 변경 사항
- grill-with-docs 검사에서 발견: "결과 파일"/"결과 저장" → "결과 리포트 Excel"/"결과 리포트 저장" (rpa_runner.py:306-307 수정 완료)
