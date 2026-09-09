# Service Conventions

Backend services follow the same shape, but keep their ownership isolated.

## Required Ownership

Each service owns:

- its Serverpod server and client packages;
- its database and migrations;
- its local and production secrets;
- its Docker Compose service names, volumes, and ports;
- its domain models, endpoints, and application services.

Shared runtime mechanics live under:

```text
backend/infrastructure/service-runtime/
```

Services consume that runtime through their own Compose and script wrappers.

## Database Rule

Every service has its own database.

Examples:

```text
identity -> identity database
parties -> parties database
projects -> projects database
users    -> users database
entities -> entities database
legal    -> legal database
```

Services must not query another service database directly.

## Secrets Rule

Each service declares only the secrets it actually needs.

Common minimum for a simple Serverpod service:

```text
postgres_password
redis_password
service_secret
vault_dev_root_token
vault_role_id
vault_secret_id
postgres_test_password
redis_test_password
```

Service-specific secrets stay in that service.

Example:

- SMTP, OAuth, and JWT auth secrets belong to `identity`.
- User profile data belongs to `users`.
- Party, organization, and membership data belongs to `parties`.
- Archive storage secrets belong to `projects` only when archive storage is
  implemented.

`secrets/` is never shared across services. Each service keeps its own
`secrets/` and `secrets_example/` directories.

## Inter-Service Rule

Services communicate through API contracts or dedicated service clients.

Correct:

```text
projects -> users API
projects -> entities API
legal -> projects API
```

Avoid:

```text
projects -> users database
legal -> projects database
identity -> central database for every service
```
