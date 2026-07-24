pid_file = "/vault/token/vault-agent.pid"

vault {
  address = "http://vault:8200"

  retry {
    num_retries = 12
  }
}

auto_auth {
  method "approle" {
    mount_path = "auth/approle"

    config = {
      role_id_file_path                   = "/run/secrets/role_id"
      secret_id_file_path                 = "/run/secrets/secret_id"
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
  destination = "/vault/secrets/postgres_password"
  perms       = "0440"
}

template {
  source      = "/vault/templates/redis_password.ctmpl"
  destination = "/vault/secrets/redis_password"
  perms       = "0440"
}
