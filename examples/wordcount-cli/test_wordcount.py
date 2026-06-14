import subprocess
import sys
import os
import pytest

PY = sys.executable
CLI = os.path.join(os.path.dirname(__file__), "wordcount.py")
SAMPLE = os.path.join(os.path.dirname(__file__), "sample.txt")


def run(args):
    return subprocess.run([PY, CLI] + args, capture_output=True, text=True)


def test_line_count():
    """AC-1: 줄 수가 정수로 출력된다"""
    r = run([SAMPLE])
    assert r.returncode == 0
    lines = {l.split(":")[0].strip(): l.split(":", 1)[1].strip()
             for l in r.stdout.splitlines() if ":" in l}
    assert lines["줄 수"].isdigit()
    assert int(lines["줄 수"]) == 10


def test_word_count():
    """AC-2: 단어 수가 정수로 출력된다"""
    r = run([SAMPLE])
    assert r.returncode == 0
    lines = {l.split(":")[0].strip(): l.split(":", 1)[1].strip()
             for l in r.stdout.splitlines() if ":" in l}
    assert lines["단어 수"].isdigit()
    assert int(lines["단어 수"]) > 0


def test_top5():
    """AC-3: TOP5 단어가 순위/단어/횟수 형식으로 출력된다"""
    r = run([SAMPLE])
    assert r.returncode == 0
    top5_lines = [l for l in r.stdout.splitlines() if l.strip().startswith(("1.", "2.", "3.", "4.", "5."))]
    assert len(top5_lines) == 5
    for line in top5_lines:
        assert "(" in line and ")" in line


def test_file_not_found():
    """AC-4: 존재하지 않는 파일 → 오류 메시지 + exit 1"""
    r = run(["없는파일.txt"])
    assert r.returncode == 1
    assert "파일을 찾을 수 없습니다" in r.stdout


def test_no_args():
    """AC-5: 인수 없이 실행 → 사용법 안내 + exit 1"""
    r = run([])
    assert r.returncode == 1
    assert "사용법" in r.stdout
