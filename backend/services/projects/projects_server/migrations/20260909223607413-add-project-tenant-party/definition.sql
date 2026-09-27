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
-- Class Project as table project
--
CREATE TABLE "project" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "slug" text NOT NULL,
    "name" text NOT NULL,
    "summary" text,
    "status" text NOT NULL DEFAULT 'active'::text,
    "visibility" text NOT NULL DEFAULT 'private'::text,
    "tenantPartyId" uuid,
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
CREATE INDEX "project_tenant_idx" ON "project" USING btree ("tenantPartyId");
CREATE INDEX "project_owner_idx" ON "project" USING btree ("ownerIdentityId");
CREATE INDEX "project_tenant_status_idx" ON "project" USING btree ("tenantPartyId", "status");
CREATE INDEX "project_created_at_idx" ON "project" USING btree ("createdAt");

--
-- Class ProjectArchiveEntry as table project_archive_entry
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
-- Class ProjectEvent as table project_event
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
-- Class ProjectLink as table project_link
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
-- Class ProjectParticipant as table project_participant
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
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Foreign relations for "project_archive_entry" table
--
ALTER TABLE ONLY "project_archive_entry"
    ADD CONSTRAINT "project_archive_entry_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "project_event" table
--
ALTER TABLE ONLY "project_event"
    ADD CONSTRAINT "project_event_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "project_link" table
--
ALTER TABLE ONLY "project_link"
    ADD CONSTRAINT "project_link_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "project_participant" table
--
ALTER TABLE ONLY "project_participant"
    ADD CONSTRAINT "project_participant_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR projects
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('projects', '20260909223607413-add-project-tenant-party', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260909223607413-add-project-tenant-party', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
