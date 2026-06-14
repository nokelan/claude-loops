#!/usr/bin/env bash
# claude-loops update.sh
# Usage: bash update.sh [~/.claude]

set -e

CLAUDE_HOME="${1:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_HOME/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "claude-loops 업데이트"
echo "CLAUDE_HOME: $CLAUDE_HOME"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "오류: $SKILLS_DIR 가 없습니다. install.sh를 먼저 실행하세요."
  exit 1
fi

git -C "$REPO_DIR" pull --ff-only

for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$SKILLS_DIR/$skill_name"
  mkdir -p "$dest"
  cp -r "$skill_dir"* "$dest/"
  echo "  [OK] $skill_name"
done

echo ""
echo "업데이트 완료."
