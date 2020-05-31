local postgresClient = require("postgres.client")

local sql = 
[[CREATE TYPE "record_type" AS ENUM (
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
  "player" serial,
  "record" bigserial
);

CREATE TABLE "cells" (
  "id" serial PRIMARY KEY,
  "description" varchar UNIQUE,
  "data" jsonb
);

CREATE TABLE "cell_links" (
  "id" bigserial PRIMARY KEY,
  "cell" serial,
  "record" bigserial
);

CREATE TABLE "record_stores" (
  "id" serial PRIMARY KEY,
  "type" varchar UNIQUE
);

CREATE TABLE "records" (
  "id" bigserial PRIMARY KEY,
  "refId" varchar UNIQUE,
  "record_store_id" serial,
  "type" record_type,
  "data" jsonb
);

CREATE TABLE "data_storage" (
  "id" bigserial PRIMARY KEY,
  "key" varchar UNIQUE,
  "data" jsonb
);

ALTER TABLE "player_links" ADD FOREIGN KEY ("player") REFERENCES "players" ("id");

ALTER TABLE "player_links" ADD FOREIGN KEY ("record") REFERENCES "records" ("id");

ALTER TABLE "cell_links" ADD FOREIGN KEY ("cell") REFERENCES "cells" ("id");

ALTER TABLE "cell_links" ADD FOREIGN KEY ("record") REFERENCES "records" ("id");

ALTER TABLE "records" ADD FOREIGN KEY ("record_store_id") REFERENCES "record_stores" ("id");]]

local result = postgresClient.QueryAwait(sql)
if result.error then
  return 1
end
return 0