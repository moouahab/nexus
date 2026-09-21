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
CREATE TABLE "consumed_project_authorization_grant" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "jwtIdHash" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "consumedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "consumed_project_authorization_grant_jti_idx" ON "consumed_project_authorization_grant" USING btree ("jwtIdHash");
CREATE INDEX "consumed_project_authorization_grant_expiry_idx" ON "consumed_project_authorization_grant" USING btree ("expiresAt");


--
-- MIGRATION VERSION FOR identity
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('identity', '20260921091003569-consumed-project-grant', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260921091003569-consumed-project-grant', "timestamp" = now();

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


COMMIT;
