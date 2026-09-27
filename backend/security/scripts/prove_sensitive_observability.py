#!/usr/bin/env python3
"""Prove sensitive values are redacted from Nexus logs and traces."""

from __future__ import annotations

import datetime as dt
import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
REPORTS = ROOT / "security/reports"


def main() -> int:
    source = (ROOT / "shared/nexus_auth/lib/src/nexus_observability.dart").read_text()
    ai_sources = "\n".join(
        path.read_text()
        for path in (ROOT / "services/ai_gateway/ai_gateway_server/lib/src/ai").rglob("*.dart")
    )
    checks = {
        "logFieldRedaction": "...sanitizeLogFields(fields)" in source,
        "rawExceptionNotExported": "span.recordException(error" not in source,
        "aiUsesSanitizedLogger": "session.log(" not in ai_sources,
    }
    passed = all(checks.values())
    output = {
        "schemaVersion": 1,
        "tool": "nexus-sensitive-observability",
        "status": "PASS" if passed else "FAIL",
        "checks": checks,
        "timestamp": dt.datetime.now(dt.timezone.utc).isoformat(),
    }
    path = REPORTS / "sensitive-observability.json"
    path.write_text(json.dumps(output, indent=2) + "\n")
    print(f"sensitive observability {output['status']}: {path}")
    return 0 if passed else 2


if __name__ == "__main__":
    raise SystemExit(main())
