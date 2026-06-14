# /design-page — 브랜드 기반 단일 스크롤 HTML 페이지 생성

랜딩페이지·보고서·문서·포트폴리오 등 **스크롤 싱글 페이지** HTML을 생성한다.
16:9 슬라이드가 아님. 16:9 슬라이드/프레젠테이션은 `/frontend-slides` 사용.

## 사용법

```
/design-page vercel          # Vercel 디자인 토큰 기반 페이지
/design-page stripe          # Stripe 디자인 토큰 기반 페이지
/design-page                 # 브랜드 없이 — 직접 색상/폰트 지정
```

**브랜드 DESIGN.md 경로:**
`E:\Harness\awesome-design-md-main\awesome-design-md-main\design-md\<brand>\DESIGN.md`

**사용 가능한 브랜드 (폴더명):**
airbnb, airtable, apple, binance, bmw, cal, claude, clay, clickhouse, coinbase, cursor, elevenlabs, ferrari, figma, framer, intercom, kraken, linear.app, lovable, mastercard, netflix, nike, notion, nvidia, openai, paypal, porsche, raycast, reddit, shopify, slack, spacex, spotify, stripe, supabase, tailwind, tesla, twitter, uber, vercel, youtube, zoom 등 73개

---

## Phase 0: 브랜드 및 페이지 타입 감지

### Step 0.1: 브랜드 감지
- 브랜드명이 주어지면 즉시 DESIGN.md 읽기
- YAML 프론트매터에서 추출: `colors`, `typography`, `rounded`, `spacing`, `components`
- 브랜드 없으면 Step 0.3에서 직접 설정

### Step 0.2: 페이지 타입 감지
사용자 의도에서 자동 감지. 불명확하면 질문:

| 타입 | 용도 | 레이아웃 특징 |
|------|------|--------------|
| **landing** | 제품·서비스 소개 | Hero → Features → Testimonials → CTA |
| **report** | 분석·리포트·백서 | TOC → 섹션별 데이터/차트 → 결론 |
| **document** | 기술 문서·가이드 | 사이드바 네비 → 단계별 내용 |
| **portfolio** | 포트폴리오·작품집 | 그리드 갤러리 → 프로젝트 상세 |

### Step 0.3: 콘텐츠 수집
- 콘텐츠가 있으면 받기
- 없으면 브랜드/타입에 맞는 예시 콘텐츠로 데모 생성
- 이미지 경로가 있으면 base64 인코딩해서 삽입

---

## Phase 1: 브랜드 토큰 → CSS 변수 변환

DESIGN.md에서 추출한 토큰을 CSS 커스텀 프로퍼티로 변환:

```css
:root {
  /* Colors */
  --color-primary: <colors.primary>;
  --color-canvas: <colors.canvas>;
  --color-ink: <colors.ink>;
  --color-body: <colors.body>;
  --color-mute: <colors.mute>;
  --color-hairline: <colors.hairline>;
  --color-link: <colors.link>;

  /* Typography */
  --font-display: <typography.display-xl.fontFamily>;
  --font-body: <typography.body-md.fontFamily>;
  --font-mono: <typography.code.fontFamily or fallback>;

  /* Scale */
  --text-display-xl: <typography.display-xl.fontSize>;
  --text-display-lg: <typography.display-lg.fontSize>;
  --text-body-lg: <typography.body-lg.fontSize>;
  --text-body-md: <typography.body-md.fontSize>;
  --text-body-sm: <typography.body-sm.fontSize>;

  /* Spacing */
  --space-xs: <spacing.xs>;
  --space-sm: <spacing.sm>;
  --space-md: <spacing.md>;
  --space-lg: <spacing.lg>;
  --space-xl: <spacing.xl>;
  --space-section: <spacing.section>;

  /* Rounded */
  --radius-sm: <rounded.sm>;
  --radius-md: <rounded.md>;
  --radius-lg: <rounded.lg>;
  --radius-pill: <rounded.pill>;
}
```

**폰트 로딩:** fontFamily에 명시된 폰트를 Google Fonts 또는 Fontshare에서 import.
- Geist, Inter → `@import url('https://fonts.googleapis.com/css2?family=Inter...')`
- Geist Mono → `@import url(...Geist+Mono...)`

---

## Phase 2: 페이지 생성

### 공통 규칙
- **Zero-dependency**: CDN 없음, 인라인 CSS/JS만 사용 (Chart.js 제외)
- **단일 HTML 파일**: 모든 CSS/JS/이미지(base64) 인라인
- **반응형**: 모바일 우선, breakpoint 768px
- **다크모드**: 브랜드 토큰에 dark 변형이 있으면 `prefers-color-scheme: dark` 지원
- **접근성**: semantic HTML, aria-label, 색상 대비 WCAG AA
- **차트**: 데이터 시각화 필요 시 Chart.js CDN 허용 (`https://cdn.jsdelivr.net/npm/chart.js`)

### 페이지별 레이아웃

#### Landing Page
```
<nav> — 로고 + 링크 + CTA 버튼 (sticky)
<hero> — 대형 헤드라인 + 서브헤드 + CTA + 히어로 이미지/그래픽
<features> — 3~6개 기능 카드 그리드
<social-proof> — 통계/수치 or 고객사 로고 or 후기
<cta-section> — 전환 유도 최종 섹션
<footer> — 링크 + 카피라이트
```

