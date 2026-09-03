# Identity Auth Architecture

Ce document explique l'infrastructure du code auth et l'API HTTP exposee par le
service `identity_server`.

## Objectif du Service

Le service identity gere l'identite technique et l'authentification. Il ne gere
pas le profil complet d'un utilisateur.

Responsabilites incluses:

- creer une identite technique;
- connecter avec username/password;
- preparer le lien avec Google, GitHub et Apple via `IdentityProvider`;
- emettre un JWT access token dans un cookie;
- emettre et stocker des refresh tokens rotatifs;
- proteger une route/API avec `RequireAuth`;
- bloquer le brute force avec Redis.

Responsabilites exclues:

- profil utilisateur complet;
- preferences utilisateur;
- donnees metier du compte;
- droits applicatifs fins hors presence d'une identity active.

Le lien avec les autres services se fait avec l'id technique `identity.id`.
Dans le JWT, cet id est le claim `sub`.

## Structure des Dossiers

```text
lib/src/auth/
  application/
    exceptions/
    interfaces/
    services/
    use_cases/
    validation/
  constants/
  domain/
  infrastructure/
    http/
    repositories/
    security/
  models/
  routes/
```

### `models/`

Contient les fichiers Serverpod `.spy.yaml`.

Ces fichiers decrivent les tables persistantes:

- `identity`: identite technique principale;
- `identity_provider`: lien vers username, Google, GitHub, Apple;
- `password_credential`: credential username/password;
- `auth_session`: session de connexion, utilisee comme claim JWT `sid`;
- `auth_refresh_token`: refresh token hash, rotation et revocation;
- `identity_status`: statut `active`, `pending`, `disabled`, `locked`,
  `deleted`;
- `auth_provider`: provider `username`, `google`, `github`, `apple`.

Les fichiers generes correspondants sont dans:

```text
lib/src/generated/auth/models/
```

### `constants/`

Centralise les noms qui ne doivent pas etre dupliques:

- `AuthClaimNames`: `sub`, `sid`, `iss`, `aud`, `typ`, `iat`, `exp`,
  `email_verified`, `amr`;
- `AuthCookieNames`: `access_token`, `refresh_token`;
- `AuthTokenDefaults`: issuer, audience, duree access token, duree refresh;
- `AuthTokenTypes`: `access`.

### `domain/`

Contient les objets metier simples, sans dependance DB.

- `AuthClaims`: representation typee des claims JWT.
- `AuthCookieOptions`: configuration cookie dev/prod.
- `AuthResult`: resultat retourne par les use cases/routes auth.
- `AuthenticatedRequest`: resultat d'une authentification valide pour une route
  protegee.
- `RefreshTokenCookieValue`: valeur parse du cookie refresh.
- `RefreshTokenSecret`: paire raw/hash lors de la creation d'un refresh token.

### `application/interfaces/`

Contrats utilises par les use cases. Les use cases dependent des interfaces, pas
des implementations Serverpod/Postgres/Redis.

Interfaces principales:

- `IdentityRepository`;
- `IdentityProviderRepository`;
- `PasswordCredentialRepository`;
- `AuthSessionRepository`;
- `AuthRefreshTokenRepository`;
- `PasswordHasher`;
- `SecretHasher`;
- `AccessTokenService`;
- `RefreshTokenSecretService`;
- `RefreshTokenCodec`;
- `AuthCookieService`;
- `LoginAttemptLimiter`.

### `application/use_cases/`

Contient la logique metier auth.

- `RegisterWithUsernameUseCase`
  - normalise username/email;
  - verifie que le username est libre;
  - cree `identity`;
  - cree `password_credential`;
  - cree `identity_provider` avec provider `username`;
  - appelle `AuthTokenIssuer`.

- `LoginWithUsernameUseCase`
  - normalise username;
  - verifie le rate limit Redis;
  - cherche le credential;
  - verifie le password;
  - verifie que l'identity existe et est `active`;
  - reset le compteur brute force au succes;
  - appelle `AuthTokenIssuer`.

