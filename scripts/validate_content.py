#!/usr/bin/env python3
"""Validate every published Study question bank before deployment."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "static" / "data"
BANKS = (
    "questions.json",
    "public-exam.json",
    "mock-exams.json",
    "summary-foundation.json",
    "s-exclusive.json",
    "s-exclusive-beta.json",
    "private-ja.json",
    "private-ma.json",
    "private-sc.json",
    "private-so.json",
    "private-en.json",
)


def validate_bank(filename):
    payload = json.loads((DATA / filename).read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError(f"{filename}: root must be an object")

    records = payload.get("questions")
    if not isinstance(records, list):
        raise ValueError(f"{filename}: questions must be an array")
    if "count" in payload and payload["count"] != len(records):
        raise ValueError(
            f"{filename}: count metadata says {payload['count']}, "
            f"but contains {len(records)} records"
        )

    expected_subject = payload.get("subject")
    seen = set()
    for index, item in enumerate(records, 1):
        if not isinstance(item, dict):
            raise ValueError(f"{filename}: record {index} is not an object")

        missing = [
            key
            for key in ("id", "prompt", "options", "correct", "explanation")
            if key not in item
        ]
        if missing:
            raise ValueError(
                f"{filename}: {item.get('id', index)} missing {', '.join(missing)}"
            )

        identifier = item["id"]
        if not isinstance(identifier, str) or not identifier.strip():
            raise ValueError(f"{filename}: record {index} has an empty/invalid id")
        if identifier in seen:
            raise ValueError(f"{filename}: duplicate id {identifier}")
        seen.add(identifier)

        prompt = item["prompt"]
        explanation = item["explanation"]
        if not isinstance(prompt, str) or not prompt.strip():
            raise ValueError(f"{filename}: {identifier} has an empty/invalid prompt")
        if not isinstance(explanation, str) or not explanation.strip():
            raise ValueError(
                f"{filename}: {identifier} has an empty/invalid explanation"
            )

        options = item["options"]
        if not isinstance(options, list) or len(options) != 4:
            raise ValueError(f"{filename}: {identifier} must have four options")
        if any(not isinstance(option, str) or not option.strip() for option in options):
            raise ValueError(f"{filename}: {identifier} has an empty/invalid option")
        if len({option.strip() for option in options}) != 4:
            raise ValueError(f"{filename}: {identifier} has duplicate options")

        correct = item["correct"]
        if type(correct) is not int or not 0 <= correct < 4:
            raise ValueError(f"{filename}: {identifier} has invalid correct index")

        for field in ("subject", "topic", "term", "level"):
            if field in item and (
                not isinstance(item[field], str) or not item[field].strip()
            ):
                raise ValueError(f"{filename}: {identifier} has an invalid {field}")
        if expected_subject is not None and item.get("subject") != expected_subject:
            raise ValueError(
                f"{filename}: {identifier} does not match top-level subject "
                f"{expected_subject!r}"
            )

    print(f"OK {filename}: {len(records)} questions checked")
    return len(records)


if __name__ == "__main__":
    try:
        total = sum(validate_bank(name) for name in BANKS)
        print(
            f"Content validation passed: {total} question records "
            f"across {len(BANKS)} banks."
        )
    except (OSError, ValueError, json.JSONDecodeError) as error:
        print(f"Content validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)
