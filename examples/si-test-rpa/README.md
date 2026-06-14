# si-test-rpa — Selenium E2E 테스트 자동화 (app 타입 예제)

`/dev-loopcode` 전체 파이프라인 실전 예제.  
엑셀에 정의된 테스트케이스를 Selenium으로 자동 실행하고 PASS/FAIL + 화면 캡처를 결과 리포트 Excel에 기록한다.

## 특징

- **타입**: `app` (Selenium RPA)
- **CONTEXT.md 활용**: 도메인 용어 사전 정의 → grill-with-docs 검사 적용
- **ADR.md**: Hash routing, selenium-manager, Select 드롭다운 등 채택 결정 기록
- **RESCUE 미발동**: 12케이스 전부 2회 내 통과

## 빠른 시작

```bash
pip install -r requirements.txt

# 샘플 테스트케이스 생성
python create_sample_excel.py

# Vue 샘플 앱 기동
python -m http.server 5500 --directory vue-sample

# RPA 실행 (별도 터미널)
python rpa_runner.py
```

결과: `results/YYYYMMDD_HHMMSS_report.xlsx`

## 테스트 결과

```
12/12 PASS — 2026-06-14
pytest test_rpa.py: 4/4 PASS
```

## 파이프라인 흐름

```
/dev-loopcode --type app
    ↓
[INIT]      CONTEXT.md 로드 (테스트케이스/액션타입/기대결과 등 도메인 용어)
    ↓
[BUILD]     rpa_runner.py + vue-sample HTML 5개 화면 + create_sample_excel.py
    ↓
[VERIFY-1]  python -m http.server 5500 기동 → GET localhost:5500 → 200
    ↓
[VERIFY-2]  12개 테스트케이스 전부 PASS/FAIL 판정 확인
            + grill-with-docs: "결과 파일" → "결과 리포트 Excel" 도메인 위반 수정
    ↓
[VERIFY-3]  Adversarial — selenium-manager vs webdriver_manager 채택 검토
    ↓
[완료]      ADR.md 갱신 (Hash routing, Select 드롭다운 등 6개 결정 기록)
```
