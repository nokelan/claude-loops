# CONTEXT — SI 테스트 자동화 도메인 언어

## 핵심 도메인 용어

| 용어 | 정의 | 금지 동의어 |
|------|------|-----------|
| 테스트케이스 | Excel 한 행 = 액션 단위 | 테스트, TC, case |
| 액션타입 | navigate / input / click / check_text | action, 동작, 타입 |
| 기대결과 | 검증 조건 문자열 (예: "URL contains dashboard") | expected, 결과, 조건 |
| 상태 | PASS / FAIL / RETRY | status, 결과, 판정 |
| 캡처경로 | 스크린샷 절대 경로 | screenshot, 캡처, 이미지 |
| 실제결과 | 검증 실행 후 실제 값 | actual, 결과값 |
| 화면명 | 테스트케이스 식별자 (예: "로그인_버튼클릭") | 이름, name, ID |
| config.json | 환경 설정 파일 (base_url, server_cmd 등) | 설정파일, 환경파일 |
| 세션 크래시 | ChromeDriver 세션 무효화 예외 | 드라이버 오류, 크래시 |
| 루프백 | 검증 실패 시 BUILD 단계 재시도 | 재시도, retry, 반복 |

## 약어 정의

| 약어 | 전체 | 설명 |
|------|------|------|
| RPA | Robotic Process Automation | 자동화 실행기 |
| AC | Acceptance Criteria | 완료 기준 |
| SI | System Integration | 시스템 통합 |
| E2E | End-to-End | 전체 흐름 테스트 |

## 금지 표현

- "테스트 스크립트" → "rpa_runner.py" 또는 "테스트 자동화 실행기"
- "브라우저 자동화" → "Selenium 기반 액션 실행"
- "결과 파일" → "결과 리포트 Excel" 또는 "report.xlsx"
