#!/usr/bin/env bash
# deploy.sh — Vercel 배포 스크립트 (frontend-slides / design-page 공용)
# Usage: bash deploy.sh <html_file_path>

set -e

FILE_PATH="${1:?Usage: bash deploy.sh <html_file_path>}"

if [ ! -f "$FILE_PATH" ]; then
  echo "오류: 파일이 없습니다 — $FILE_PATH"
  exit 1
fi

FILE_DIR="$(dirname "$FILE_PATH")"
FILE_NAME="$(basename "$FILE_PATH")"

# Vercel CLI 설치 확인
if ! command -v vercel &>/dev/null && ! npx vercel --version &>/dev/null 2>&1; then
  echo "Vercel CLI 미설치."
  echo "설치: npm install -g vercel"
  echo "가입: https://vercel.com/signup"
  exit 1
fi

VERCEL_CMD="npx vercel"

# 로그인 확인
if ! $VERCEL_CMD whoami &>/dev/null 2>&1; then
  echo "Vercel 로그인 필요:"
  echo "  npx vercel login"
  exit 1
fi

# 단일 파일 → 임시 디렉토리로 복사 후 배포
DEPLOY_DIR="$(mktemp -d)"
cp "$FILE_PATH" "$DEPLOY_DIR/index.html"

echo "배포 중: $FILE_NAME → Vercel"
$VERCEL_CMD deploy "$DEPLOY_DIR" --prod --yes 2>&1

rm -rf "$DEPLOY_DIR"
