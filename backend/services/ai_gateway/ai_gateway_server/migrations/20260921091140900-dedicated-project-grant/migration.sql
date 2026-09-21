BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "ai_run_job" ADD COLUMN "projectAuthorizationGrant" text;

--
-- MIGRATION VERSION FOR ai_gateway
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('ai_gateway', '20260921091140900-dedicated-project-grant', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260921091140900-dedicated-project-grant', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
