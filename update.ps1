# claude-loops update.ps1
# Usage: .\update.ps1 [-ClaudeHome "C:\Users\YourName\.claude"]

param(
    [string]$ClaudeHome = "$env:USERPROFILE\.claude"
)

$SkillsDir = "$ClaudeHome\skills"
$RepoDir = $PSScriptRoot

Write-Host "claude-loops 업데이트"
Write-Host "CLAUDE_HOME: $ClaudeHome"

if (-not (Test-Path $SkillsDir)) {
    Write-Host "오류: $SkillsDir 가 없습니다. install.ps1을 먼저 실행하세요."
    exit 1
}

# 최신 변경 pull
git -C $RepoDir pull --ff-only

# skills 재복사
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
Write-Host "업데이트 완료."
