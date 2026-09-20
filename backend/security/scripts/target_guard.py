#!/usr/bin/env python3
"""Reject accidental scans of non-loopback targets."""

from __future__ import annotations

import ipaddress
import os
import socket
import sys
import urllib.parse


ACKNOWLEDGEMENT = "I_HAVE_WRITTEN_AUTHORIZATION"


def validate_target(value: str) -> str:
    parsed = urllib.parse.urlparse(value)
    if parsed.scheme not in {"http", "https"} or not parsed.hostname:
        raise ValueError("target must be an absolute HTTP(S) URL")
    if parsed.username or parsed.password or parsed.query or parsed.fragment:
        raise ValueError("target must not contain credentials, query or fragment")

    host = parsed.hostname
    is_local = host == "localhost"
    try:
        is_local = is_local or ipaddress.ip_address(host).is_loopback
    except ValueError:
        try:
            addresses = socket.getaddrinfo(host, parsed.port or 80)
        except socket.gaierror:
            addresses = []
        is_local = bool(addresses) and all(
            ipaddress.ip_address(item[4][0]).is_loopback for item in addresses
        )

    if not is_local and os.getenv("NEXUS_PENTEST_ALLOW_REMOTE") != ACKNOWLEDGEMENT:
        raise ValueError(
            "remote target refused; written authorization acknowledgement is required"
        )
    return value.rstrip("/")


def main() -> int:
    target = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        print(validate_target(target))
    except ValueError as error:
        print(f"target rejected: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
