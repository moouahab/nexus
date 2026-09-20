import os
import unittest
from unittest.mock import patch

from security.scripts.target_guard import validate_target


class TargetGuardTest(unittest.TestCase):
    def test_accepts_loopback(self):
        self.assertEqual(validate_target("http://127.0.0.1:8000/"), "http://127.0.0.1:8000")

    def test_rejects_remote_without_acknowledgement(self):
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaises(ValueError):
                validate_target("https://example.com")

    def test_rejects_embedded_credentials(self):
        with self.assertRaises(ValueError):
            validate_target("https://user:secret@localhost:8443")


if __name__ == "__main__":
    unittest.main()
