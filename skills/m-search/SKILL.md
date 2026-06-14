# /m-search — 대화 메모리 검색

과거 Claude 대화를 키워드로 검색하여 텔레그램으로 결과를 전송한다.

## 동작 방식

1. `/m-search <키워드>` 호출 시 바로 검색 실행
2. 키워드 없이 `/m-search` 만 입력하면 텔레그램으로 "검색어를 입력해주세요" 요청
3. `python ${CLAUDE_HOME}/conv_archive.py --search <키워드>` 실행
4. 결과를 텔레그램 chat_id ${TELEGRAM_CHAT_ID} 으로 전송

## 텔레그램 결과 형식

```
[검색] "키워드" — N개 결과

--- [날짜] 프로젝트명 ---
  [나] 검색어 관련 대화 내용 120자...
  [AI] 응답 내용 120자...

--- [날짜] 다른 세션 ---
  ...

세션 전체 보려면: /m-session <session_id>
```

## 세션 전체 조회

`/m-session <session_id>` 또는 `/m-search --session <session_id>` 호출 시:
- `python ${CLAUDE_HOME}/conv_archive.py --session <session_id>` 실행
- 전체 대화 텍스트를 텔레그램으로 전송 (긴 경우 여러 메시지로 분할)

## DB 경로

`${RECORDINGS_DIR}/conv_archive.db`

## 초기 스캔

DB가 비어 있거나 처음 실행 시:
`python ${CLAUDE_HOME}/conv_archive.py --scan` 으로 전체 .jsonl 일괄 import 제안

