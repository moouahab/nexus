BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "auth_refresh_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authSessionId" uuid NOT NULL,
    "tokenHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL,
    "revokedAt" timestamp without time zone,
    "rotatedAt" timestamp without time zone,
    "replacedByTokenId" uuid
);

-- Indexes
CREATE INDEX "auth_refresh_token_session_idx" ON "auth_refresh_token" USING btree ("authSessionId");
CREATE INDEX "auth_refresh_token_expires_at_idx" ON "auth_refresh_token" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "auth_session" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "identityId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL,
    "lastUsedAt" timestamp without time zone,
    "revokedAt" timestamp without time zone,
    "authMethod" text NOT NULL
);

-- Indexes
CREATE INDEX "auth_session_identity_idx" ON "auth_session" USING btree ("identityId");
CREATE INDEX "auth_session_expires_at_idx" ON "auth_session" USING btree ("expiresAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "identity" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "email" text,
    "username" text,
    "emailVerified" boolean NOT NULL DEFAULT false,
    "status" text NOT NULL DEFAULT 'active'::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "identity_email_idx" ON "identity" USING btree ("email");
CREATE UNIQUE INDEX "identity_username_idx" ON "identity" USING btree ("username");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "identity_provider" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "identityId" uuid NOT NULL,
    "provider" text NOT NULL,
    "providerUserId" text NOT NULL,
    "email" text,
    "emailVerified" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "identity_provider_user_idx" ON "identity_provider" USING btree ("identityId");
CREATE UNIQUE INDEX "identity_provider_provider_user_idx" ON "identity_provider" USING btree ("provider", "providerUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "password_credential" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "identityId" uuid NOT NULL,
    "username" text NOT NULL,
    "passwordHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "password_credential_username_idx" ON "password_credential" USING btree ("username");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "auth_refresh_token"
    ADD CONSTRAINT "auth_refresh_token_fk_0"
    FOREIGN KEY("authSessionId")
    REFERENCES "auth_session"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "auth_session"
    ADD CONSTRAINT "auth_session_fk_0"
    FOREIGN KEY("identityId")
    REFERENCES "identity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "identity_provider"
    ADD CONSTRAINT "identity_provider_fk_0"
    FOREIGN KEY("identityId")
    REFERENCES "identity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "password_credential"
    ADD CONSTRAINT "password_credential_fk_0"
    FOREIGN KEY("identityId")
    REFERENCES "identity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR identity
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('identity', '20260725134249946', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260725134249946', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
