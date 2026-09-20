#!/usr/bin/env python3
"""Enforce an explicit network scope for every defensive security request."""

from __future__ import annotations

import ipaddress
import socket
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Iterable


DEFAULT_SCOPE = Path(__file__).resolve().parents[1] / "policy/local.scope.yaml"


@dataclass(frozen=True)
class ScopePolicy:
    environment: str
    allowed_hosts: frozenset[str]
    allowed_cidrs: tuple[ipaddress.IPv4Network | ipaddress.IPv6Network, ...]
    destructive: bool
    max_redirects: int


def load_scope_manifest(path: str | Path = DEFAULT_SCOPE) -> ScopePolicy:
    """Load the deliberately small, dependency-free scope YAML subset."""
    manifest = Path(path)
    values: dict[str, object] = {}
    current_list: str | None = None
    for number, raw_line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
        line = raw_line.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        if line.startswith("  - "):
            if current_list is None:
                raise ValueError(f"invalid scope manifest list at line {number}")
            item = line[4:].strip()
            if not item:
                raise ValueError(f"empty scope value at line {number}")
            assert isinstance(values[current_list], list)
            values[current_list].append(item)
            continue
        if line[0].isspace() or ":" not in line:
            raise ValueError(f"invalid scope manifest line {number}")
        key, raw_value = line.split(":", 1)
        key = key.strip()
        raw_value = raw_value.strip()
        if not raw_value:
            values[key] = []
            current_list = key
        else:
            current_list = None
            values[key] = raw_value

    required = {"environment", "allowedHosts", "allowedCidrs", "destructive"}
    missing = required.difference(values)
    if missing:
        raise ValueError(f"scope manifest missing: {', '.join(sorted(missing))}")
    hosts = values["allowedHosts"]
    cidrs = values["allowedCidrs"]
    if not isinstance(hosts, list) or not hosts:
        raise ValueError("allowedHosts must be a non-empty list")
    if not isinstance(cidrs, list) or not cidrs:
        raise ValueError("allowedCidrs must be a non-empty list")
    destructive = str(values["destructive"]).lower()
    if destructive not in {"true", "false"}:
        raise ValueError("destructive must be true or false")
    max_redirects = int(str(values.get("maxRedirects", "0")))
    if max_redirects < 0 or max_redirects > 5:
        raise ValueError("maxRedirects must be between 0 and 5")
    return ScopePolicy(
        environment=str(values["environment"]),
        allowed_hosts=frozenset(_normalize_host(item) for item in hosts),
        allowed_cidrs=tuple(ipaddress.ip_network(item, strict=True) for item in cidrs),
        destructive=destructive == "true",
        max_redirects=max_redirects,
    )


def _normalize_host(host: str) -> str:
    return host.rstrip(".").lower()


def _resolve(host: str, port: int) -> frozenset[ipaddress.IPv4Address | ipaddress.IPv6Address]:
    try:
        return frozenset(
            ipaddress.ip_address(item[4][0])
            for item in socket.getaddrinfo(host, port, type=socket.SOCK_STREAM)
        )
    except socket.gaierror as error:
        raise ValueError(f"target host cannot be resolved: {host}") from error


def _addresses_in_scope(
    addresses: Iterable[ipaddress.IPv4Address | ipaddress.IPv6Address],
    policy: ScopePolicy,
) -> bool:
    addresses = tuple(addresses)
    return bool(addresses) and all(
        any(address in network for network in policy.allowed_cidrs)
        for address in addresses
    )


def validate_target(
    value: str,
    policy: ScopePolicy | None = None,
    *,
    resolver: Callable[[str, int], frozenset[ipaddress.IPv4Address | ipaddress.IPv6Address]] = _resolve,
) -> str:
    policy = policy or load_scope_manifest()
    parsed = urllib.parse.urlparse(value)
    if parsed.scheme not in {"http", "https"} or not parsed.hostname:
        raise ValueError("target must be an absolute HTTP(S) URL")
    if parsed.username or parsed.password or parsed.query or parsed.fragment:
        raise ValueError("target must not contain credentials, query or fragment")

    host = _normalize_host(parsed.hostname)
    if host not in policy.allowed_hosts:
        raise ValueError(f"target host is not explicitly allowed: {host}")
    port = parsed.port or (443 if parsed.scheme == "https" else 80)
    addresses = resolver(host, port)
    if not _addresses_in_scope(addresses, policy):
        raise ValueError("target resolves outside the allowed CIDRs")
    return value.rstrip("/")


class ScopeRedirectHandler(urllib.request.HTTPRedirectHandler):
    """Validate every redirect and refuse redirects beyond the policy limit."""

    def __init__(self, policy: ScopePolicy):
        super().__init__()
        self.policy = policy
        self.redirects = 0

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        self.redirects += 1
        if self.redirects > self.policy.max_redirects:
            raise urllib.error.HTTPError(
                req.full_url, code, "redirect limit exceeded", headers, fp
            )
        validate_target(newurl, self.policy)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def scoped_opener(policy: ScopePolicy) -> urllib.request.OpenerDirector:
    return urllib.request.build_opener(ScopeRedirectHandler(policy))


def main() -> int:
    target = sys.argv[1] if len(sys.argv) > 1 else ""
    manifest = sys.argv[2] if len(sys.argv) > 2 else DEFAULT_SCOPE
    try:
        print(validate_target(target, load_scope_manifest(manifest)))
    except (OSError, ValueError) as error:
        print(f"target rejected: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
