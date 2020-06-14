return function(postgresDrive)
local sql =
[[
CREATE FUNCTION update_timestamp() RETURNS trigger AS $update_timestamp$
BEGIN
    NEW.updated = timezone('utc', now());
    return NEW;
END;
$update_timestamp$ LANGUAGE plpgsql;

CREATE TABLE "player" (
    "name" varchar PRIMARY KEY,
    "data" jsonb,
    "updated" timestamp DEFAULT timezone('utc', now())
);

CREATE TRIGGER player_timestamp
BEFORE UPDATE ON player
FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

CREATE TABLE "cell" (
    "description" varchar PRIMARY KEY,
    "data" jsonb,
    "updated" timestamp DEFAULT timezone('utc', now())
);

CREATE TRIGGER cell_timestamp
BEFORE UPDATE ON cell
FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

CREATE TABLE "record_store" (
    "type" varchar PRIMARY KEY,
    "data" jsonb,
    "updated" timestamp DEFAULT timezone('utc', now())
);

CREATE TRIGGER record_store_timestamp
BEFORE UPDATE ON record_store
FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

CREATE TABLE "cell_per_player" (
    "description" varchar,
    "name" varchar,
    "updated" timestamp DEFAULT timezone('utc', now()),
    PRIMARY KEY ("description", "name")
);

ALTER TABLE "cell_per_player" ADD FOREIGN KEY ("description") REFERENCES "cell" ("description");
ALTER TABLE "cell_per_player" ADD FOREIGN KEY ("name") REFERENCES "player" ("name");

CREATE TRIGGER cell_per_player_timestamp
BEFORE UPDATE ON cell_per_player
FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

CREATE TABLE "storage" (
    "key" varchar PRIMARY KEY,
    "data" jsonb,
    "updated" timestamp DEFAULT timezone('utc', now())
);

CREATE TRIGGER storage_timestamp
BEFORE UPDATE ON storage
FOR EACH ROW EXECUTE PROCEDURE update_timestamp();
]]

local result = postgresDrive.QueryAsync(sql)
if result.error then
    return 1
end
return 0
end