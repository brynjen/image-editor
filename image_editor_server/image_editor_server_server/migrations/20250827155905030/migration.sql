BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "processing_jobs" (
    "id" bigserial PRIMARY KEY,
    "imageId" bigint NOT NULL,
    "status" text NOT NULL DEFAULT 'pending'::text,
    "processorType" text NOT NULL,
    "instructions" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "errorMessage" text,
    "processingTimeMs" bigint,
    "resultImageId" bigint,
    "progress" double precision NOT NULL DEFAULT 0.0
);


--
-- MIGRATION VERSION FOR image_editor_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('image_editor_server', '20250827155905030', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250827155905030', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
