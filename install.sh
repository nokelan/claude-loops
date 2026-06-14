#!/usr/bin/env bash
# claude-loops install.sh
# Usage: bash install.sh [--claude-home ~/.claude]

set -e

CLAUDE_HOME="${1:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_HOME/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "claude-loops 설치"
echo "CLAUDE_HOME: $CLAUDE_HOME"
echo "skills 대상: $SKILLS_DIR"

if [ ! -d "$SKILLS_DIR" ]; then
    echo "오류: $SKILLS_DIR 가 존재하지 않습니다."
    echo "Claude Code를 먼저 설치하고 ~/.claude/skills 가 있는지 확인하세요."
    exit 1
fi

for skill_dir in "$REPO_DIR/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    dest="$SKILLS_DIR/$skill_name"
    mkdir -p "$dest"
    cp -r "$skill_dir"* "$dest/"
    echo "  [OK] $skill_name"
done

echo ""
echo "설치 완료. Claude Code에서 다음 명령으로 사용:"
echo "  /dev-plan, /dev-loop, /dev-loopcode, /dev-verify"
echo "  /dev-hwaloop, /harness, /graphify, /design-page"
echo ""
echo ".env 설정:"
echo "  cp .env.example .env 후 TELEGRAM_CHAT_ID 등 설정"
