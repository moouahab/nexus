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

## Service-to-Service Auth Rule

User access tokens and service tokens are distinct contracts.

User access tokens:

- use `typ=access`;
- use `sub=<identityId>`;
- include `sid`, `email_verified`, and `amr`;
- target the public API audience, currently `nexus-api`.

Service tokens:

- use `typ=service`;
- use `sub=service:<service-name>`;
- target the called service as `aud`, for example `projects-service`;
- include a space-separated or list `scope` claim;
- are accepted only when the target service validates issuer, audience, expiry,
  token type, and required scopes.

Services must not treat `session.request == null` as an authorization boundary.
Internal-only operations should require an explicit service token and scope once
they are exposed through a service API.

## Cross-Platform API Rule

Public capabilities must not require Flutter, Dart, browser cookies, or a
platform-specific SDK. A public API is exposed as versioned HTTPS JSON and is
described by an OpenAPI contract.

Serverpod RPC endpoints may remain available for generated Dart clients, but
they must call the same application services as the public HTTP routes. They
must not contain a second implementation of business rules or authorization.

Public contracts use:

- `Authorization: Bearer <token>` as the portable authentication mechanism;
- UUID strings for identifiers;
- UTC ISO-8601 timestamps;
- explicit request size limits;
- stable machine-readable error codes;
- cursor or bounded offset pagination for collections;
- `/v1` versioned paths.

Cookie transport may be offered to web applications as an additional security
mechanism, but must not be the only way to authenticate. Native, desktop, CLI,
and server clients must be able to use bearer tokens without emulating a web
browser.

An HTTP route and its Serverpod RPC equivalent must enforce the same audience,
scope, tenant, and resource authorization checks.
