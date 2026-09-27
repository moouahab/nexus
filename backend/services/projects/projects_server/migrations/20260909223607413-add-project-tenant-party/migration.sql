BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "project" ADD COLUMN "tenantPartyId" uuid;
CREATE INDEX "project_tenant_idx" ON "project" USING btree ("tenantPartyId");
CREATE INDEX "project_tenant_status_idx" ON "project" USING btree ("tenantPartyId", "status");

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
