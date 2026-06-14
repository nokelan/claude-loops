import sys
import re
from collections import Counter


def analyze(path: str) -> dict:
    with open(path, encoding="utf-8") as f:
        text = f.read()
    lines = text.splitlines()
    words = re.findall(r"[a-zA-Z가-힣]+", text.lower())
    top5 = sorted(Counter(words).items(), key=lambda x: (-x[1], x[0]))[:5]
    return {"lines": len(lines), "words": len(words), "top5": top5}


def main():
    if len(sys.argv) < 2:
        print("사용법: python wordcount.py <파일경로>")
        sys.exit(1)

    path = sys.argv[1]
    try:
        result = analyze(path)
    except FileNotFoundError:
        print(f"파일을 찾을 수 없습니다: {path}")
        sys.exit(1)

    print(f"줄 수: {result['lines']}")
    print(f"단어 수: {result['words']}")
    print("TOP5 단어:")
    for i, (word, count) in enumerate(result["top5"], 1):
        print(f"  {i}. {word:<10} ({count})")


if __name__ == "__main__":
    main()
