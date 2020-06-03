local postgresClient = require("postgres.client")

local sql =
[[CREATE TABLE "migrations" (
  "id" serial,
  "processed_at" timestamp
);]]

local result = postgresClient.QueryAwait(sql)
if result.error then
  return 1
end
return 0