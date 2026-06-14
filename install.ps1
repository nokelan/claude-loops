# claude-loops install.ps1
# Usage: .\install.ps1 [-ClaudeHome "C:\Users\YourName\.claude"]

param(
    [string]$ClaudeHome = "$env:USERPROFILE\.claude"
)

$SkillsDir = "$ClaudeHome\skills"
$RepoDir = $PSScriptRoot

Write-Host "claude-loops 설치"
Write-Host "CLAUDE_HOME: $ClaudeHome"
Write-Host "skills 대상: $SkillsDir"

# skills 디렉토리 확인
if (-not (Test-Path $SkillsDir)) {
    Write-Host "오류: $SkillsDir 가 존재하지 않습니다."
    Write-Host "Claude Code를 먼저 설치하고 ~/.claude/skills 가 있는지 확인하세요."
    exit 1
}

# 각 skill 복사
$skills = Get-ChildItem "$RepoDir\skills" -Directory
foreach ($skill in $skills) {
    $destSkillDir = "$SkillsDir\$($skill.Name)"
    New-Item -ItemType Directory -Force $destSkillDir | Out-Null
    Get-ChildItem $skill.FullName -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($skill.FullName.Length + 1)
        $destFile = "$destSkillDir\$rel"
        $destFileDir = Split-Path $destFile -Parent
        New-Item -ItemType Directory -Force $destFileDir | Out-Null
        Copy-Item $_.FullName $destFile -Force
    }
    Write-Host "  [OK] $($skill.Name)"
}

Write-Host ""
Write-Host "설치 완료. Claude Code에서 다음 명령으로 사용:"
Write-Host "  /dev-plan, /dev-loop, /dev-loopcode, /dev-verify"
Write-Host "  /dev-hwaloop, /harness, /graphify, /design-page"
Write-Host ""
Write-Host ".env 설정:"
Write-Host "  cp .env.example .env 후 TELEGRAM_CHAT_ID 등 설정"
