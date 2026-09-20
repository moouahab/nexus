BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "ai_run_job" ADD COLUMN "requestFingerprint" text;

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
