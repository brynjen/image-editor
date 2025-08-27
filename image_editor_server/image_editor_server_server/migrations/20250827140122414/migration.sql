BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "image_data" (
    "id" bigserial PRIMARY KEY,
    "filename" text NOT NULL,
    "originalName" text NOT NULL,
    "mimeType" text NOT NULL,
    "size" bigint NOT NULL,
    "uploadedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processorType" text,
    "instructions" text,
    "processedAt" timestamp without time zone,
    "processedFilename" text
);


--
-- MIGRATION VERSION FOR image_editor_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('image_editor_server', '20250827140122414', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20250827140122414', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
