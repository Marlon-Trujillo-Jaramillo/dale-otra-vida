BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "push_token" (
    "id" bigserial PRIMARY KEY,
    "profileId" bigint NOT NULL,
    "token" text NOT NULL,
    "platform" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "push_token_token_idx" ON "push_token" USING btree ("token");
CREATE INDEX "push_token_profile_idx" ON "push_token" USING btree ("profileId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "push_token"
    ADD CONSTRAINT "push_token_fk_0"
    FOREIGN KEY("profileId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261106033514154', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261106033514154', "timestamp" = now();

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
