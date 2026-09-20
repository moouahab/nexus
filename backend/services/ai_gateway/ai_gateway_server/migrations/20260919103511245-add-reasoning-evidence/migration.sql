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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION ALTER TABLE
--
ALTER TABLE "ai_run" ADD COLUMN "reasoningLevel" text;
ALTER TABLE "ai_run" ADD COLUMN "currentIteration" bigint;
ALTER TABLE "ai_run" ADD COLUMN "maxIterations" bigint;
ALTER TABLE "ai_run" ADD COLUMN "validated" boolean DEFAULT false;

--
-- MIGRATION VERSION FOR ai_gateway
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ai_gateway', '20260919103511245-add-reasoning-evidence', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260919103511245-add-reasoning-evidence', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
