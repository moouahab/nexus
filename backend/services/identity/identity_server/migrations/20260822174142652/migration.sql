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
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_secret_challenge" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_rate_limited_request_attempt" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_passkey_challenge" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_passkey_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_microsoft_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_google_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_github_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_firebase_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_facebook_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_email_account_request" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_email_account_password_reset_request" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_email_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_apple_account" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "serverpod_auth_idp_anonymous_account" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "password_reset_code" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "identityId" uuid NOT NULL,
    "email" text NOT NULL,
    "codeHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone NOT NULL,
    "consumedAt" timestamp without time zone,
    "failedAttempts" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX "password_reset_code_identity_idx" ON "password_reset_code" USING btree ("identityId");
CREATE INDEX "password_reset_code_email_idx" ON "password_reset_code" USING btree ("email");
CREATE INDEX "password_reset_code_expires_at_idx" ON "password_reset_code" USING btree ("expiresAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "password_reset_code"
    ADD CONSTRAINT "password_reset_code_fk_0"
    FOREIGN KEY("identityId")
    REFERENCES "identity"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR identity
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('identity', '20260822174142652', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260822174142652', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


--
-- MIGRATION VERSION FOR 'serverpod_auth_idp'
--
DELETE FROM "serverpod_migrations"WHERE "module" IN ('serverpod_auth_idp');

COMMIT;
