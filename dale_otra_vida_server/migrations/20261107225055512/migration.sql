BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "listing" ADD COLUMN "depositAmount" bigint;
ALTER TABLE "listing" ADD COLUMN "lateFeePerDay" bigint;
ALTER TABLE "listing" ADD COLUMN "loanConditions" text;
ALTER TABLE "listing" ADD COLUMN "loanOutcome" text;
ALTER TABLE "listing" ADD COLUMN "loanClosedAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "listing_request" ADD COLUMN "acceptedTermsAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261107225055512', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261107225055512', "timestamp" = now();

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
