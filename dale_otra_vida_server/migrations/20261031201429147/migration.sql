BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_feedback" (
    "id" bigserial PRIMARY KEY,
    "profileId" bigint NOT NULL,
    "rating" bigint,
    "message" text NOT NULL,
    "screen" text,
    "platform" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "app_feedback_created_idx" ON "app_feedback" USING btree ("createdAt");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_feedback"
    ADD CONSTRAINT "app_feedback_fk_0"
    FOREIGN KEY("profileId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261031201429147', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261031201429147', "timestamp" = now();

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
