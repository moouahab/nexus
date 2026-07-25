# Identity Auth Structure

| Layer | Class/File | Main functions | Role |
| --- | --- | --- | --- |
| constants | `AuthClaimNames` | claim names | JWT keys: `sub`, `sid`, `iss`, `aud`, `typ`, `iat`, `exp`, `email_verified`, `amr`. |
| constants | `AuthCookieNames` | cookie names | Central names for `access_token` and `refresh_token`. |
| constants | `AuthTokenTypes` | token type names | Avoid string duplication for `access` and `refresh`. |
| constants | `AuthTokenDefaults` | default lifetimes | Default issuer, audience, access token lifetime, refresh token lifetime. |
| interface | `IdentityRepository` | `create`, `findById`, `findByEmail`, `findByUsername`, `updateStatus`, `markEmailVerified` | Contract for technical identities. |
| interface | `IdentityProviderRepository` | `create`, `findByProviderUserId`, `findByIdentityId`, `markUsed` | Contract for Google/GitHub/Apple links. |
| interface | `PasswordCredentialRepository` | `create`, `findByUsername`, `updatePasswordHash` | Contract for username/password credentials. |
| interface | `AuthSessionRepository` | `create`, `findById`, `findActiveById`, `touch`, `revoke`, `revokeAllForIdentity` | Contract for sessions used as JWT `sid`. |
| interface | `AuthRefreshTokenRepository` | `create`, `findById`, `findActiveById`, `revoke`, `rotate` | Contract for refresh token persistence. |
| interface | `PasswordHasher` | `hashPassword`, `verifyPassword` | Contract for password hashing and verification. |
| interface | `SecretHasher` | `hashSecret`, `verifySecret` | Contract for hashing refresh token secrets. |
| interface | `AccessTokenService` | `createAccessToken`, `verifyAccessToken` | Contract for JWT access token creation and verification. |
| interface | `RefreshTokenSecretService` | `createSecret`, `verifySecret` | Contract for raw refresh token secret generation and verification. |
| interface | `AuthCookieService` | `createAuthCookies`, `clearAuthCookies`, `readCookie` | Contract for auth cookies without coupling use cases to a web framework. |
| interface | `RefreshTokenCodec` | `encode`, `decode` | Contract for the refresh cookie value format. |
| validation | `TerminationRule` | `validateAll` | Sync validation table for stop conditions instead of repeated `if` blocks. |
| validation | `AsyncTerminationRule` | `validateAll` | Async validation table with optional cleanup before throwing. |
| domain | `AuthClaims` | `access`, `fromJson`, `toJson` | Typed JWT claims: `sub`, `sid`, `iss`, `aud`, `typ`, `iat`, `exp`, `email_verified`, `amr`. |
| domain | `RefreshTokenSecret` | `raw`, `hash` | Pair returned when creating a refresh token secret. Raw goes to cookie, hash goes to DB. |
| domain | `RefreshTokenCookieValue` | `refreshTokenId`, `secret` | Parsed refresh cookie value. |
| domain | `AuthResult` | `identityId`, `authSessionId`, `responseHeaders` | Result returned by auth use cases. |
| domain | `AuthCookieOptions` | `development`, `production` | Cookie security options for access and refresh tokens. |
| application | `AuthTokenIssuer` | `issue` | Creates `AuthSession`, access JWT, refresh token row, and auth cookies. |
| application | `RegisterWithUsernameUseCase` | `execute` | Creates identity, password credential, username provider, then signs in. |
| application | `LoginWithUsernameUseCase` | `execute` | Verifies username/password, checks identity status, then signs in. |
| application | `RefreshSessionUseCase` | `execute` | Reads refresh cookie, verifies secret, rotates refresh token, issues new cookies. |
| application | `LogoutUseCase` | `execute` | Revokes refresh token and session, then clears auth cookies. |
| infrastructure | `Serverpod*Repository` | implements interfaces | Serverpod/Postgres implementation. |
| infrastructure | `Argon2PasswordHasher` | implements `PasswordHasher` | PHC Argon2 password hashes with pepper support. |
| infrastructure | `Argon2SecretHasher` | implements `SecretHasher` | PHC Argon2 hashes for refresh token secrets. |
| infrastructure | `HmacSha256AccessTokenService` | implements `AccessTokenService` | Creates and verifies compact HS256 JWTs. |
| infrastructure | `SecureRefreshTokenSecretService` | implements `RefreshTokenSecretService` | Generates URL-safe random refresh secrets and hashes them. |
| infrastructure | `ColonRefreshTokenCodec` | implements `RefreshTokenCodec` | Encodes refresh cookie as `refreshTokenId:secret`. |
| infrastructure | `HeaderAuthCookieService` | implements `AuthCookieService` | Builds `Set-Cookie` headers and reads Cookie headers. |
| routes | `AuthJsonRoute` | `handleCall`, `readJsonBody`, `jsonResponse` | Common JSON HTTP route behavior. |
| routes | `AuthDependencies` | `fromSession` | Builds repositories, security services, use cases from `Session`. |
| routes | `AuthRegisterRoute` | `POST /auth/register` | Calls `RegisterWithUsernameUseCase`. |
| routes | `AuthLoginRoute` | `POST /auth/login` | Calls `LoginWithUsernameUseCase`. |
| routes | `AuthRefreshRoute` | `POST /auth/refresh` | Calls `RefreshSessionUseCase`. |
| routes | `AuthLogoutRoute` | `POST /auth/logout` | Calls `LogoutUseCase`. |
| routes | `registerAuthRoutes` | route table + `for` loop | Registers all auth routes dynamically. |

Next layers:

| Step | Folder | Purpose |
| --- | --- | --- |
| security services | `infrastructure/security/` | Done: password hashing, JWT signing/verification, refresh token secret generation. |
| cookie service | `infrastructure/http/` | Done: Set, clear, and read auth cookies through plain headers. |
| use cases | `application/use_cases/` | Done: username register/login, refresh session, logout. |
| endpoints/routes | `routes/` | Done: Thin HTTP routes calling use cases and returning JSON + cookies. |
