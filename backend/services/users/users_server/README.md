# Users Server

`users_server` owns functional NEXUS human profiles.

It owns:

- user profiles linked to Identity by `identityId`;
- display/profile metadata;
- the preferred party UUID as an external reference.

It does not own authentication or parties. Identity remains responsible for
login, sessions, tokens, password, email verification, and OAuth. Parties owns
companies, associations, consultant practices, and memberships.

## Cross-platform HTTP API

The Serverpod RPC endpoint remains available to Dart clients. The public JSON
facade is mounted by Kong below `/v1/users` and is documented by
`../openapi/openapi.yaml`. It uses bearer JWT authentication, UUID strings,
ISO-8601 UTC dates, stable error codes, a 256 KiB request-body limit, and
`Cache-Control: no-store` responses.

User tokens are restricted to their own profile. Service tokens must target
the `users-service` audience and carry `users.profile.read` or
`users.profile.write`. Both transports execute the existing `UserEndpoint`
and `UserProfileService` rules.

## Local Runtime

Use the local setup script from `users_server/`:

```bash
./docker/script/setup_vault_approle.sh
```

Runtime ports:

```text
API      127.0.0.1:8380
Insights 127.0.0.1:8381
Web      127.0.0.1:8382
Postgres 127.0.0.1:8390
Redis    127.0.0.1:8391
Vault    127.0.0.1:8400
```

## Tests

Run from `users_server/`:

```bash
./docker/script/run_serverpod_tests.sh
```