- `RefreshSessionUseCase`
  - lit le cookie `refresh_token`;
  - decode `refreshTokenId:secret`;
  - cherche un refresh token actif;
  - verifie le secret contre le hash;
  - revoke le refresh token si le secret est faux;
  - cherche la session active;
  - verifie l'identity active;
  - cree un nouveau refresh token;
  - marque l'ancien token comme rotate;
  - emet un nouveau access token et de nouveaux cookies.

- `LogoutUseCase`
  - lit le cookie refresh;
  - revoke le refresh token;
  - revoke la session;
  - renvoie des cookies expires.

### `application/services/`

Services metier partages.

- `AuthTokenIssuer`
  - cree `auth_session`;
  - cree le JWT access;
  - cree le refresh token hash en DB;
  - encode le refresh cookie;
  - retourne les `Set-Cookie`.

- `RequireAuth`
  - lit `access_token`;
  - verifie JWT signature et claims;
  - extrait `sub` et `sid`;
  - verifie `sid` en DB avec `findActiveById`;
  - verifie `identity` en DB;
  - refuse si identity non active;
  - retourne `AuthenticatedRequest`.

### `infrastructure/repositories/`

Implementations Serverpod/Postgres des interfaces repository.

Chaque repository garde les requetes DB hors des use cases.

Exemple:

- `ServerpodIdentityRepository.findById`;
- `ServerpodAuthSessionRepository.findActiveById`;
- `ServerpodAuthRefreshTokenRepository.rotate`.

### `infrastructure/security/`

Implementations securite.

- `Argon2PasswordHasher`
  - hash password en PHC;
  - utilise un pepper issu des secrets Serverpod/Vault.

- `Argon2SecretHasher`
  - hash les secrets de refresh token;
  - ne stocke jamais le refresh secret brut.

- `HmacSha256AccessTokenService`
  - cree et verifie les JWT HS256;
  - verifie `iss`, `aud`, `typ`, `exp`;
  - utilise comparaison constant-time pour la signature.

- `SecureRefreshTokenSecretService`
  - genere un secret URL-safe;
  - retourne raw pour cookie et hash pour DB.

- `ColonRefreshTokenCodec`
  - format cookie refresh: `refreshTokenId:secret`.

- `RedisLoginAttemptLimiter`
  - stocke le compteur brute force dans Redis;
  - cle Redis hash avec sha256 du username;
  - incremente avec Lua `INCR + PEXPIRE` pour eviter les courses;
  - reset au login reussi.

### `infrastructure/http/`

- `HeaderAuthCookieService`
  - construit les cookies;
  - lit les cookies depuis les headers;
  - clear les cookies au logout.

Options cookie dev:

- `HttpOnly`;
- `SameSite=Lax`;
- pas de `Secure` en HTTP local;
- access token path `/`;
- refresh token path `/auth`.

Options cookie prod:

- ajoute `Secure`;
- garde `HttpOnly` et `SameSite=Lax`.

### `routes/`

Routes HTTP web server Serverpod.

- `AuthJsonRoute`
  - base JSON commune;
  - parse JSON body;
  - convertit les exceptions en reponses JSON;
  - retourne `AuthResult.responseBody()`.

- `AuthenticatedJsonRoute`
  - base pour routes protegees;
  - appelle `RequireAuth`;
  - passe `AuthenticatedRequest` a la route metier;
  - renvoie `401` si non connecte ou token/session invalide;
  - renvoie `403` si identity non active.

- `AuthRegisterRoute`
  - `POST /auth/register`.

- `AuthLoginRoute`
  - `POST /auth/login`.

- `AuthRefreshRoute`
  - `POST /auth/refresh`.

- `AuthLogoutRoute`
  - `POST /auth/logout`.

- `AuthMeRoute`
  - `GET /auth/me`;
  - `POST /auth/me`;
  - route protegee de diagnostic/session courante.

- `registerAuthRoutes`
  - table dynamique des routes;
  - boucle `for` pour enregistrer les routes.

