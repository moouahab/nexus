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
CREATE TABLE "project" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "slug" text NOT NULL,
    "name" text NOT NULL,
    "summary" text,
    "status" text NOT NULL DEFAULT 'active'::text,
    "visibility" text NOT NULL DEFAULT 'private'::text,
    "ownerIdentityId" uuid,
    "workspacePath" text,
    "archivePath" text,
    "tags" json,
    "metadata" json,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone,
    "archivedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "project_slug_idx" ON "project" USING btree ("slug");
CREATE INDEX "project_status_idx" ON "project" USING btree ("status");
CREATE INDEX "project_owner_idx" ON "project" USING btree ("ownerIdentityId");
CREATE INDEX "project_created_at_idx" ON "project" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "project_archive_entry" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "projectId" uuid NOT NULL,
    "archivePath" text,
    "reason" text,
    "archivedByIdentityId" uuid,
    "archivedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "restoredAt" timestamp without time zone,
    "restoredByIdentityId" uuid,
    "metadata" json
);

-- Indexes
CREATE INDEX "project_archive_entry_project_idx" ON "project_archive_entry" USING btree ("projectId");
CREATE INDEX "project_archive_entry_archived_at_idx" ON "project_archive_entry" USING btree ("archivedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "project_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "projectId" uuid NOT NULL,
    "kind" text NOT NULL,
    "message" text,
    "actorIdentityId" uuid,
    "resourceKind" text,
    "resourceService" text,
    "resourceExternalId" text,
    "payload" json,
    "occurredAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "project_event_project_idx" ON "project_event" USING btree ("projectId");
CREATE INDEX "project_event_kind_idx" ON "project_event" USING btree ("kind");
CREATE INDEX "project_event_occurred_at_idx" ON "project_event" USING btree ("occurredAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "project_link" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "projectId" uuid NOT NULL,
    "kind" text NOT NULL,
    "service" text NOT NULL,
    "externalId" text NOT NULL,
    "label" text,
    "uri" text,
    "status" text NOT NULL DEFAULT 'active'::text,
    "metadata" json,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "project_link_project_idx" ON "project_link" USING btree ("projectId");
CREATE INDEX "project_link_kind_idx" ON "project_link" USING btree ("kind");
CREATE INDEX "project_link_external_idx" ON "project_link" USING btree ("service", "externalId");
CREATE UNIQUE INDEX "project_link_unique_idx" ON "project_link" USING btree ("projectId", "kind", "service", "externalId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "project_archive_entry"
    ADD CONSTRAINT "project_archive_entry_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "project_event"
    ADD CONSTRAINT "project_event_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "project_link"
    ADD CONSTRAINT "project_link_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR projects
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('projects', '20260905173542082', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260905173542082', "timestamp" = now();

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
