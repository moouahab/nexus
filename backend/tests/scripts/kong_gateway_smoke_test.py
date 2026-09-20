#!/usr/bin/env python3
"""Minimal NEXUS Kong gateway integration smoke test.

Flow:
  1. Register and login through Kong Identity REST routes.
  2. Call Users, Parties, and Projects REST routes through Kong.

The test intentionally avoids direct service ports and hardcoded secrets. It is
designed to fail with actionable diagnostics while the Identity RSA/JWKS runtime
issue is still present, then pass once Identity token issuance is fixed.
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from typing import Any


DEFAULT_GATEWAY_URL = "http://127.0.0.1:8000"
TIMEOUT_SECONDS = 15


@dataclass(frozen=True)
class HttpResponse:
    status: int
    body: str
    json: Any


class SmokeTestFailure(Exception):
    pass


def main() -> int:
    gateway_url = os.environ.get("NEXUS_GATEWAY_URL", DEFAULT_GATEWAY_URL)
    gateway_url = gateway_url.rstrip("/")
    _require_gateway_url(gateway_url)

    run_id = str(int(time.time() * 1000))
    username = f"kong_smoke_{run_id}"
    password = f"NexusSmoke!{run_id}"
    email = f"{username}@example.invalid"

    print(f"gateway: {gateway_url}")
    print("flow: register -> login -> users REST -> parties REST -> projects REST")

    jwks = _get(f"{gateway_url}/.well-known/jwks.json")
    _expect_status(jwks, 200, "JWKS must be available through Kong")
    keys = _expect_json_object(jwks, "JWKS response")
    if not isinstance(keys.get("keys"), list) or not keys["keys"]:
        raise SmokeTestFailure("JWKS response does not contain any public key.")
    print("ok: jwks available")

    registered = _post_json(
        f"{gateway_url}/v1/auth/register",
        {
            "username": username,
            "password": password,
            "confirmPassword": password,
            "email": email,
            "tokenTransport": "body",
        },
        headers={"X-Auth-Token-Transport": "body"},
    )
    _expect_status(registered, 200, "register via Kong")
    register_body = _expect_json_object(registered, "register response")
    access_token = _expect_string(register_body, "accessToken", "register response")
    identity_id = _expect_string(register_body, "identityId", "register response")
    print("ok: register via /v1/auth")

    logged_in = _post_json(
        f"{gateway_url}/v1/auth/login",
        {
            "username": username,
            "password": password,
            "tokenTransport": "body",
        },
        headers={"X-Auth-Token-Transport": "body"},
    )
    _expect_status(logged_in, 200, "login via Kong")
    login_body = _expect_json_object(logged_in, "login response")
    access_token = _expect_string(login_body, "accessToken", "login response")
    print("ok: login via /v1/auth")

    auth_headers = {"Authorization": f"Bearer {access_token}"}

    profile_response = _put_json(
        f"{gateway_url}/v1/users/me",
        {
            "displayName": "Kong Smoke Test",
            "kind": "consultant",
            "primaryPartyId": None,
            "email": email,
            "avatarUri": None,
            "bio": None,
            "locale": "en",
            "timezone": "UTC",
            "metadata": {"source": "kong_gateway_smoke_test"},
        },
        headers=auth_headers,
    )
    _expect_status(profile_response, 200, "users complete profile via REST")
    profile = _expect_json_object(profile_response, "user profile response")
    user_profile_id = _expect_string(profile, "id", "user profile response")
    if profile.get("identityId") != identity_id:
        raise SmokeTestFailure(
            "Users service returned a profile for a different identityId."
        )
    print("ok: users completeMyProfile via /v1/users")

    my_profile_response = _get(
        f"{gateway_url}/v1/users/me", headers=auth_headers
    )
    _expect_status(my_profile_response, 200, "users get profile via REST")
    my_profile = _expect_json_object(my_profile_response, "my profile response")
    if my_profile.get("id") != user_profile_id:
        raise SmokeTestFailure("Users getMyProfile did not return created profile.")
    print("ok: users getMyProfile via /v1/users")

    party_response = _post_json(
        f"{gateway_url}/v1/parties/parties",
        {
            "kind": "consultantPractice",
            "name": f"Kong Smoke Party {run_id}",
            "legalName": None,
            "registrationNumber": None,
            "country": "FR",
            "website": None,
            "metadata": {"source": "kong_gateway_smoke_test"},
        },
        headers=auth_headers,
    )
    _expect_status(party_response, 200, "parties create via REST")
    party = _expect_json_object(party_response, "party response")
    party_id = _expect_string(party, "id", "party response")
    print("ok: parties createParty via /v1/parties")

    parties_response = _get(
        f"{gateway_url}/v1/parties/parties?limit=10&offset=0",
        headers=auth_headers,
    )
    _expect_status(parties_response, 200, "parties list via REST")
    parties_body = _expect_json_object(parties_response, "parties response")
    if not isinstance(parties_body.get("items"), list):
        raise SmokeTestFailure("Parties REST response does not contain items.")
    print("ok: parties listParties via /v1/parties")

    project_response = _post_json(
        f"{gateway_url}/v1/projects/projects",
        {
            "slug": f"kong-smoke-{run_id}",
            "name": f"Kong Smoke Project {run_id}",
            "tenantPartyId": party_id,
            "summary": "Gateway integration smoke test project.",
            "visibility": "private",
            "workspacePath": None,
            "tags": ["smoke-test"],
            "metadata": {"source": "kong_gateway_smoke_test"},
        },
        headers=auth_headers,
    )
    _expect_status(project_response, 201, "projects create via REST")
    project = _expect_json_object(project_response, "project response")
    project_id = _expect_string(project, "id", "project response")
    print("ok: projects createMyProject via /v1/projects")

    projects_response = _get(
        f"{gateway_url}/v1/projects/tenants/{party_id}/projects",
        headers=auth_headers,
    )
    _expect_status(projects_response, 200, "projects list via REST")
    projects_body = _expect_json_object(projects_response, "projects response")
    projects = projects_body.get("items")
    if not isinstance(projects, list):
        raise SmokeTestFailure("Projects REST response does not contain items.")
    if not any(item.get("id") == project_id for item in projects if isinstance(item, dict)):
        raise SmokeTestFailure("Projects listProjects did not include created project.")
    print("ok: projects listProjects via /v1/projects")

    print("success: Kong gateway smoke test passed")
    return 0


def _require_gateway_url(gateway_url: str) -> None:
    parsed = urllib.parse.urlparse(gateway_url)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise SmokeTestFailure(f"Invalid NEXUS_GATEWAY_URL: {gateway_url!r}")

    direct_service_ports = {8182, 8280, 8380, 8480}
    port = parsed.port
    if port in direct_service_ports:
        raise SmokeTestFailure(
            f"NEXUS_GATEWAY_URL points to direct service port {port}; use Kong "
            f"gateway instead, normally {DEFAULT_GATEWAY_URL}."
        )


def _get(
    url: str, headers: dict[str, str] | None = None
) -> HttpResponse:
    request_headers = {"Accept": "application/json"}
    request_headers.update(headers or {})
    return _request("GET", url, headers=request_headers)


def _put_json(
    url: str,
    body: dict[str, Any],
    headers: dict[str, str] | None = None,
) -> HttpResponse:
    payload = json.dumps(body).encode("utf-8")
    request_headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
    }
    request_headers.update(headers or {})
    return _request("PUT", url, data=payload, headers=request_headers)


def _post_json(
    url: str,
    body: dict[str, Any],
    headers: dict[str, str] | None = None,
) -> HttpResponse:
    payload = json.dumps(body).encode("utf-8")
    request_headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
    }
    request_headers.update(headers or {})
    return _request("POST", url, data=payload, headers=request_headers)


def _request(
    method: str,
    url: str,
    data: bytes | None = None,
    headers: dict[str, str] | None = None,
) -> HttpResponse:
    request = urllib.request.Request(
        url,
        data=data,
        headers=headers or {"Accept": "application/json"},
        method=method,
    )
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
            body = response.read().decode("utf-8", errors="replace")
            return HttpResponse(response.status, body, _decode_json(body))
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", errors="replace")
        return HttpResponse(error.code, body, _decode_json(body))
    except urllib.error.URLError as error:
        raise SmokeTestFailure(f"Cannot reach {url}: {error}") from error


def _decode_json(body: str) -> Any:
    if not body.strip():
        return None
    try:
        return json.loads(body)
    except json.JSONDecodeError:
        return None


def _expect_status(response: HttpResponse, expected: int, context: str) -> None:
    if response.status == expected:
        return

    details = response.body.strip() or "<empty body>"
    if response.status in {500, 502}:
        details += (
            "\nPossible current blocker: Identity cannot issue or expose RS256 "
            "tokens because its RSA/JWKS secret is invalid at runtime."
        )

    raise SmokeTestFailure(
        f"{context} failed: expected HTTP {expected}, got {response.status}.\n"
        f"Response: {details}"
    )


def _expect_json_object(response: HttpResponse, context: str) -> dict[str, Any]:
    if isinstance(response.json, dict):
        return response.json
    raise SmokeTestFailure(f"{context} is not a JSON object: {response.body!r}")


def _expect_string(body: dict[str, Any], field: str, context: str) -> str:
    value = body.get(field)
    if isinstance(value, str) and value:
        return value
    raise SmokeTestFailure(f"{context} does not contain string field {field!r}.")


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SmokeTestFailure as error:
        print(f"failure: {error}", file=sys.stderr)
        raise SystemExit(1)
