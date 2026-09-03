# Identity Auth Structure

Detailed architecture and API documentation: `ARCHITECTURE.md`.

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
| interface | `UsernamePolicy` | `validate` | Rejects malformed public usernames. |
| interface | `EmailPolicy` | `validate` | Rejects malformed optional email addresses. |
| interface | `PasswordHasher` | `hashPassword`, `verifyPassword` | Contract for password hashing and verification. |
| interface | `PasswordPolicy` | `validate` | Rejects weak or account-derived passwords before hashing. |
| interface | `SecretHasher` | `hashSecret`, `verifySecret` | Contract for hashing refresh token secrets. |
| interface | `AccessTokenService` | `createAccessToken`, `verifyAccessToken` | Contract for JWT access token creation and verification. |
| interface | `AccessTokenReader` | `readAccessToken` | Reads access token from cookie first, then `Authorization: Bearer`. |
| interface | `RefreshTokenSecretService` | `createSecret`, `verifySecret` | Contract for raw refresh token secret generation and verification. |
| interface | `AuthCookieService` | `createAuthCookies`, `clearAuthCookies`, `readCookie` | Contract for auth cookies without coupling use cases to a web framework. |
| interface | `RefreshTokenCodec` | `encode`, `decode` | Contract for the refresh cookie value format. |
| interface | `OAuthProviderVerifier` | `verify` | Contract for Google/GitHub/Apple authorization-code verification. |
| validation | `TerminationRule` | `validateAll` | Sync validation table for stop conditions instead of repeated `if` blocks. |
| validation | `AsyncTerminationRule` | `validateAll` | Async validation table with optional cleanup before throwing. |
| domain | `AuthClaims` | `access`, `fromJson`, `toJson` | Typed JWT claims: `sub`, `sid`, `iss`, `aud`, `typ`, `iat`, `exp`, `email_verified`, `amr`. |
| domain | `RefreshTokenSecret` | `raw`, `hash` | Pair returned when creating a refresh token secret. Raw goes to cookie, hash goes to DB. |
| domain | `RefreshTokenCookieValue` | `refreshTokenId`, `secret` | Parsed refresh cookie value. |
| domain | `AuthResult` | `identityId`, `authSessionId`, `responseHeaders` | Result returned by auth use cases. |
| domain | `AuthTokenTransport` | `cookie`, `body` | Selects web cookie response or app body-token response. |
| domain | `AuthCookieOptions` | `development`, `production` | Cookie security options for access and refresh tokens. |
| application | `AuthTokenIssuer` | `issue` | Creates `AuthSession`, access JWT, refresh token row, and auth cookies. |
| application | `RegisterWithUsernameUseCase` | `execute` | Creates identity, password credential, username provider, then signs in. |
| application | `LoginWithUsernameUseCase` | `execute` | Verifies username/password, checks identity status, then signs in. |
| application | `LoginWithOAuthUseCase` | `execute` | Verifies provider authorization code, links or creates identity, then signs in. |
| application | `RefreshSessionUseCase` | `execute` | Reads refresh cookie, verifies secret, rotates refresh token, issues new cookies. |
| application | `LogoutUseCase` | `execute` | Revokes refresh token and session, then clears auth cookies. |
| infrastructure | `Serverpod*Repository` | implements interfaces | Serverpod/Postgres implementation. |
| infrastructure | `DefaultUsernamePolicy` | implements `UsernamePolicy` | Lowercase username length and character checks. |
| infrastructure | `DefaultEmailPolicy` | implements `EmailPolicy` | Length, domain, and basic mailbox syntax checks. |
| infrastructure | `Argon2PasswordHasher` | implements `PasswordHasher` | PHC Argon2 password hashes with pepper support. |
| infrastructure | `DefaultPasswordPolicy` | implements `PasswordPolicy` | Minimum length, maximum length, common password, and account-token checks. |
| infrastructure | `Argon2SecretHasher` | implements `SecretHasher` | PHC Argon2 hashes for refresh token secrets. |
| infrastructure | `HmacSha256AccessTokenService` | implements `AccessTokenService` | Creates and verifies compact HS256 JWTs. |
| infrastructure | `SecureRefreshTokenSecretService` | implements `RefreshTokenSecretService` | Generates URL-safe random refresh secrets and hashes them. |
| infrastructure | `ColonRefreshTokenCodec` | implements `RefreshTokenCodec` | Encodes refresh cookie as `refreshTokenId:secret`. |
| infrastructure | `HeaderAuthCookieService` | implements `AuthCookieService` | Builds `Set-Cookie` headers and reads Cookie headers. |
| infrastructure | `HeaderAccessTokenReader` | implements `AccessTokenReader` | Reads `access_token` cookie first, then `Authorization: Bearer`. |
| infrastructure | `GoogleOAuthProviderVerifier` | implements `OAuthProviderVerifier` | Exchanges Google OAuth code and reads OpenID user info. |
| infrastructure | `GitHubOAuthProviderVerifier` | implements `OAuthProviderVerifier` | Exchanges GitHub OAuth code and reads GitHub user info/email. |
| infrastructure | `AppleOAuthProviderVerifier` | implements `OAuthProviderVerifier` | Exchanges Apple authorization code and reads Apple ID token claims. |
| routes | `AuthJsonRoute` | `handleCall`, `readJsonBody`, `jsonResponse` | Common JSON HTTP route behavior. |
| routes | `AuthDependencies` | `fromSession` | Builds repositories, security services, use cases from `Session`. |
| routes | `AuthRegisterRoute` | `POST /auth/register` | Calls `RegisterWithUsernameUseCase`. |
| routes | `AuthLoginRoute` | `POST /auth/login` | Calls `LoginWithUsernameUseCase`. |
| routes | `AuthOAuthLoginRoute` | `POST /auth/oauth/login` | Calls `LoginWithOAuthUseCase`. |
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

