BEGIN;

--
-- ACTION ALTER TABLE
--
CREATE INDEX "app_notification_ref_idx" ON "app_notification" USING btree ("userId", "kind", "refId");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "chat_message_sender_idx" ON "chat_message" USING btree ("senderId", "createdAt");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "listing_request_requester_idx" ON "listing_request" USING btree ("requesterId", "status");

--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261107230820383', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261107230820383', "timestamp" = now();

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