## Flux HTTP

### Register

Endpoint:

```http
POST /auth/register
Content-Type: application/json
```

Body:

```json
{
  "username": "noxe",
  "password": "test-password",
  "email": "noxe@example.com"
}
```

Succes:

- cree identity;
- cree password credential;
- cree identity provider;
- cree auth session;
- cree refresh token;
- renvoie cookies `access_token` et `refresh_token`.

Reponse:

```json
{
  "identityId": "...",
  "authSessionId": "..."
}
```

Erreurs principales:

- `409 usernameAlreadyExists`;
- `409 emailAlreadyExists`;
- `400 invalid_request`;
- `500 missingGeneratedId`.

### Login

Endpoint:

```http
POST /auth/login
Content-Type: application/json
```

Body:

```json
{
  "username": "noxe",
  "password": "test-password"
}
```

Succes:

- verifie password;
- verifie identity active;
- cree une session;
- cree refresh token;
- renvoie les cookies.

Erreurs:

- `401 invalidCredentials`;
- `403 identityNotActive`;
- `429 tooManyAttempts`.

### Refresh

Endpoint:

```http
POST /auth/refresh
Cookie: refresh_token=...
```

Succes:

- verifie le refresh token;
- verifie la session active;
- verifie identity active;
- cree un nouveau refresh token;
- rotate l'ancien refresh token;
- renvoie nouveaux cookies.

Erreurs:

- `401 missingRefreshToken`;
- `401 invalidRefreshToken`;
- `403 identityNotActive`.

### Logout

Endpoint:

```http
POST /auth/logout
Cookie: refresh_token=...
```

Succes:

- revoke refresh token;
- revoke session;
- clear `access_token`;
- clear `refresh_token`.

Si aucun cookie refresh n'est present, la route renvoie quand meme des cookies
expires. Le logout reste idempotent cote client.

### Me

Endpoint:

```http
GET /auth/me
Cookie: access_token=...
```

Pour les clients app/mobile/desktop, la meme route accepte aussi:

```http
Authorization: Bearer <access_token>
```

Succes:

```json
{
  "sub": "...",
  "sid": "...",
  "identityId": "...",
  "authSessionId": "...",
  "username": "noxe",
  "email": "noxe@example.com",
  "emailVerified": false,
  "amr": ["username"]
}
```

Erreurs:

- `401 missingAccessToken`;
- `401 invalidAccessToken`;
- `401 sessionNotFound`;
- `401 identityNotFound`;
- `403 identityNotActive`.

## Transport Web Et App

Le transport par defaut est `cookie`.

Web:

- `register`, `login` et `refresh` renvoient `Set-Cookie`;
- `access_token` et `refresh_token` sont `HttpOnly`;
- le front appelle l'API avec `credentials: include`;
- le JWT n'est pas lisible par JavaScript.

App/mobile/desktop:

- le client demande `body` avec `X-Auth-Token-Transport: body`;
- ou ajoute `"tokenTransport": "body"` dans le JSON;
- `register`, `login` et `refresh` renvoient les tokens dans le body;
- les routes protegees acceptent `Authorization: Bearer <access_token>`;
- le refresh token est envoye a `/auth/refresh` dans le body JSON.

Exemple register app:

```http
POST /auth/register
Content-Type: application/json
X-Auth-Token-Transport: body
```

```json
{
  "username": "noxe",
  "password": "test-password",
  "email": "noxe@example.com"
}
```

Reponse app:

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

Exemple refresh app:

```http
POST /auth/refresh
Content-Type: application/json
```

```json
{
  "refreshToken": "...",
  "tokenTransport": "body"
}
```

Regles de securite app:

- garder l'access token en memoire;
- stocker le refresh token dans le secure storage de l'OS;
- ne pas mettre les tokens dans les logs;
- ne jamais stocker le refresh token dans un fichier texte ou preferences non
  chiffrees;
- la rotation refresh reste obligatoire, donc un ancien refresh token reutilise
  est refuse.

## JWT

