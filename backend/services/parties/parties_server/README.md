# Parties Server

`parties_server` owns business actors and memberships.

It owns:

- companies;
- associations;
- consultant practices;
- memberships between `users.UserProfile` ids and parties.

It does not own authentication or human profile details.

## Local Runtime

Use the local setup script from `parties_server/`:

```bash
./docker/script/setup_vault_approle.sh
```

Runtime ports:

```text
API      127.0.0.1:8480
Insights 127.0.0.1:8481
Web      127.0.0.1:8482
Postgres 127.0.0.1:8490
Redis    127.0.0.1:8491
Vault    127.0.0.1:8500
```

## Tests

Run from `parties_server/`:

```bash
./docker/script/run_serverpod_tests.sh
```

