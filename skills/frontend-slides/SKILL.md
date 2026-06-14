---
name: frontend-slides
description: Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files. Use when the user wants to build a presentation, convert a PPT/PPTX to web, or create slides for a talk/pitch. Helps non-designers discover their aesthetic through visual exploration rather than abstract choices.
---

# Frontend Slides

Create zero-dependency, animation-rich HTML presentations that run entirely in the browser.

## Core Principles

1. **Zero Dependencies** — Single HTML files with inline CSS/JS. No npm, no build tools.
2. **Show, Don't Tell** — Generate visual previews, not abstract choices. People discover what they want by seeing it.
3. **Distinctive Design** — No generic "AI slop." Every presentation must feel custom-crafted.
4. **Progressive Disclosure** — Read lightweight style indexes first. For bold templates, use small preview cards for style previews and load the full `design.md` only after the user picks that template.
5. **Fixed 16:9 Stage (NON-NEGOTIABLE)** — Every deck uses a 1920×1080 slide canvas scaled as a whole to the viewport. Slides must stay 16:9 on every screen, including phones. Do not reflow slide content to fit the device.

## Design Aesthetics

You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

Focus on:

- Typography: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.
- Color & Theme: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes. Draw from IDE themes and cultural aesthetics for inspiration.
- Motion: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions.
- Backgrounds: Create atmosphere and depth rather than defaulting to solid colors. Layer CSS gradients, use geometric patterns, or add contextual effects that match the overall aesthetic.

Avoid generic AI-generated aesthetics:

