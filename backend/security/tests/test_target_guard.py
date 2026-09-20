import ipaddress
import tempfile
import unittest
from pathlib import Path

from security.scripts.target_guard import ScopeRedirectHandler, load_scope_manifest, validate_target


class TargetGuardTest(unittest.TestCase):
    def setUp(self):
        self.policy = load_scope_manifest()

    def test_accepts_loopback(self):
        self.assertEqual(validate_target("http://127.0.0.1:8000/", self.policy), "http://127.0.0.1:8000")

    def test_rejects_remote_even_without_legacy_acknowledgement(self):
        with self.assertRaises(ValueError):
            validate_target("https://example.com", self.policy)

    def test_rejects_embedded_credentials(self):
        with self.assertRaises(ValueError):
            validate_target("https://user:secret@localhost:8443", self.policy)

    def test_rejects_allowed_hostname_resolving_outside_cidr(self):
        resolver = lambda _host, _port: frozenset({ipaddress.ip_address("203.0.113.8")})
        with self.assertRaisesRegex(ValueError, "outside"):
            validate_target("http://localhost:8000", self.policy, resolver=resolver)

    def test_rejects_mixed_dns_answer_to_limit_simple_rebinding(self):
        resolver = lambda _host, _port: frozenset({
            ipaddress.ip_address("127.0.0.1"),
            ipaddress.ip_address("203.0.113.8"),
        })
        with self.assertRaisesRegex(ValueError, "outside"):
            validate_target("http://localhost:8000", self.policy, resolver=resolver)

    def test_redirects_are_denied_by_default(self):
        handler = ScopeRedirectHandler(self.policy)
        request = type("Request", (), {"full_url": "http://127.0.0.1:8000"})()
        with self.assertRaisesRegex(Exception, "redirect limit"):
            handler.redirect_request(request, None, 302, "Found", {}, "http://127.0.0.1:8001")

    def test_manifest_rejects_empty_allowlists(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "scope.yaml"
            path.write_text(
                "environment: test\nallowedHosts:\nallowedCidrs:\n  - 127.0.0.0/8\ndestructive: false\n",
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "allowedHosts"):
                load_scope_manifest(path)


if __name__ == "__main__":
    unittest.main()
