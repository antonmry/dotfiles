#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Export dated Codex messages from the host and running Lima VMs to /tmp."""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from zoneinfo import ZoneInfo


def arguments(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--since", help="First local date/time (default: Monday)")
    parser.add_argument("--until", help="Exclusive local date/time (default: now)")
    parser.add_argument("--timezone", default="Europe/Madrid")
    parser.add_argument("--host-only", action="store_true", help="Skip Lima")
    parser.add_argument("--exclude-thread", action="append", default=[])
    parser.add_argument(
        "--output", type=Path, help="New evidence file directly in /tmp"
    )
    parser.add_argument("--guest", action="store_true", help=argparse.SUPPRESS)
    return parser.parse_args(argv)


def period(args, now=None):
    zone = ZoneInfo(args.timezone)
    now = (now or datetime.now(timezone.utc)).astimezone(zone)

    def boundary(value):
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            parsed = parsed.replace(tzinfo=zone)
        return parsed.astimezone(timezone.utc)

    monday = (now - timedelta(days=now.weekday())).replace(
        hour=0, minute=0, second=0, microsecond=0
    )
    start = boundary(args.since) if args.since else monday.astimezone(timezone.utc)
    end = boundary(args.until) if args.until else now.astimezone(timezone.utc)
    if end <= start:
        raise ValueError("--until must be after --since")
    return start, end


def timestamp(value):
    if not isinstance(value, str):
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        return parsed.astimezone(timezone.utc) if parsed.tzinfo else None
    except ValueError:
        return None


def redact(text):
    # Best-effort removal of common inline credentials, not a secret detector.
    text = re.sub(r"(?i)(Bearer\s+)[\w.~+/=-]+", r"\1[REDACTED]", text)
    text = re.sub(
        r"\b(?:xox[baprs]-[\w-]+|gh[pousr]_[\w]+|github_pat_[\w]+|"
        r"sk-[\w-]{16,}|AKIA[A-Z0-9]{16})\b",
        "[REDACTED]",
        text,
    )
    text = re.sub(
        r"(?im)(\b[\w-]*(?:api[_-]?key|token|secret|password|credential)"
        r"[\w-]*[\"']?\s*[:=]\s*[\"']?)([^\s,;\"']+)",
        r"\1[REDACTED]",
        text,
    )
    text = re.sub(r"(\w+://)[^\s/@]+:[^\s/@]+@", r"\1[REDACTED]@", text)
    return re.sub(
        r"(?i)([?&](?:access_token|token|sig|signature|x-amz-signature|"
        r"x-amz-credential|x-amz-security-token)=)[^&\s)]+",
        r"\1[REDACTED]",
        text,
    )


def message_text(item):
    if isinstance(item.get("text"), str):
        return item["text"]
    if isinstance(item.get("message"), str):
        return item["message"]
    return "\n".join(
        block["text"]
        for block in item.get("content", [])
        if isinstance(block, dict) and isinstance(block.get("text"), str)
    )


def extract_message(record):
    payload = record.get("payload", {})
    if not isinstance(payload, dict):
        return None
    kind = record.get("type")
    legacy = False
    if kind == "response_item" and payload.get("type") == "message":
        item = payload
        role = item.get("role")
    elif kind == "event_msg" and payload.get("type") == "item_completed":
        item = payload.get("item", {})
        role = {"UserMessage": "user", "AgentMessage": "assistant"}.get(
            item.get("type")
        )
    elif kind == "event_msg" and payload.get("type") in (
        "user_message",
        "agent_message",
    ):
        item = payload
        role = "user" if payload["type"] == "user_message" else "assistant"
        legacy = True
    else:
        return None
    if role not in ("user", "assistant"):
        return None
    text = message_text(item).strip()
    if not text or text.startswith(
        ("# AGENTS.md instructions", "<environment_context>", "<skill>")
    ):
        return None
    if text.startswith("<realtime_delegation>"):
        match = re.search(r"<input>(.*?)</input>", text, re.DOTALL)
        if match:
            text = match[1].strip()
    # Embedded commit diffs are not needed when reporting their actual outcomes.
    text = text.split("<stdin>", 1)[0].strip()
    return {
        "id": item.get("id"),
        "role": role,
        "phase": item.get("phase", ""),
        "text": redact(text),
        "legacy": legacy,
    }


def collect_source(root, start, end, excluded):
    """Read rollout files, including older threads modified during this period."""
    threads = []
    warnings = []
    stores = [p for p in (root / "sessions", root / "archived_sessions") if p.is_dir()]
    if not stores:
        raise FileNotFoundError(f"No Codex session directories under {root}")
    for store in stores:
        for path in sorted(store.rglob("rollout-*.jsonl")):
            if path.is_symlink() or path.stat().st_mtime < start.timestamp():
                continue
            metadata = {}
            messages = []
            completed = []
            legacy = []
            bad_lines = 0
            try:
                with path.open(encoding="utf-8") as stream:
                    for ordinal, line in enumerate(stream):
                        try:
                            record = json.loads(line)
                        except (json.JSONDecodeError, UnicodeError):
                            bad_lines += 1
                            continue
                        if not isinstance(record, dict):
                            continue
                        if record.get("type") == "session_meta":
                            metadata = record.get("payload", {})
                            continue
                        at = timestamp(record.get("timestamp"))
                        if at is None or not start <= at < end:
                            continue
                        message = extract_message(record)
                        if message is not None:
                            message["timestamp"] = at.isoformat()
                            message["record_ordinal"] = ordinal
                            if message.pop("legacy"):
                                legacy.append(message)
                            elif record["type"] == "event_msg":
                                completed.append(message)
                            else:
                                messages.append(message)
            except (OSError, UnicodeError) as error:
                warnings.append(f"Could not read {path.name}: {type(error).__name__}")
                continue
            if bad_lines:
                warnings.append(
                    f"Skipped {bad_lines} incomplete/invalid lines in {path.name}"
                )
            thread_id = metadata.get("id") or path.stem
            if thread_id in excluded:
                continue
            # Completed items and response items can have different IDs for the
            # same message, timestamped milliseconds apart. Prefer completed
            # items, but preserve genuinely repeated requests in later turns.
            mirrors = {}
            merged = []
            for group in (completed, messages, legacy):
                group_times = {}
                for message in group:
                    key = (message["role"], message["text"])
                    at = timestamp(message["timestamp"]).timestamp()
                    if not any(abs(at - other) <= 2 for other in mirrors.get(key, [])):
                        merged.append(message)
                    group_times.setdefault(key, []).append(at)
                for key, times in group_times.items():
                    mirrors.setdefault(key, []).extend(times)
            seen = set()
            unique = []
            for message in merged:
                key = message["id"] or (
                    message["timestamp"],
                    message["role"],
                    message["text"],
                )
                if key not in seen:
                    seen.add(key)
                    unique.append(message)
            if unique:
                threads.append(
                    {
                        "id": thread_id,
                        "cwd": metadata.get("cwd", ""),
                        "messages": sorted(
                            unique, key=lambda m: (m["timestamp"], m["record_ordinal"])
                        ),
                    }
                )
    return {"threads": threads, "warnings": warnings}


def lima_sources(start, end, excluded):
    """Run this same standard-library collector in guests; never start a VM."""
    sources = []
    try:
        listing = subprocess.run(
            ["limactl", "list", "--json"],
            capture_output=True,
            text=True,
            check=True,
            timeout=30,
        )
        instances = [
            json.loads(line) for line in listing.stdout.splitlines() if line.strip()
        ]
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        return [{"source": "lima", "status": "error", "error": type(error).__name__}]
    script = Path(__file__).read_text(encoding="utf-8")
    for instance in instances:
        name = instance["name"]
        source = f"lima:{name}"
        if instance.get("status") != "Running":
            sources.append(
                {"source": source, "status": instance.get("status", "unknown")}
            )
            continue
        command = [
            "limactl",
            "shell",
            name,
            "--",
            "python3",
            "-",
            "--guest",
            "--since",
            start.isoformat(),
            "--until",
            end.isoformat(),
            "--timezone",
            "UTC",
        ]
        for thread in sorted(excluded):
            command.extend(["--exclude-thread", thread])
        try:
            result = subprocess.run(
                command,
                input=script,
                capture_output=True,
                text=True,
                check=True,
                timeout=120,
            )
            data = json.loads(result.stdout)
            sources.append({"source": source, "status": "ok", **data})
        except (OSError, subprocess.SubprocessError, ValueError) as error:
            sources.append(
                {"source": source, "status": "error", "error": type(error).__name__}
            )
    return sources


def write_evidence(output, start, end, zone, sources):
    output = output or Path(
        f"/tmp/codex-sessions-{datetime.now():%Y%m%d-%H%M%S}-{os.getpid()}.jsonl"
    )
    if output.parent.resolve() != Path("/tmp").resolve():
        raise ValueError("Evidence output must be a new file directly in /tmp")
    coverage = []
    records = []
    seen = set()
    for source in sources:
        threads = source.get("threads", [])
        coverage.append(
            {
                **{k: v for k, v in source.items() if k != "threads"},
                "threads": len(threads),
                "messages": sum(len(t["messages"]) for t in threads),
            }
        )
        for thread in threads:
            emitted = False
            for message in thread["messages"]:
                key = (
                    thread["id"],
                    message.get("id")
                    or (message["timestamp"], message["role"], message["text"]),
                )
                if key in seen:
                    continue
                seen.add(key)
                if not emitted:
                    records.append(
                        {
                            "type": "thread",
                            "source": source["source"],
                            "id": thread["id"],
                            "cwd": thread["cwd"],
                        }
                    )
                    emitted = True
                records.append(
                    {
                        "type": "message",
                        "source": source["source"],
                        "thread_id": thread["id"],
                        **message,
                    }
                )
    header = {
        "type": "collection",
        "since": start.isoformat(),
        "until": end.isoformat(),
        "timezone": zone,
        "sources": coverage,
    }
    # Exclusive creation also rejects pre-existing files and symlinks in /tmp.
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8") as stream:
        for record in [header, *records]:
            stream.write(json.dumps(record, ensure_ascii=False) + "\n")
    return {"file": str(output), **header, "message_count": len(seen)}


def main(argv=None):
    args = arguments(argv)
    try:
        start, end = period(args)
        excluded = set(args.exclude_thread)
        if os.environ.get("CODEX_THREAD_ID"):
            excluded.add(os.environ["CODEX_THREAD_ID"])
        root = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
        if args.guest:
            print(
                json.dumps(
                    collect_source(root, start, end, excluded), ensure_ascii=False
                )
            )
            return 0
        try:
            host = {
                "source": "host",
                "status": "ok",
                **collect_source(root, start, end, excluded),
            }
        except OSError as error:
            host = {"source": "host", "status": "error", "error": type(error).__name__}
        sources = [host]
        if not args.host_only:
            sources.extend(lima_sources(start, end, excluded))
        summary = write_evidence(args.output, start, end, args.timezone, sources)
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 0 if any(s["status"] == "ok" for s in sources) else 1
    except (OSError, ValueError, KeyError) as error:
        print(f"Collection failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