- Overused font families (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

Interpret creatively and make unexpected choices that feel genuinely designed for the context. Vary between light and dark themes, different fonts, different aesthetics. You still tend to converge on common choices (Space Grotesk, for example) across generations. Avoid this: it is critical that you think outside the box!

## Fixed Stage Rules

These invariants apply to EVERY slide in EVERY presentation:

- Every deck has a viewport wrapper that fills the browser window.
- Every slide is authored inside a fixed 1920×1080 stage.
- The stage scales uniformly to fit the viewport. It may letterbox/pillarbox; it must not re-layout content.
- Do not use responsive breakpoints to rearrange slide content for phones.
- Use fixed internal slide measurements at the 1920×1080 design size.
- Slide visibility must be controlled by `.active` / `.visible` using `visibility`, `opacity`, and `pointer-events` from `viewport-base.css`. Do not use `display: none` / `display: block` for slide switching; later layout classes such as `.slide-content { display: flex; }` can override them and make every slide visible at once.
- Use `clamp()` only for non-slide UI outside the stage, or for small fallback previews where a full stage is impractical.
- Include `prefers-reduced-motion` support
- Never negate CSS functions directly (`-clamp()`, `-min()`, `-max()` are silently ignored) — use `calc(-1 * clamp(...))` instead

**When generating, read `viewport-base.css` and include its full contents in every presentation.**

### Content Density Modes

Ask the user whether this is primarily a reading deck or a speaking deck, then design around that answer:

| Density mode | Best for | Design behavior |
| ------------- | -------- | --------------- |
| **Low density / speaker-led** | Public talks, keynote-style sharing, live explanation | One idea per slide, large type, strong visual hierarchy, generous negative space, 1-3 bullets max, more slides if needed |
| **High density / reading-first** | Reports, handouts, async review, detailed internal docs | More self-contained slides, structured grids/tables/annotations, 4-8 bullets or 4-6 cards when readable, tighter but still intentional spacing |

Baseline limits still apply: no scrolling, no overflow, no overlapping panels, and no text below comfortable reading size. If content exceeds the selected density mode, split it into more slides instead of shrinking until it becomes cramped.

---

## Awesome-Design-MD Brand System

73개 브랜드 DESIGN.md 컬렉션: `E:\Harness\awesome-design-md-main\awesome-design-md-main\design-md\<brand>\DESIGN.md`

사용 가능한 브랜드 (폴더명 그대로 사용):
airbnb, airtable, apple, binance, bmw, bmw-m, bugatti, cal, claude, clay, clickhouse, cohere, coinbase, composio, cursor, dell-1996, elevenlabs, expo, ferrari, figma, framer, hashicorp, hp, ibm, intercom, kraken, lamborghini, linear.app, lovable, mastercard, mercedes, microsoft, netflix, next.js, nike, notion, nvidia, openai, palantir, paypal, porsche, raycast, reddit, rolex, samsung, sentry, servicenow, shopify, slack, spacex, spotify, stripe, supabase, tailwind, tesla, threads, tiffany, twitter, uber, vertex-ai, vercel, vscode, windows-11, workday, x-twitter, youtube, zoom, …など

**DESIGN.md 구조:**
- YAML 프론트매터: `colors`, `typography`, `rounded`, `spacing`, `components`
- Markdown 섹션: design rationale, usage examples
- 모든 색상 토큰은 hex값 직접 사용, typography는 fontFamily/fontSize/fontWeight/lineHeight/letterSpacing 포함

**브랜드 모드 활성화 조건:**
- `/frontend-slides vercel` — 브랜드명을 직접 지정한 경우
- 사용자가 "vercel 스타일로" 또는 "stripe 느낌으로" 언급한 경우

**브랜드 모드 처리:**
1. 브랜드 DESIGN.md 읽기: `E:\Harness\awesome-design-md-main\awesome-design-md-main\design-md\<brand>\DESIGN.md`
2. 색상·폰트·간격·컴포넌트 토큰 추출
3. Phase 2 스타일 미리보기 중 첫 번째 옵션(Style A)에 해당 브랜드 토큰 적용
4. 나머지 두 옵션(Style B, C)은 브랜드 팔레트를 유지하되 다른 레이아웃/무드 변형

---

## Phase 0: Detect Mode

Determine what the user wants:

- **Mode A: New Presentation** — Create from scratch. Go to Phase 1.
- **Mode B: PPT Conversion** — Convert a .pptx file. Go to Phase 4.
- **Mode C: Enhancement** — Improve an existing HTML presentation. Read it, understand it, enhance. **Follow Mode C modification rules below.**

**Brand Mode Check:** 먼저 입력에 브랜드명이 포함되어 있는지 확인한다. 브랜드명이 있으면 DESIGN.md를 미리 읽어 Phase 2에서 Style A로 활용한다.

### Mode C: Modification Rules

When enhancing existing presentations, fixed-stage fitting is the biggest risk:

1. **Before adding content:** Count existing elements, check against density limits
2. **Adding images:** Fit them inside the 1920×1080 slide canvas. If slide already has max content, split into two slides
3. **Adding text:** Max 4-6 bullets per slide. Exceeds limits? Split into continuation slides
4. **After ANY modification, verify:** the slide stage remains 16:9, no text overflows its card, no panels overlap, and screenshots look correct at 1280×720 plus one phone viewport
5. **Proactively reorganize:** If modifications will cause overflow, automatically split content and inform the user. Don't wait to be asked

**When adding images to existing slides:** Move image to a new slide or reduce other content first. Never add images without checking if existing content already fills the 1920×1080 slide stage.

---

## Phase 1: Content Discovery (New Presentations)

**Ask ALL questions together** so the user fills everything out at once. If the current environment provides a native structured-question UI, use it; otherwise ask in one concise message with clearly numbered choices:

**Question 1 — Purpose** (header: "Purpose"):
What is this presentation for? Options: Pitch deck / Teaching-Tutorial / Conference talk / Internal presentation

**Question 2 — Length** (header: "Length"):
Approximately how many slides? Options: Short 5-10 / Medium 10-20 / Long 20+

**Question 3 — Content** (header: "Content"):
Do you have content ready? Options: All content ready / Rough notes / Topic only

**Question 4 — Density** (header: "Density"):
How dense should the deck feel? Options:

- "Low density / speaker-led" — Big ideas, fewer words, more visual breathing room
- "High density / reading-first" — More self-contained detail for async reading

**Question 5 — Font** (header: "Font"):
폰트를 지정하시겠습니까? Options:
- "브랜드 자동" — 브랜드 DESIGN.md 토큰 or 콘텐츠 분위기에 맞게 자동 선택
- "직접 지정" — 폰트 이름 입력 (Google Fonts 또는 Fontshare에서 검색)
- "시스템 기본" — 시스템 폰트 사용 (빠른 렌더링)

직접 지정 시: 사용자가 입력한 폰트명이 Google Fonts(`https://fonts.google.com/`) 또는 Fontshare(`https://www.fontshare.com/`)에 존재하면 @import로 로드. 없으면 유사 폰트 3개를 제안.

**Do not ask about inline editing during Phase 1.** Users should not have to choose editing behavior before seeing a draft. Inline editing is a post-draft affordance: include it by default unless the user explicitly asks for a locked/export-only file.

Remember the user's density choice. It affects slide count, typography scale, amount of text per slide, layout density, and whether to favor cinematic presenter slides or self-contained reading slides.

If user has content, ask them to share it.

### Step 1.2: Image Evaluation (if images provided)

If user selected "No images" → skip to Phase 2.

If user provides an image folder:

1. **Scan** — List all image files (.png, .jpg, .svg, .webp, etc.)
2. **Inspect each image** — Use the agent's available image-understanding capability. If image reading is unavailable, use filenames/metadata and ask the user to clarify only when needed
3. **Evaluate** — For each: what it shows, USABLE or NOT USABLE (with reason), what concept it represents, dominant colors
4. **Co-design the outline** — Curated images inform slide structure alongside text. This is NOT "plan slides then add images" — design around both from the start (e.g., 3 screenshots → 3 feature slides, 1 logo → title/closing slide)
5. **Confirm the outline** using the same structured-question mechanism when available: "Does this slide outline and image selection look right?" Options: Looks good / Adjust images / Adjust outline

**Logo in previews:** If a usable logo was identified, embed it (base64) into each style preview in Phase 2 — the user sees their brand styled three different ways.

---

## Phase 2: Style Discovery

**This is the "show, don't tell" phase.** Most people can't articulate design preferences in words.

### Step 2.0: Generate 3 Style Previews Directly

Based on purpose, audience, mood, and content density, generate 3 distinct single-slide HTML previews showing typography, colors, animation, and overall aesthetic.

Do not ask the user whether they want options or a preset picker. The default discovery experience is always visual comparison.

If the user already gave a vibe, use it. If they did not, infer the likely mood from the occasion, audience, content, and stakes. Keep the options diverse enough that the user can react visually instead of needing to articulate taste up front.

If the user explicitly names a preset or bold template, honor that as one option and generate the remaining preview slots around it.

Read [STYLE_PRESETS.md](STYLE_PRESETS.md) for safe preset candidates. If [bold-template-pack/selection-index.json](bold-template-pack/selection-index.json) exists, read that compact index too, but do not read any `design.md` files yet.

| Mood                | Suggested Presets                                  |
| ------------------- | -------------------------------------------------- |
| Impressed/Confident | Bold Signal, Electric Studio, Dark Botanical       |
| Excited/Energized   | Creative Voltage, Neon Cyber, Split Pastel         |
| Calm/Focused        | Notebook Tabs, Paper & Ink, Swiss Modern           |
| Inspired/Moved      | Dark Botanical, Vintage Editorial, Pastel Geometry |

**Preview mix rules:**

- Generate 3 previews by default: 1 safe preset from `STYLE_PRESETS.md`, at least 1 bold template from `bold-template-pack/selection-index.json`, and 1 wildcard.
- The wildcard may be either a second bold template or a self-generated custom design. Choose whichever creates the strongest, most useful contrast for the user's occasion, audience, mood, and content.
- Do not force every expressive option to come from the template library. If the brief has a sharper, more specific design opportunity than the available templates, use the wildcard slot to design freely.
- For conservative or high-stakes decks, make the safe preset especially restrained; choose a calm, higher-formality bold template; make the wildcard either another restrained template or a custom design that feels authoritative rather than decorative.
- For expressive decks, keep the safe preset as a readable fallback; choose one strong bold template; make the wildcard adventurous, context-specific, and clearly different from both other previews.
- If bold template matches feel weak, use the wildcard as a custom design or fall back to another safe preset instead of forcing a template.

**Custom wildcard design rules:**

- Follow the Design Aesthetics section above: no generic "AI slop", no default font/color/layout choices, no purple-gradient-on-white clichés, no cookie-cutter dashboard/card look.
- Match the user's stated occasion, audience, mood/vibe, and content density. The custom design should feel authored for this deck, not merely "stylish."
- Make a deliberate visual thesis: distinctive typography, a committed palette, a recognizable layout system, and one strong atmospheric or graphic device.
- Keep it feasible for a full deck. The preview must imply a design system that can expand into section, content, quote, comparison, and closing slides.
- Use fixed 1920×1080 stage rules and pass the same preview authenticity checks as every other option.
- Never render "custom", "wildcard", "AI-generated", or design-process labels on the slide itself.

**Bold template selection rules:**

- Match user purpose and mood against `mood`, `tone`, `best_for`, `avoid_for`, `formality`, `density`, and `scheme`.
- Treat `best_for` examples as soft signals, not strict industry filters.
- Keep the three previews genuinely different from each other.
- After choosing bold template candidate(s), read only those candidate(s)' `preview.md` files from the `preview_md` paths in the selection index.
- Use `preview.md` only for title-slide previews. Do not read full `design.md` files until the user picks the final template.
- Do not read or copy `template.html` unless the selected final `design.md` is missing a critical implementation detail.

**Preview authenticity rules (NON-NEGOTIABLE):**

- Every style preview must look like a real first slide from the user's deck, not a diagnostic card.
- Never render internal workflow text on a slide: no `preview`, `generated from`, `preview.md`, `template`, `preset`, `style option`, `Option A/B/C`, file names, paths, or source-doc labels.
- Never render template names or slug names on the slide itself. Template/style names belong only in the message to the user.
- Never render user requirement notes as slide content, such as "sharp and provocative", "safe option", "bold option", "for internal sharing", or "audience: ...", unless the user explicitly wants that exact phrase to appear in the deck.
- If the slide needs chrome, use real deck chrome only: the deck title, section title, date, author, company, page number, or a genuine content phrase from the user's material.
- Before opening previews, inspect the visible text and revise if any internal metadata appears.

Save previews to `.frontend-slides/slide-previews/` (style-a.html, style-b.html, style-c.html). Each should be self-contained and compact, showing one animated title slide.

Open each preview automatically for the user.

### Step 2.1: User Picks

Ask (header: "Style"):
Which style preview do you prefer? Options: Style A: [Name] / Style B: [Name] / Style C: [Name] / Mix elements

If "Mix elements", ask for specifics.

---

## Phase 3: Generate Presentation

Generate the full presentation using content from Phase 1 (text, or text + curated images) and style from Phase 2.

If images were provided, the slide outline already incorporates them from Step 1.2. If not, CSS-generated visuals (gradients, shapes, patterns) provide visual interest — this is a fully supported first-class path.

Apply the user's density choice throughout the deck:

- **Low density / speaker-led:** Use more slides with fewer ideas per slide. Favor large headings, short phrases, visual metaphors, section beats, quote/statement slides, and presenter-friendly pacing.
- **High density / reading-first:** Make slides more self-contained. Use structured grids, comparison tables, annotated diagrams, captions, and concise explanatory copy. Keep hierarchy strong so it feels designed, not like a document pasted onto slides.

If the user's stated needs are mixed, choose the closer of the two modes instead of inventing a middle option: live audience persuasion defaults low-density; async circulation or detailed review defaults high-density.

Never let high density become visual clutter. If a high-density slide starts to overflow, split it or redesign it into a clearer structure.

If the user selected a bold template from `bold-template-pack`, read that one template's full `design.md` before generating. Do not read the other bold templates. Treat `design.md` as the design recipe:

- Preserve its fonts, palette, decorative vocabulary, spacing rhythm, and component grammar.
- Generate the final deck as a fixed 1920×1080 stage scaled uniformly to the viewport, regardless of whether the source template originally used `deck-stage.js` or viewport-fluid CSS.
- Treat viewport-fluid values in `design.md` as design proportions to translate into 1920×1080 stage coordinates. Do not keep them as live viewport reflow rules in the final deck.
- Keep the output as a single self-contained Frontend Slides HTML file.
- Do not copy demo slide content or mimic the source template too literally.
- Use `template.html` only as a last-resort implementation reference for the selected template.
- After generating, verify both content overflow and panel overlap in rendered browser screenshots. `scrollHeight` checks alone are not enough because grid panels can visually cover each other.

If the user selected a self-generated custom wildcard, treat that preview's CSS and layout as the design recipe:

- Preserve its fonts, palette, decorative vocabulary, spacing rhythm, grid logic, and component grammar.
- Expand the same visual system across the full deck. Do not switch to a preset or bold template after the user has chosen the custom direction.
- Design any missing slide layouts from that system rather than importing patterns from another style.
- Keep the output fixed-stage, single-file, and visually verified like every other deck.

**Before generating, read these supporting files:**

- [html-template.md](html-template.md) — HTML architecture and JS features
- [viewport-base.css](viewport-base.css) — Mandatory CSS (include in full)
- [animation-patterns.md](animation-patterns.md) — Animation reference for the chosen feeling

**Key requirements:**

- Single self-contained HTML file, all CSS/JS inline
- Include the FULL contents of viewport-base.css in the `<style>` block
- Use fonts from Fontshare or Google Fonts — never system fonts
- Add detailed comments explaining each section
- Every section needs a clear `/* === SECTION NAME === */` comment block

---

## Phase 4: PPT Conversion

When converting PowerPoint files:

1. **Extract content** — Run `python scripts/extract-pptx.py <input.pptx> <output_dir>` (install python-pptx if needed: `pip install python-pptx`)
2. **Confirm with user** — Present extracted slide titles, content summaries, and image counts
3. **Style selection** — Proceed to Phase 2 for style discovery
4. **Generate HTML** — Convert to chosen style, preserving all text, images (from assets/), slide order, and speaker notes (as HTML comments)

---

## Phase 5: Delivery

1. **Clean up** — Delete `.frontend-slides/slide-previews/` if it exists
2. **Open** — Use `open [filename].html` to launch in browser
3. **Summarize** — Tell the user:
   - File location, style name, slide count
   - Navigation: Arrow keys, Space, swipe/tap if enabled
   - How to customize: `:root` CSS variables for colors, font link for typography, `.reveal` class for animations
   - Inline text editing is available: Hover top-left corner or press E to enter edit mode, click any text to edit, Ctrl+S to save
   - Offer the natural post-draft actions: ask for revisions, edit text directly in the browser, or export/share

---

## Phase 6: Share & Export (Optional)

After delivery, **ask the user:** _"Would you like to share this presentation? I can deploy it to a live URL (works on any device including phones) or export it as a PDF."_

Options:

- **Deploy to URL** — Shareable link that works on any device
- **Export to PDF** — Universal file for email, Slack, print
- **Export to PPTX** — Editable PowerPoint (charts editable in Excel, font: 맑은 고딕 default)
- **No thanks**

If the user declines, stop here. If they choose one or both, proceed below.

### 6A: Deploy to a Live URL (Vercel)

This deploys the presentation to Vercel — a free hosting platform. The link works on any device (phones, tablets, laptops) and stays live until the user takes it down.

**If the user has never deployed before, guide them step by step:**

1. **Check if Vercel CLI is installed** — Run `npx vercel --version`. If not found, install Node.js first (`brew install node` on macOS, or download from https://nodejs.org).

2. **Check if user is logged in** — Run `npx vercel whoami`.
   - If NOT logged in, explain: _"Vercel is a free hosting service. You need an account to deploy. Let me walk you through it:"_
     - Step 1: Ask user to go to https://vercel.com/signup in their browser
     - Step 2: They can sign up with GitHub, Google, email — whatever is easiest
     - Step 3: Once signed up, run `vercel login` and follow the prompts (it opens a browser window to authorize)
     - Step 4: Confirm login with `vercel whoami`
   - Wait for the user to confirm they're logged in before proceeding.

3. **Deploy** — Run the deploy script:

   ```bash
   bash scripts/deploy.sh <path-to-presentation>
   ```

   The script accepts either a folder (with index.html) or a single HTML file.

4. **Share the URL** — Tell the user:
   - The live URL (from the script output)
   - That it works on any device — they can text it, Slack it, email it
   - To take it down later: visit https://vercel.com/dashboard and delete the project
   - The Vercel free tier is generous — they won't be charged

**⚠ Deployment gotchas:**

- **Local images/videos must travel with the HTML.** The deploy script auto-detects files referenced via `src="..."` in the HTML and bundles them. But if the presentation references files via CSS `background-image` or unusual paths, those may be missed. **Before deploying, verify:** open the deployed URL and check that all images load. If any are broken, the safest fix is to put the HTML and all its assets into a single folder and deploy the folder instead of a standalone HTML file.
- **Prefer folder deployments when the presentation has many assets.** If the presentation lives in a folder with images alongside it (e.g., `my-deck/index.html` + `my-deck/logo.png`), deploy the folder directly: `bash scripts/deploy.sh ./my-deck/`. This is more reliable than deploying a single HTML file because the entire folder contents are uploaded as-is.
- **Filenames with spaces work but can cause issues.** The script handles spaces in filenames, but Vercel URLs encode spaces as `%20`. If possible, avoid spaces in image filenames. If the user's images have spaces, the script handles it — but if images still break, renaming files to use hyphens instead of spaces is the fix.
- **Redeploying updates the same URL.** Running the deploy script again on the same presentation overwrites the previous deployment. The URL stays the same — no need to share a new link.

### 6C: Export to PPTX (수정 가능한 PowerPoint)

HTML 슬라이드를 python-pptx로 PowerPoint 파일로 변환한다. 차트는 네이티브 PowerPoint 차트(Excel 데이터 편집 가능)로 생성된다.

**사전 조건:**
```bash
pip install python-pptx
```

**변환 스크립트 실행:**
```bash
python scripts/export-pptx.py <path-to-html> [output.pptx]
```

**스크립트가 하는 일:**
1. HTML에서 `.slide` 요소를 순서대로 파싱
2. 각 슬라이드에서 제목(`h1`, `h2`), 본문(`p`, `li`), 이미지(`img`) 추출
3. HTML에 `CHART_DATA` JS 객체가 있으면 python-pptx ChartData API로 네이티브 차트 생성
4. 슬라이드 레이아웃: 1920×1080 → PowerPoint 33.87cm × 19.05cm 비율 유지
5. 폰트: Phase 1에서 사용자가 지정한 폰트로 설정. 없으면 맑은 고딕(Malgun Gothic) 기본값

**차트 변환:**
- HTML의 Chart.js 설정(`CHART_DATA` 또는 `new Chart(...)`)을 탐지
- 차트 타입 매핑: `bar` → `BAR`, `line` → `LINE`, `pie` → `PIE`, `doughnut` → `DOUGHNUT`
- python-pptx `ChartData`에 레이블/시리즈 데이터 삽입 → PowerPoint에서 "데이터 편집" 클릭 시 Excel 시트로 수정 가능

**스크립트 자동 생성:**
`scripts/export-pptx.py`가 없으면 생성:

```python
# scripts/export-pptx.py — HTML → PPTX 변환
# 의존성: pip install python-pptx beautifulsoup4

import sys, re, json
from pathlib import Path
from bs4 import BeautifulSoup
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.chart import XL_CHART_TYPE
from pptx.chart.data import ChartData

SLIDE_W = Inches(33.87 / 2.54)
SLIDE_H = Inches(19.05 / 2.54)

CHART_TYPE_MAP = {
    'bar': XL_CHART_TYPE.COLUMN_CLUSTERED,
    'horizontalBar': XL_CHART_TYPE.BAR_CLUSTERED,
    'line': XL_CHART_TYPE.LINE,
    'pie': XL_CHART_TYPE.PIE,
    'doughnut': XL_CHART_TYPE.DOUGHNUT,
}

def extract_chart_data(html_text):
    # CHART_DATA 객체 또는 new Chart() 파싱
    match = re.search(r'(?:const|var|let)\s+CHART_DATA\s*=\s*(\{[\s\S]*?\});', html_text)
    if match:
        try:
            return json.loads(match.group(1))
        except Exception:
            pass
    return {}

def add_textbox(slide, text, left, top, width, height, font_size=18, bold=False):
    from pptx.util import Pt
    txBox = slide.shapes.add_textbox(left, top, width, height)
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = text
    p.runs[0].font.size = Pt(font_size)
    p.runs[0].font.bold = bold
    p.runs[0].font.name = 'Malgun Gothic'

def convert(html_path, out_path):
    html = Path(html_path).read_text(encoding='utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    chart_data_global = extract_chart_data(html)

    prs = Presentation()
    prs.slide_width = SLIDE_W
    prs.slide_height = SLIDE_H
    blank_layout = prs.slide_layouts[6]

    for slide_el in soup.select('.slide'):
        slide = prs.slides.add_slide(blank_layout)
        # 제목
        title = slide_el.find(['h1', 'h2'])
        if title:
            add_textbox(slide, title.get_text(strip=True),
                        Inches(0.5), Inches(0.4), SLIDE_W - Inches(1), Inches(1.2),
                        font_size=36, bold=True)
        # 본문
        items = slide_el.find_all(['p', 'li'])
        body_text = '\n'.join(i.get_text(strip=True) for i in items if i.get_text(strip=True))
        if body_text:
            add_textbox(slide, body_text,
                        Inches(0.5), Inches(1.8), SLIDE_W - Inches(1), SLIDE_H - Inches(2.5),
                        font_size=18)
        # 차트 (canvas 태그 탐지)
        canvas = slide_el.find('canvas')
        if canvas and chart_data_global:
            cid = canvas.get('id', '')
            cfg = chart_data_global.get(cid, chart_data_global)
            ctype = cfg.get('type', 'bar')
            xl_type = CHART_TYPE_MAP.get(ctype, XL_CHART_TYPE.COLUMN_CLUSTERED)
            labels = cfg.get('data', {}).get('labels', ['A', 'B', 'C'])
            datasets = cfg.get('data', {}).get('datasets', [{'label': 'Data', 'data': [1, 2, 3]}])
            cd = ChartData()
            cd.categories = labels
            for ds in datasets:
                cd.add_series(ds.get('label', 'Series'), ds.get('data', []))
            left, top = Inches(0.5), Inches(2.2)
            w, h = SLIDE_W - Inches(1), SLIDE_H - Inches(3)
            slide.shapes.add_chart(xl_type, left, top, w, h, cd)

    prs.save(out_path)
    print(f'저장 완료: {out_path}')

if __name__ == '__main__':
    html_in = sys.argv[1]
    pptx_out = sys.argv[2] if len(sys.argv) > 2 else html_in.replace('.html', '.pptx')
    convert(html_in, pptx_out)
```

**결과물 안내:**
- PPTX 파일 위치 및 크기
- 차트 편집 방법: 차트 우클릭 → "데이터 편집" → Excel 시트 수정
- 폰트: 맑은 고딕 (기본) 또는 사용자 지정 폰트 (시스템에 설치된 경우만 적용)
- 제한사항: 애니메이션·그래디언트·CSS 효과는 보존되지 않음, 텍스트·이미지·차트만 변환

### 6B: Export to PDF

This captures each slide as a screenshot and combines them into a PDF. Perfect for email attachments, embedding in documents, or printing.

**Note:** Animations and interactivity are not preserved — the PDF is a static snapshot. This is normal and expected; mention it to the user so they're not surprised.

1. **Run the export script:**

   ```bash
   bash scripts/export-pdf.sh <path-to-html> [output.pdf]
   ```

   If no output path is given, the PDF is saved next to the HTML file.

2. **What happens behind the scenes** (explain briefly to the user):
   - A headless browser opens the presentation at 1920×1080 (standard widescreen)
   - It screenshots each slide one by one
   - All screenshots are combined into a single PDF
   - The script needs Playwright (a browser automation tool) — it will install automatically if missing

3. **If Playwright installation fails:**
   - The most common issue is Chromium not downloading. Run: `npx playwright install chromium`
   - If that fails too, it may be a network/firewall issue. Ask the user to try on a different network.

4. **Deliver the PDF** — The script auto-opens it. Tell the user:
   - The file location and size
   - That it works everywhere — email, Slack, Notion, Google Docs, print
   - Animations are replaced by their final visual state (still looks great, just static)

**⚠ PDF export gotchas:**

- **First run is slow.** The script installs Playwright and downloads a Chromium browser (~150MB) into a temp directory. This happens once per run. Warn the user it may take 30-60 seconds the first time — subsequent exports within the same session are faster.
- **Slides must use `class="slide"`.** The export script finds slides by querying `.slide` elements. If the presentation uses a different class name, the script will report "0 slides found" and fail. All presentations generated by this skill use `.slide`, so this only matters for externally-created HTML.
- **Local images must be loadable via HTTP.** The script starts a local server and loads the HTML through it (so Google Fonts and relative image paths work). If images use absolute filesystem paths (e.g., `src="/Users/name/photo.png"`) instead of relative paths (e.g., `src="photo.png"`), they won't load. Generated presentations always use relative paths, but converted or user-provided decks might not — check and fix if needed.
- **Local images appear in the PDF** as long as they are in the same directory as (or relative to) the HTML file. The export script serves the HTML's parent directory over HTTP, so relative paths like `src="photo.png"` resolve correctly — including filenames with spaces. If images still don't appear, check: (1) the image files actually exist at the referenced path, (2) the paths are relative, not absolute filesystem paths like `/Users/name/photo.png`.
- **Large presentations produce large PDFs.** Each slide is captured as a full 1920×1080 PNG screenshot. An 18-slide deck can produce a ~20MB PDF. If the PDF exceeds 10MB, ask the user: _"The PDF is [size]. Would you like me to compress it? It'll look slightly less sharp but the file will be much smaller."_ If yes, re-run the export with the `--compact` flag:
  ```bash
  bash scripts/export-pdf.sh <path-to-html> [output.pdf] --compact
  ```
  This renders at 1280×720 instead of 1920×1080, typically cutting file size by 50-70% with minimal visual difference.

---

## Supporting Files

| File                                               | Purpose                                                              | When to Read              |
| -------------------------------------------------- | -------------------------------------------------------------------- | ------------------------- |
| [STYLE_PRESETS.md](STYLE_PRESETS.md)               | 12 curated visual presets with colors, fonts, and signature elements | Phase 2 (style selection) |
| [bold-template-pack/selection-index.json](bold-template-pack/selection-index.json) | Compact bold template metadata for candidate selection | Phase 2 (style selection) |
| [bold-template-pack/templates/*/preview.md](bold-template-pack/templates/) | Lightweight style cards for shortlisted bold title previews | Phase 2 after shortlisting |
| [bold-template-pack/templates/*/design.md](bold-template-pack/templates/) | Detailed design-system docs for the selected bold template only | Phase 3 after user selection |
| [viewport-base.css](viewport-base.css)             | Mandatory fixed-stage CSS — copy into every presentation             | Phase 3 (generation)      |
| [html-template.md](html-template.md)               | HTML structure, JS features, code quality standards                  | Phase 3 (generation)      |
| [animation-patterns.md](animation-patterns.md)     | CSS/JS animation snippets and effect-to-feeling guide                | Phase 3 (generation)      |
| [scripts/extract-pptx.py](scripts/extract-pptx.py) | Python script for PPT content extraction                             | Phase 4 (conversion)      |
| [scripts/deploy.sh](scripts/deploy.sh)             | Deploy slides to Vercel for instant sharing                          | Phase 6 (sharing)         |
| [scripts/export-pdf.sh](scripts/export-pdf.sh)     | Export slides to PDF                                                 | Phase 6 (sharing)         |
| [scripts/export-pptx.py](scripts/export-pptx.py)   | HTML → PPTX 변환 (차트 네이티브, 폰트 맑은 고딕 기본)               | Phase 6C (PPTX 출력)      |
| `E:\Harness\awesome-design-md-main\awesome-design-md-main\design-md\<brand>\DESIGN.md` | 73개 브랜드 디자인 토큰 (colors/typography/spacing/components) | Phase 0 브랜드 감지 시 즉시, Phase 2 Style A |

---

## 한국어 보고서 CSS 규칙

한국어 콘텐츠가 포함된 슬라이드/보고서 생성 시 반드시 적용.

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

## Phase 7: Impeccable Polish (선택)

Phase 5 Delivery 완료 후 자동으로 아래 질문을 한다:

> "impeccable로 품질 검증/개선할까요? (audit · polish · critique)"

사용자가 원하면 해당 명령을 생성된 HTML 파일에 적용한다.

| 명령 | 효과 | 추천 시점 |
|------|------|----------|
| `audit` | WCAG 접근성·색상 대비·타이포그래피 점검 | 배포 전 필수 |
| `critique` | 슬라이드 디자인 비판적 검토 + 개선 제안 | 초안 완성 후 |
| `polish` | 미세 디테일(간격·정렬·Shadow 등) 완성도 향상 | 최종 마무리 |
| `bolder` | 비주얼 임팩트 강화 (헤드라인·배경·대비) | 키노트·피치덱 |
| `animate` | 전환 애니메이션·모션 효과 추가·개선 | 발표용 |

적용 방법: impeccable SKILL.md를 읽고 해당 서브커맨드 reference 파일을 참조하여 생성된 HTML에 직접 수정을 가한다. 수정 후 브라우저로 결과를 열어 확인한다.