#### Report Page
```
<header> — 제목 + 날짜 + 저자 + 요약
<nav-toc> — 사이드바 또는 인라인 목차 (JS scroll-spy)
<sections> — 각 섹션: 제목 + 본문 + 데이터 시각화
<appendix> — 참고자료/방법론
```

#### Document Page
```
<header> — 문서 제목 + 버전
<sidebar> — 고정 네비게이션 (섹션 링크)
<main> — 단계별 콘텐츠 (코드블록 포함)
<prev-next> — 이전/다음 섹션 링크
```

#### Portfolio Page
```
<hero> — 이름 + 짧은 소개
<work-grid> — 프로젝트 카드 그리드 (hover 상세)
<about> — 기술 스택 + 경력
<contact> — 연락처/링크
```

### 인터랙션 (선택적, 필요 시 포함)
- 스크롤 애니메이션: `IntersectionObserver` 기반 fade-in/slide-up
- 부드러운 스크롤: `scroll-behavior: smooth`
- TOC 하이라이트: scroll-spy로 현재 섹션 강조
- 차트: Chart.js (데이터 수정 가능하도록 config 객체 상단에 노출)

---

## Phase 3: 출력 및 저장

1. **파일 저장**: 작업 디렉토리에 `<brand>-<type>-<topic>.html` 형태로 저장
   - 예: `vercel-landing-saas.html`, `stripe-report-q1.html`
2. **브라우저 열기**: `start <파일명>.html` (Windows)
3. **커스터마이즈 안내**: `:root` CSS 변수 위치, 폰트 교체법, 색상 교체법

---

## Phase 4: Vercel 배포 (선택)

"배포할까요?" 질문 후 진행:

```bash
# frontend-slides의 deploy.sh 재사용
bash "${CLAUDE_HOME}/skills/frontend-slides\scripts\deploy.sh" <파일경로>
```

- Vercel CLI 설치 여부 확인: `npx vercel --version`
- 로그인 확인: `npx vercel whoami`
- 미로그인 시: `https://vercel.com/signup` 안내

---

## 브랜드 없는 경우 처리

`/design-page` (브랜드 없음) 사용 시:
1. 페이지 타입 먼저 선택
2. 색상 팔레트 선택 (다크/라이트/컬러풀)
3. 기본 폰트: Inter + mono 폰트

---

## 주의사항

- 16:9 고정 스테이지 금지 — 스크롤 페이지가 목적
- `overflow: hidden` 전체 페이지에 적용 금지
- 차트 데이터는 HTML 파일 상단 `const CHART_DATA = {...}` 객체로 분리해서 쉽게 수정 가능하게
- 이미지 없을 시 CSS 그래디언트/SVG 패턴으로 시각적 완성도 유지

---

## 한국어 보고서 CSS 규칙

한국어 콘텐츠가 포함된 보고서/문서 페이지 생성 시 반드시 적용.

### 텍스트 처리
- `word-break: keep-all` — 모든 한국어 컨테이너에 적용 (어절 중간 자르기 방지)
- `white-space: nowrap` — 법조문 번호, 코드성 텍스트, 한 줄 유지 필요 컬럼에 적용

### 테이블 컬럼 정렬
```css
td:first-child { font-weight: 600; text-align: center; vertical-align: middle; }
th:first-child { text-align: center; }
td, th { word-break: keep-all; }
/* 특정 컬럼 한 줄 강제 (예: 법조문 컬럼) */
td:nth-child(3), th:nth-child(3) { white-space: nowrap; min-width: 110px; }
```

### Flow-Box 패턴 (단계/상태 라벨 박스)
고정 `width` 금지 — 텍스트 세로 잘림 유발. 올바른 패턴:
```css
.flow-box.primary {
  min-width: 110px;           /* 고정 width 대신 min-width */
  white-space: nowrap;        /* 텍스트 한 줄 강제 */
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
```

### 수직 텍스트 라벨
```css
/* 올바른 방법: vertical-lr (위→아래 정방향) */
writing-mode: vertical-lr;

/* 금지: rotate(180deg) 조합 — 텍스트가 bottom→top으로 역전됨 */
/* writing-mode: vertical-rl; transform: rotate(180deg);  ← 사용 금지 */
```

### 보고서 메타정보 노출 금지
- API 파라미터, 내부 키값, OC 코드 등 기술 메타정보는 HTML 본문에 절대 노출 금지
- 예: `(OC=kjh1029)`, `?serviceKey=...` 등은 출처 주석에서 제거

---

## Phase 5: Impeccable Polish (선택)

HTML 파일 생성 후 자동으로 아래 질문을 한다:

> "impeccable로 품질 검증/개선할까요? (audit · polish · critique)"

사용자가 원하면 해당 명령을 생성된 HTML 파일 경로에 적용한다.

| 명령 | 효과 | 추천 시점 |
|------|------|----------|
| `audit` | WCAG 접근성·색상 대비·타이포그래피 점검 | 배포 전 필수 |
| `critique` | 디자인 비판적 검토 + 구체적 개선 제안 | 초안 완성 후 |
| `polish` | 미세 디테일(간격·정렬·Shadow 등) 완성도 향상 | 최종 마무리 |
| `bolder` | 비주얼 임팩트 강화 (헤드라인·배경·대비) | 발표용·랜딩 |

적용 방법: impeccable SKILL.md를 읽고 해당 서브커맨드 reference 파일을 참조하여 생성된 HTML에 직접 수정을 가한다. 수정 후 브라우저로 결과를 열어 확인한다.

