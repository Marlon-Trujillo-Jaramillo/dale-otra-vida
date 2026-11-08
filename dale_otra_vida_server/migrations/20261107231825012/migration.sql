BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "identity_verification" (
    "id" bigserial PRIMARY KEY,
    "profileId" bigint NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "documentNumber" text NOT NULL,
    "frontPath" text,
    "selfiePath" text,
    "consentAt" timestamp without time zone NOT NULL,
    "submittedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedAt" timestamp without time zone,
    "reviewedBy" bigint,
    "rejectionReason" text
);

-- Indexes
CREATE UNIQUE INDEX "identity_verification_profile_idx" ON "identity_verification" USING btree ("profileId");
CREATE INDEX "identity_verification_status_idx" ON "identity_verification" USING btree ("status", "submittedAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "identity_verification"
    ADD CONSTRAINT "identity_verification_fk_0"
    FOREIGN KEY("profileId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261107231825012', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261107231825012', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
