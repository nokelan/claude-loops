# SPEC — 문서/보고서 생성 템플릿

## Goal
<!-- 예: 월간 KPI 데이터를 받아 HTML 보고서를 자동 생성하는 스크립트 -->

## Acceptance Criteria
- [ ] AC-1: 입력 CSV → HTML 보고서 단일 파일 출력 (20초 이하)
- [ ] AC-2: 차트/테이블 포함, 브라우저에서 바로 열림
- [ ] AC-3: 한국어 텍스트 깨짐 없음 (UTF-8, word-break: keep-all)

## Output Format
- 파일 형식: <!-- HTML / PDF / Markdown -->
- 브랜드 스타일: <!-- vercel / stripe / 없음 -->
- 저장 경로: <!-- output/ 폴더 -->

## Constraints
- 외부 서버 없이 오프라인 실행 가능
- 차트: Chart.js CDN 허용
- 이미지: base64 인라인 삽입

## Out of Scope
- 이메일 자동 발송
- 데이터베이스 연동
