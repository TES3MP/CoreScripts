local postgresClient = require("drive.postgres.client")

-- generated from https://dbdiagram.io/d/5eb7f43539d18f5553fef7a2
local sql =
[[
CREATE TYPE "record_type" AS ENUM (
    'permanent',
    'generated'
);

CREATE TABLE "players" (
    "id" serial PRIMARY KEY,
    "name" varchar UNIQUE,
    "data" jsonb
);

CREATE TABLE "player_links" (
    "id" bigserial PRIMARY KEY,
    "player_name" varchar,
    "record_refId" varchar
);

CREATE TABLE "cells" (
    "id" serial PRIMARY KEY,
    "description" varchar UNIQUE,
    "data" jsonb
);

CREATE TABLE "cell_links" (
    "id" bigserial PRIMARY KEY,
    "cell_description" varchar,
    "record_refId" varchar
);

CREATE TABLE "record_stores" (
    "id" serial PRIMARY KEY,
    "type" varchar UNIQUE,
    "data" jsonb
);

CREATE TABLE "records" (
    "id" bigserial PRIMARY KEY,
    "refId" varchar UNIQUE,
    "type" record_type,
    "store_type" varchar,
    "data" jsonb
);

CREATE TABLE "data_storage" (
    "id" bigserial PRIMARY KEY,
    "key" varchar UNIQUE,
    "data" jsonb
);

ALTER TABLE "player_links" ADD FOREIGN KEY ("player_name") REFERENCES "players" ("name");

ALTER TABLE "player_links" ADD FOREIGN KEY ("record_refId") REFERENCES "records" ("refId");

ALTER TABLE "cell_links" ADD FOREIGN KEY ("cell_description") REFERENCES "cells" ("description");

ALTER TABLE "cell_links" ADD FOREIGN KEY ("record_refId") REFERENCES "records" ("refId");

ALTER TABLE "records" ADD FOREIGN KEY ("store_type") REFERENCES "record_stores" ("type");
]]

local result = postgresClient.QueryAsync(sql)
if result.error then
    return 1
end
return 0
