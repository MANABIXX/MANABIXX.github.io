#!/usr/bin/env python3
"""Validate core question banks before a Study release."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "static" / "data"
BANKS = ("questions.json", "public-exam.json")


def validate_bank(filename):
    payload = json.loads((DATA / filename).read_text(encoding="utf-8"))
    records = payload.get("questions", []) if isinstance(payload, dict) else payload
    if not isinstance(records, list):
        raise ValueError(f"{filename}: questions must be an array")
    seen = set()
    for index, item in enumerate(records, 1):
        if not isinstance(item, dict):
            raise ValueError(f"{filename}: record {index} is not an object")
        missing = [key for key in ("id", "prompt", "options", "correct", "explanation") if key not in item]
        if missing:
            raise ValueError(f"{filename}: {item.get('id', index)} missing {', '.join(missing)}")
        identifier = str(item["id"])
        if identifier in seen:
            raise ValueError(f"{filename}: duplicate id {identifier}")
        seen.add(identifier)
        if not isinstance(item["options"], list) or len(item["options"]) != 4:
            raise ValueError(f"{filename}: {identifier} must have four options")
        if not isinstance(item["correct"], int) or not 0 <= item["correct"] < 4:
            raise ValueError(f"{filename}: {identifier} has invalid correct index")
        if not str(item["prompt"]).strip() or not str(item["explanation"]).strip():
            raise ValueError(f"{filename}: {identifier} has an empty prompt/explanation")
    print(f"OK {filename}: {len(records)} questions checked")
    return len(records)


if __name__ == "__main__":
    try:
        total = sum(validate_bank(name) for name in BANKS)
        print(f"Content validation passed: {total} questions.")
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Content validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)