## Token Transport

Web clients use the default cookie transport. `register`, `login`, and
`refresh` return `HttpOnly` auth cookies and do not expose tokens in JSON.
They also return a readable `csrf_token` cookie. Cookie-based clients must send
that value as `X-CSRF-Token` when calling state-changing auth routes that rely
on auth cookies, such as `POST /auth/refresh` and `POST /auth/logout`.

App clients can request body tokens with either:

```http
X-Auth-Token-Transport: body
```

or:

```json
{
  "tokenTransport": "body"
}
```

In body mode, `register`, `login`, and `refresh` return:

```json
{
  "identityId": "...",
  "authSessionId": "...",
  "tokenType": "Bearer",
  "accessToken": "...",
  "refreshToken": "...",
  "expiresIn": 900,
  "refreshExpiresIn": 2592000
}
```

Protected routes accept:

```http
Cookie: access_token=...
```

or:

```http
Authorization: Bearer ...
```

The cookie token is preferred when both are present.

## OAuth Login

Google, GitHub, and Apple use the same Nexus session/token system as username
login. The client completes the provider authorization redirect and sends the
authorization code to the Identity API:

```http
POST /auth/oauth/login
Content-Type: application/json
```

```json
{
  "provider": "google",
  "code": "...",
  "redirectUri": "https://app.example.com/auth/callback",
  "codeVerifier": "...",
  "tokenTransport": "body"
}
```

`provider` can be `google`, `github`, or `apple`. `codeVerifier` is optional
and should be sent when the frontend used PKCE. The response is the same as
`/auth/login`: cookies by default, or bearer tokens when `tokenTransport` is
`body`.

Server secrets are prepared per provider, but each provider stays disabled until
its explicit flag is enabled. This lets the API ship with OAuth wiring in place
without accepting OAuth login before the external account is ready:

```yaml
googleOAuthEnabled: "false"
googleOAuthClientId: ...
googleOAuthClientSecret: ...
githubOAuthEnabled: "false"
githubOAuthClientId: ...
githubOAuthClientSecret: ...
appleOAuthEnabled: "false"
appleOAuthClientId: ...
appleOAuthClientSecret: ...
```

Set a provider flag to `"true"` only after its client id, client secret, and
redirect URI are configured with the provider. Apple uses a pre-generated Apple
client secret JWT as `appleOAuthClientSecret`; the backend verifies the Apple
`id_token` signature and claims with Apple's JWKS before accepting the login.

OAuth HTTP calls use bounded timeouts so an external provider cannot hold auth
workers indefinitely.

Account linking rules:

- Existing `(provider, providerUserId)` links sign in the same identity.
- A new provider with a verified email links to an existing identity using that
  email.
- A new provider with an unverified email that is already used is rejected.
- Disabled identities cannot sign in through OAuth.

## Browser Origin Guard

Browser auth calls with an `Origin` header must match `authAllowedOrigins` from
`serverpod-passwords.yaml`. Mobile and server-to-server clients normally do not
send `Origin` and are not blocked by this guard.

Use the reverse proxy as the first CORS layer for the real web frontend. The
example at `docker/proxy/Caddyfile.example` shows HTTPS, security headers, and
credentialed CORS for `/auth/*`.

`tokenTransport: "body"` is intended for mobile/desktop clients. Browser-like
requests are rejected from body token transport when they include headers such
as `Origin`, `Referer`, `Cookie`, or `Sec-Fetch-*`.

## Security Audit Logs

Auth flows emit `[AuthAudit]` structured logs for login, refresh, password
change, password reset, code sending, and blocked browser origins. Audit logs do
not include passwords, tokens, OTP codes, OAuth codes, code verifiers, or client
secrets. User-controlled subjects are SHA-256 hashed after normalization.
