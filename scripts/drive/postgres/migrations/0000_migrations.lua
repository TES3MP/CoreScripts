return function(postgresDrive)
local sql =
[[
CREATE TABLE "migrations" (
    "id" bigserial,
    "processed" timestamp default timezone('utc', now())
);
]]

local result = postgresDrive.QueryAsync(sql)
if result.error then
    return 1
end
return 0
end