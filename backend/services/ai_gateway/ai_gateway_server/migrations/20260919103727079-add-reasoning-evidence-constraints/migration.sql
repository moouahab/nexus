BEGIN;

--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION ALTER TABLE
--
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ai_claim"
    ADD CONSTRAINT "ai_claim_fk_0"
    FOREIGN KEY("runId")
    REFERENCES "ai_run"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "ai_evidence"
    ADD CONSTRAINT "ai_evidence_fk_0"
    FOREIGN KEY("runId")
    REFERENCES "ai_run"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

-- `runId` on the association is intentionally redundant: it makes tenant and
-- project scoping cheap when explanations are read through an AI run. Enforce
-- that redundancy at the database boundary so a claim or evidence row from a
-- different run can never be attached accidentally.
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
    VALUES ('ai_gateway', '20260919103727079-add-reasoning-evidence-constraints', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260919103727079-add-reasoning-evidence-constraints', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();


COMMIT;
