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
CREATE TABLE "ai_run_job" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "runId" uuid NOT NULL,
    "inputJson" text NOT NULL,
    "bearerToken" text,
    "idempotencyKey" text,
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
-- MIGRATION VERSION FOR ai_gateway
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ai_gateway', '20260919195133567-durable-ai-run-queue', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260919195133567-durable-ai-run-queue', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
