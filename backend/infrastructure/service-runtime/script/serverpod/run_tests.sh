#!/usr/bin/env bash
set -Eeuo pipefail

if [[ -z "${SERVER_ROOT:-}" ]]; then
  echo "SERVER_ROOT is required." >&2
  exit 1
fi

POSTGRES_TEST_PORT="${POSTGRES_TEST_PORT:-9290}"
REDIS_TEST_PORT="${REDIS_TEST_PORT:-9291}"
TEST_COMPOSE_PROJECT="${NEXUS_TEST_COMPOSE_PROJECT:-$(basename "$SERVER_ROOT")_test}"

cd "$SERVER_ROOT"

cleanup_test_stack() {
  POSTGRES_TEST_PORT="$POSTGRES_TEST_PORT" \
  REDIS_TEST_PORT="$REDIS_TEST_PORT" \
  docker compose -p "$TEST_COMPOSE_PROJECT" --profile test \
    down --volumes --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup_test_stack EXIT INT TERM

if [[ ! -s secrets/postgres_test_password ]]; then
  echo "Missing secrets/postgres_test_password" >&2
  exit 1
fi

if [[ ! -s secrets/redis_test_password ]]; then
  echo "Missing secrets/redis_test_password" >&2
  exit 1
fi

compose_up=(--profile test up --wait)
if [[ "${NEXUS_TEST_NO_BUILD:-false}" == "true" ]]; then
  # Useful for deterministic/offline reruns once the disposable test images
  # have already been built. Compose must never contact a registry here.
  compose_up+=(--no-build)
else
  compose_up+=(--build)
fi
compose_up+=(postgres_test redis_test)

POSTGRES_TEST_PORT="$POSTGRES_TEST_PORT" \
REDIS_TEST_PORT="$REDIS_TEST_PORT" \
docker compose -p "$TEST_COMPOSE_PROJECT" "${compose_up[@]}"

export SERVERPOD_DATABASE_PORT="$POSTGRES_TEST_PORT"
export SERVERPOD_REDIS_ENABLED=true
export SERVERPOD_REDIS_PORT="$REDIS_TEST_PORT"
export SERVERPOD_PASSWORD_database
export SERVERPOD_PASSWORD_redis

if [[ "${SERVERPOD_TEST_AUTH_PASSWORDS:-false}" == "true" ]]; then
  export SERVERPOD_PASSWORD_emailSecretHashPepper="${SERVERPOD_PASSWORD_emailSecretHashPepper:-test-email-secret-pepper}"
  export SERVERPOD_PASSWORD_jwtAccessTokenPrivateKeyPem="${SERVERPOD_PASSWORD_jwtAccessTokenPrivateKeyPem:-$'-----BEGIN PRIVATE KEY-----\\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC7VJTUt9Us8cKj\\nMzEfYyjiWA4R4/M2bS1GB4t7NXp98C3SC6dVMvDuictGeurT8jNbvJZHtCSuYEvu\\nNMoSfm76oqFvAp8Gy0iz5sxjZmSnXyCdPEovGhLa0VzMaQ8s+CLOyS56YyCFGeJZ\\nqgtzJ6GR3eqoYSW9b9UMvkBpZODSctWSNGj3P7jRFDO5VoTwCQAWbFnOjDfH5Ulg\\np2PKSQnSJP3AJLQNFNe7br1XbrhV//eO+t51mIpGSDCUv3E0DDFcWDTH9cXDTTlR\\nZVEiR2BwpZOOkE/Z0/BVnhZYL71oZV34bKfWjQIt6V/isSMahdsAASACp4ZTGtwi\\nVuNd9tybAgMBAAECggEBAKTmjaS6tkK8BlPXClTQ2vpz/N6uxDeS35mXpqasqskV\\nlaAidgg/sWqpjXDbXr93otIMLlWsM+X0CqMDgSXKejLS2jx4GDjI1ZTXg++0AMJ8\\nsJ74pWzVDOfmCEQ/7wXs3+cbnXhKriO8Z036q92Qc1+N87SI38nkGa0ABH9CN83H\\nmQqt4fB7UdHzuIRe/me2PGhIq5ZBzj6h3BpoPGzEP+x3l9YmK8t/1cN0pqI+dQwY\\ndgfGjackLu/2qH80MCF7IyQaseZUOJyKrCLtSD/Iixv/hzDEUPfOCjFDgTpzf3cw\\nta8+oE4wHCo1iI1/4TlPkwmXx4qSXtmw4aQPz7IDQvECgYEA8KNThCO2gsC2I9PQ\\nDM/8Cw0O983WCDY+oi+7JPiNAJwv5DYBqEZB1QYdj06YD16XlC/HAZMsMku1na2T\\nN0driwenQQWzoev3g2S7gRDoS/FCJSI3jJ+kjgtaA7Qmzlgk1TxODN+G1H91HW7t\\n0l7VnL27IWyYo2qRRK3jzxqUiPUCgYEAx0oQs2reBQGMVZnApD1jeq7n4MvNLcPv\\nt8b/eU9iUv6Y4Mj0Suo/AU8lYZXm8ubbqAlwz2VSVunD2tOplHyMUrtCtObAfVDU\\nAhCndKaA9gApgfb3xw1IKbuQ1u4IF1FJl3VtumfQn//LiH1B3rXhcdyo3/vIttEk\\n48RakUKClU8CgYEAzV7W3COOlDDcQd935DdtKBFRAPRPAlspQUnzMi5eSHMD/ISL\\nDY5IiQHbIH83D4bvXq0X7qQoSBSNP7Dvv3HYuqMhf0DaegrlBuJllFVVq9qPVRnK\\nxt1Il2HgxOBvbhOT+9in1BzA+YJ99UzC85O0Qz06A+CmtHEy4aZ2kj5hHjECgYEA\\nmNS4+A8Fkss8Js1RieK2LniBxMgmYml3pfVLKGnzmng7H2+cwPLhPIzIuwytXywh\\n2bzbsYEfYx3EoEVgMEpPhoarQnYPukrJO4gwE2o5Te6T5mJSZGlQJQj9q4ZB2Dfz\\net6INsK0oG8XVGXSpQvQh3RUYekCZQkBBFcpqWpbIEsCgYAnM3DQf3FJoSnXaMhr\\nVBIovic5l0xFkEHskAjFTevO86Fsz1C2aSeRKSqGFoOQ0tmJzBEs1R6KqnHInicD\\nTQrKhArgLXX4v3CddjfTRJkFWDbE/CkvKZNOrcf1nhaGCPspRJj2KUkj1Fhl9Cnc\\ndn/RsYEONbwQSjIfMPkvxF+8HQ==\\n-----END PRIVATE KEY-----'}"
  export SERVERPOD_PASSWORD_jwtAccessTokenPublicKeyPem="${SERVERPOD_PASSWORD_jwtAccessTokenPublicKeyPem:-$'-----BEGIN PUBLIC KEY-----\\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo\\n4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u\\n+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyeh\\nkd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ\\n0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdg\\ncKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbc\\nmwIDAQAB\\n-----END PUBLIC KEY-----'}"
  export SERVERPOD_PASSWORD_identityAccessTokenPublicKeyPem="${SERVERPOD_PASSWORD_identityAccessTokenPublicKeyPem:-${SERVERPOD_PASSWORD_jwtAccessTokenPublicKeyPem}}"
  export SERVERPOD_PASSWORD_jwtAccessTokenKeyId="${SERVERPOD_PASSWORD_jwtAccessTokenKeyId:-identity-access-token-current}"
  export SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey="${SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey:-test-jwt-secret}"
  export SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper="${SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper:-test-refresh-pepper}"
fi

SERVERPOD_PASSWORD_database="$(
  cat secrets/postgres_test_password
)"
SERVERPOD_PASSWORD_redis="$(
  cat secrets/redis_test_password
)"

dart test "$@"