Le access token est un JWT HS256 transporte par cookie `access_token` en web ou
par `Authorization: Bearer` en app.

Claims:

| Claim | Role |
| --- | --- |
| `sub` | Id technique de l'identity. |
| `sid` | Id de la session active. |
| `iss` | Emetteur attendu: `identity-service`. |
| `aud` | Audience attendue: `nexus-api`. |
| `typ` | Type de token attendu: `access`. |
| `iat` | Date d'emission en epoch seconds. |
| `exp` | Date d'expiration en epoch seconds. |
| `email_verified` | Etat de verification email. |
| `amr` | Methodes d'authentification, ex: `username`. |

`RequireAuth` valide le JWT puis verifie la session en DB. Le JWT seul ne suffit
pas: une session revoke ou expiree bloque l'acces meme si la signature JWT est
bonne.

## Refresh Token

Le refresh token est stocke dans le cookie `refresh_token` en web, ou dans le
secure storage du client app.

Format:

```text
refreshTokenId:rawSecret
```

En DB, seul le hash du secret est stocke.

Rotation:

1. Le client appelle `/auth/refresh`.
2. Le service verifie l'ancien token.
3. Le service cree un nouveau refresh token.
4. L'ancien token est marque comme rotate.
5. Le client recoit de nouveaux cookies en mode web, ou de nouveaux tokens dans
   le body en mode app.

Un ancien refresh token ne doit pas etre reutilisable.

## Brute Force

`LoginWithUsernameUseCase` utilise `LoginAttemptLimiter`.

Implementation production:

```text
RedisLoginAttemptLimiter
```

Comportement:

- la cle Redis contient `sha256(username)`;
- chaque echec incremente le compteur;
- le compteur expire apres `window`, par defaut 15 minutes;
- apres `maxAttempts`, par defaut 5, le login renvoie `tooManyAttempts`;
- un login reussi supprime le compteur.

La logique Redis utilise un script Lua pour que `INCR` et `PEXPIRE` soient faits
de maniere atomique.

## Secrets et Vault

En Docker dev/prod, les secrets ne sont pas lus depuis le code.

Flux dev:

1. Vault contient les secrets.
2. Vault Agent rend les fichiers dans `/run/vault/secrets`.
3. Postgres lit `/run/vault/secrets/postgres_password`.
4. Redis lit `/run/vault/secrets/redis_password`.
5. L'API copie `/run/vault/secrets/serverpod-passwords.yaml` vers
   `/app/config/passwords.yaml`.
6. Serverpod expose ces secrets via `session.passwords`.

Secrets utilises par l'auth:

- `emailSecretHashPepper`;
- `jwtHmacSha512PrivateKey`;
- `jwtRefreshTokenHashPepper`;
- `authAllowedOrigins`;
- `mailFromAddress`;
- `mailFromName`;
- `mailSupportAddress`;
- `smtpHost`;
- `smtpPort`;
- `smtpUsername`;
- `smtpPassword`;
- `database`;
- `redis`.

Secrets OAuth prepares mais desactives par defaut:

- `googleOAuthEnabled`;
- `googleOAuthClientId`;
- `googleOAuthClientSecret`;
- `githubOAuthEnabled`;
- `githubOAuthClientId`;
- `githubOAuthClientSecret`;
- `appleOAuthEnabled`;
- `appleOAuthClientId`;
- `appleOAuthClientSecret`.

Un provider OAuth n'est active que si son flag vaut `true` et que son client id
et client secret sont presents. Apple reste donc desactive par defaut, mais le
backend verifie maintenant la signature et les claims du `id_token` Apple via
JWKS avant d'accepter un login.

Le client HTTP OAuth applique des timeouts bornes pour eviter qu'un provider
externe bloque durablement les workers d'auth.

`authAllowedOrigins` contient la liste separee par virgules des origins web
autorisees sur les routes auth. Les clients mobile/serveur sans header `Origin`
ne sont pas bloques par cette garde.

