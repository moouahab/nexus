# Shared Backend

This directory is reserved for backend assets that are really shared by several
services.

Acceptable content:

- shared API client helpers
- inter-service error contracts
- common value objects with no service ownership
- test helpers reused by several services
- documentation for cross-service contracts

Not acceptable:

- Identity authentication logic
- Projects registry business rules
- service-specific database models
- service-specific secrets
- service-specific migrations

Rule: if only one service uses it, keep it in that service.

