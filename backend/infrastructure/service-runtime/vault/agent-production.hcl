pid_file = "/vault/token/vault-agent.pid"

vault {
  address = "__VAULT_ADDRESS__"
  ca_cert = "/vault/tls/ca.crt"

  retry {
    num_retries = 12
  }
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"

    config = {
      role_id_file_path                   = "/vault/runtime/role_id"
      secret_id_file_path                 = "/vault/runtime/secret_id"
      remove_secret_id_file_after_reading = false
    }
  }

  sink "file" {
    config = {
      path = "/vault/token/agent-token"
    }
  }
}

template_config {
  static_secret_render_interval = "5m"
  exit_on_retry_failure         = true
}

template {
  source      = "/vault/templates/postgres_password.ctmpl"
  destination = "/vault/secrets/postgres/postgres_password"
  perms       = "0440"
}

template {
  source      = "/vault/templates/redis_password.ctmpl"
  destination = "/vault/secrets/redis/redis_password"
  perms       = "0444"
}

template {
  source      = "/vault/templates/serverpod-passwords.yaml.ctmpl"
  destination = "/vault/secrets/api/serverpod-passwords.yaml"
  perms       = "0444"
}