Dans GitHub Actions, le job cree uniquement des secrets de test ephemeres dans
`identity_server/secrets/`. Ce n'est pas la procedure dev/prod avec Vault; c'est
un environnement de test CI isole.

## Comment Proteger une Nouvelle Route

Creer une route qui herite de `AuthenticatedJsonRoute`.

Exemple:

```dart
class PrivateExampleRoute extends AuthenticatedJsonRoute {
  @override
  Future<AuthResult> executeAuthenticated(
    Session session,
    Request request,
    AuthDependencies dependencies,
    AuthenticatedRequest authenticated,
  ) async {
    return AuthResult(
      identityId: authenticated.identityId,
      authSessionId: authenticated.authSessionId,
      responseHeaders: const {},
      body: {
        'identityId': authenticated.identityId.toString(),
      },
    );
  }
}
```

Puis l'ajouter dans `register_auth_routes.dart`:

```dart
AuthRouteDefinition(
  path: '/auth/private-example',
  route: PrivateExampleRoute(),
),
```

La route recevra seulement les requetes connectees. Les refus seront geres par
la base:

- `401` pour pas de cookie, token invalide, session invalide;
- `403` pour identity non active.

## Tests

Les tests auth sont dans:

```text
identity_server/test/auth/
```

Couverture principale:

- JWT valide/invalide/expire;
- cookies auth;
- refresh token codec;
- register/login/refresh/logout;
- brute force Redis;
- XSS-like payload stocke comme texte;
- SQL-injection-like username ne bypass pas le login;
- `RequireAuth`;
- `AuthenticatedJsonRoute`;
- `/auth/me`.

Commandes:

```sh
dart analyze --fatal-infos
```

Commande recommandee:

```sh
./docker/script/run_serverpod_tests.sh
```

Ce script demarre le profil Docker `test`, injecte les variables Serverpod
necessaires, puis lance `dart test`. Sans ces services et variables, les tests
qui utilisent `withServerpod` peuvent echouer pendant le chargement du fichier.

Equivalent manuel:

```sh
SERVERPOD_DATABASE_PORT=9190 \
SERVERPOD_REDIS_ENABLED=true \
SERVERPOD_REDIS_PORT=9191 \
SERVERPOD_PASSWORD_database=root_123456789 \
SERVERPOD_PASSWORD_redis="$(cat secrets/redis_test_password)" \
SERVERPOD_PASSWORD_emailSecretHashPepper=test-email-secret-pepper \
SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=test-jwt-secret \
SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=test-refresh-pepper \
dart test
```

La valeur `root_123456789` correspond au secret local indique pour cette machine
de dev. Elle ne doit pas devenir un secret partage dans le code.

## GitHub Actions

Workflow:

```text
.github/workflows/tests.yml
```

Le job fait:

1. checkout;
2. installe Flutter/Dart;
3. cree les secrets de test ephemeres;
4. demarre `postgres_test` et `redis_test`;
5. `flutter pub get`;
6. installe Serverpod CLI;
7. lance `serverpod generate`;
8. verifie format;
9. lance `dart analyze --fatal-infos`;
10. lance `dart test`;
11. stoppe les conteneurs.

## Etat Actuel des Endpoints

| Method | Path | Auth | Role |
| --- | --- | --- | --- |
| POST | `/auth/register` | public | Inscription username/password. |
| POST | `/auth/login` | public | Connexion username/password. |
| POST | `/auth/refresh` | refresh cookie | Rotation refresh + nouveaux cookies. |
| POST | `/auth/logout` | refresh cookie optionnel | Revocation + clear cookies. |
| GET/POST | `/auth/me` | access cookie | Retourne l'identite connectee. |

## Prochaines Evolutions

Priorite logique:

1. brancher le front sur register/login/me/logout;
2. ajouter CSRF pour les routes avec cookies;
3. ajouter providers Google/GitHub/Apple;
4. ajouter audit log login/logout/refresh;
5. ajouter endpoint de revocation de toutes les sessions;
6. ajouter tests HTTP end-to-end en CI.
