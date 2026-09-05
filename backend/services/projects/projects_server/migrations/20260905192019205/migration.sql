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
CREATE TABLE "project_participant" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "projectId" uuid NOT NULL,
    "role" text NOT NULL,
    "status" text NOT NULL DEFAULT 'active'::text,
    "identityId" uuid,
    "externalId" text,
    "displayName" text,
    "organizationName" text,
    "email" text,
    "phone" text,
    "notes" text,
    "isPrimary" boolean NOT NULL DEFAULT false,
    "metadata" json,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "project_participant_project_idx" ON "project_participant" USING btree ("projectId");
CREATE INDEX "project_participant_role_idx" ON "project_participant" USING btree ("role");
CREATE INDEX "project_participant_status_idx" ON "project_participant" USING btree ("status");
CREATE INDEX "project_participant_identity_idx" ON "project_participant" USING btree ("identityId");
CREATE INDEX "project_participant_external_idx" ON "project_participant" USING btree ("externalId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "project_participant"
    ADD CONSTRAINT "project_participant_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR projects
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('projects', '20260905192019205', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260905192019205', "timestamp" = now();

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
