BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "ai_run" ADD COLUMN "provider" text;
ALTER TABLE "ai_run" ADD COLUMN "model" text;
ALTER TABLE "ai_run" ADD COLUMN "outputText" text;

--
-- MIGRATION VERSION FOR ai_gateway
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ai_gateway', '20260919072300736-add-ollama-result', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260919072300736-add-ollama-result', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
