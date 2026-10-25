BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "app_notification" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "kind" text NOT NULL,
    "title" text NOT NULL,
    "body" text NOT NULL,
    "refId" bigint,
    "readAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "app_notification_user_idx" ON "app_notification" USING btree ("userId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "chat_message" (
    "id" bigserial PRIMARY KEY,
    "conversationId" bigint NOT NULL,
    "senderId" bigint,
    "kind" text NOT NULL DEFAULT 'text'::text,
    "text" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "readAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "chat_message_conversation_idx" ON "chat_message" USING btree ("conversationId", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "conversation" (
    "id" bigserial PRIMARY KEY,
    "listingId" bigint NOT NULL,
    "ownerId" bigint NOT NULL,
    "requesterId" bigint NOT NULL,
    "lastMessageAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastMessagePreview" text
);

-- Indexes
CREATE UNIQUE INDEX "conversation_unique_idx" ON "conversation" USING btree ("listingId", "requesterId");
CREATE INDEX "conversation_owner_idx" ON "conversation" USING btree ("ownerId");
CREATE INDEX "conversation_requester_idx" ON "conversation" USING btree ("requesterId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "listing" (
    "id" bigserial PRIMARY KEY,
    "ownerId" bigint NOT NULL,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "type" text NOT NULL,
    "category" text NOT NULL,
    "condition" text NOT NULL,
    "status" text NOT NULL DEFAULT 'available'::text,
    "photoUrls" json NOT NULL,
    "expiresAt" timestamp without time zone,
    "price" bigint,
    "returnDate" timestamp without time zone,
    "wantedInExchange" text,
    "neighborhood" text NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "safeMeetingPoint" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "listing_status_created_idx" ON "listing" USING btree ("status", "createdAt");
CREATE INDEX "listing_owner_idx" ON "listing" USING btree ("ownerId");
CREATE INDEX "listing_category_idx" ON "listing" USING btree ("category");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "listing_request" (
    "id" bigserial PRIMARY KEY,
    "listingId" bigint NOT NULL,
    "requesterId" bigint NOT NULL,
    "message" text,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "listing_request_unique_idx" ON "listing_request" USING btree ("listingId", "requesterId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "member_profile" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "displayName" text NOT NULL,
    "neighborhood" text,
    "latitude" double precision,
    "longitude" double precision,
    "avatarUrl" text,
    "isVerified" boolean NOT NULL DEFAULT false,
    "ratingAvg" double precision NOT NULL DEFAULT 0,
    "reviewCount" bigint NOT NULL DEFAULT 0,
    "deliveryCount" bigint NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "member_profile_auth_user_idx" ON "member_profile" USING btree ("authUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "report" (
    "id" bigserial PRIMARY KEY,
    "reporterId" bigint NOT NULL,
    "reportedUserId" bigint,
    "listingId" bigint,
    "reason" text NOT NULL,
    "details" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "review" (
    "id" bigserial PRIMARY KEY,
    "listingId" bigint NOT NULL,
    "reviewerId" bigint NOT NULL,
    "revieweeId" bigint NOT NULL,
    "rating" bigint NOT NULL,
    "comment" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "review_unique_idx" ON "review" USING btree ("listingId", "reviewerId");
CREATE INDEX "review_reviewee_idx" ON "review" USING btree ("revieweeId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "app_notification"
    ADD CONSTRAINT "app_notification_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "chat_message"
    ADD CONSTRAINT "chat_message_fk_0"
    FOREIGN KEY("conversationId")
    REFERENCES "conversation"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "chat_message"
    ADD CONSTRAINT "chat_message_fk_1"
    FOREIGN KEY("senderId")
    REFERENCES "member_profile"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "conversation"
    ADD CONSTRAINT "conversation_fk_0"
    FOREIGN KEY("listingId")
    REFERENCES "listing"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "conversation"
    ADD CONSTRAINT "conversation_fk_1"
    FOREIGN KEY("ownerId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "conversation"
    ADD CONSTRAINT "conversation_fk_2"
    FOREIGN KEY("requesterId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "listing"
    ADD CONSTRAINT "listing_fk_0"
    FOREIGN KEY("ownerId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "listing_request"
    ADD CONSTRAINT "listing_request_fk_0"
    FOREIGN KEY("listingId")
    REFERENCES "listing"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "listing_request"
    ADD CONSTRAINT "listing_request_fk_1"
    FOREIGN KEY("requesterId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "member_profile"
    ADD CONSTRAINT "member_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "report"
    ADD CONSTRAINT "report_fk_0"
    FOREIGN KEY("reporterId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "report"
    ADD CONSTRAINT "report_fk_1"
    FOREIGN KEY("reportedUserId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "report"
    ADD CONSTRAINT "report_fk_2"
    FOREIGN KEY("listingId")
    REFERENCES "listing"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "review"
    ADD CONSTRAINT "review_fk_0"
    FOREIGN KEY("listingId")
    REFERENCES "listing"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "review"
    ADD CONSTRAINT "review_fk_1"
    FOREIGN KEY("reviewerId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "review"
    ADD CONSTRAINT "review_fk_2"
    FOREIGN KEY("revieweeId")
    REFERENCES "member_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dale_otra_vida
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dale_otra_vida', '20261025060205719', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261025060205719', "timestamp" = now();

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
