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
-- Class AiClaim as table ai_claim
--
CREATE TABLE "ai_claim" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "runId" uuid NOT NULL,
    "statement" text NOT NULL,
    "claimType" text NOT NULL,
    "confidence" text NOT NULL,
    "verificationDecision" text NOT NULL,
    "iteration" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "ai_claim_run_idx" ON "ai_claim" USING btree ("runId");
CREATE INDEX "ai_claim_run_iteration_idx" ON "ai_claim" USING btree ("runId", "iteration");

--
-- Class AiClaimEvidence as table ai_claim_evidence
--
CREATE TABLE "ai_claim_evidence" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "runId" uuid NOT NULL,
    "claimId" uuid NOT NULL,
    "evidenceId" uuid NOT NULL,
    "relation" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "ai_claim_evidence_claim_idx" ON "ai_claim_evidence" USING btree ("claimId");
CREATE INDEX "ai_claim_evidence_evidence_idx" ON "ai_claim_evidence" USING btree ("evidenceId");
CREATE UNIQUE INDEX "ai_claim_evidence_unique_idx" ON "ai_claim_evidence" USING btree ("claimId", "evidenceId");

--
-- Class AiEvidence as table ai_evidence
--
CREATE TABLE "ai_evidence" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "runId" uuid NOT NULL,
    "sourceService" text NOT NULL,
    "resourceType" text NOT NULL,
    "resourceId" text NOT NULL,
    "summary" text,
    "reliability" double precision NOT NULL,
    "freshness" double precision NOT NULL,
    "observedAt" timestamp without time zone,
    "collectedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "ai_evidence_run_idx" ON "ai_evidence" USING btree ("runId");
CREATE INDEX "ai_evidence_resource_idx" ON "ai_evidence" USING btree ("sourceService", "resourceType", "resourceId");

--
-- Class AiRun as table ai_run
--
CREATE TABLE "ai_run" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "requestId" uuid NOT NULL,
    "projectId" uuid NOT NULL,
    "tenantPartyId" uuid NOT NULL,
    "missionId" uuid,
    "capability" text NOT NULL,
    "status" text NOT NULL DEFAULT 'queued'::text,
    "requesterIdentityId" uuid,
    "requesterService" text,
    "failureCode" text,
    "provider" text,
    "model" text,
    "outputText" text,
    "reasoningLevel" text,
    "currentIteration" bigint,
    "maxIterations" bigint,
    "validated" boolean DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "ai_run_request_id_idx" ON "ai_run" USING btree ("requestId");
CREATE INDEX "ai_run_project_idx" ON "ai_run" USING btree ("projectId");
CREATE INDEX "ai_run_tenant_idx" ON "ai_run" USING btree ("tenantPartyId");
CREATE INDEX "ai_run_created_at_idx" ON "ai_run" USING btree ("createdAt");

--
-- Class AiRunJob as table ai_run_job
--
CREATE TABLE "ai_run_job" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "runId" uuid NOT NULL,
    "inputJson" text NOT NULL,
    "bearerToken" text,
    "idempotencyKey" text,
    "requestFingerprint" text,
    "requesterScope" text NOT NULL,
    "tenantPartyId" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'queued'::text,
    "attemptCount" bigint NOT NULL DEFAULT 0,
    "claimedAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "lastErrorCode" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "ai_run_job_run_idx" ON "ai_run_job" USING btree ("runId");
CREATE UNIQUE INDEX "ai_run_job_idempotency_idx" ON "ai_run_job" USING btree ("tenantPartyId", "requesterScope", "idempotencyKey");

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
-- Foreign relations for "ai_claim" table
--
ALTER TABLE ONLY "ai_claim"
    ADD CONSTRAINT "ai_claim_fk_0"
    FOREIGN KEY("runId")
    REFERENCES "ai_run"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "ai_claim_evidence" table
--
ALTER TABLE ONLY "ai_claim_evidence"
    ADD CONSTRAINT "ai_claim_evidence_fk_0"
    FOREIGN KEY("runId")
    REFERENCES "ai_run"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "ai_claim_evidence"
    ADD CONSTRAINT "ai_claim_evidence_fk_1"
    FOREIGN KEY("claimId")
    REFERENCES "ai_claim"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "ai_claim_evidence"
    ADD CONSTRAINT "ai_claim_evidence_fk_2"
    FOREIGN KEY("evidenceId")
    REFERENCES "ai_evidence"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "ai_evidence" table
--
ALTER TABLE ONLY "ai_evidence"
    ADD CONSTRAINT "ai_evidence_fk_0"
    FOREIGN KEY("runId")
    REFERENCES "ai_run"("id")
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

-- `runId` on the association is intentionally redundant: it makes tenant and
-- project scoping cheap when explanations are read through an AI run. Enforce
-- that redundancy on fresh databases as well as upgraded databases.
CREATE OR REPLACE FUNCTION ai_claim_evidence_require_same_run()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM "ai_claim"
     WHERE "id" = NEW."claimId"
       AND "runId" = NEW."runId"
  ) THEN
    RAISE EXCEPTION 'claim does not belong to AI run'
      USING ERRCODE = '23514';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM "ai_evidence"
     WHERE "id" = NEW."evidenceId"
       AND "runId" = NEW."runId"
  ) THEN
    RAISE EXCEPTION 'evidence does not belong to AI run'
      USING ERRCODE = '23514';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER "ai_claim_evidence_same_run_trg"
BEFORE INSERT OR UPDATE OF "runId", "claimId", "evidenceId"
ON "ai_claim_evidence"
FOR EACH ROW
EXECUTE FUNCTION ai_claim_evidence_require_same_run();


--
-- MIGRATION VERSION FOR ai_gateway
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ai_gateway', '20260920141244671-ai-run-idempotency-fingerprint', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260920141244671-ai-run-idempotency-fingerprint', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
