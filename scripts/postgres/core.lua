local effil = require("effil")

local postgres = require("postgres.client")

-- temporary test
coroutine.wrap(function()
  postgres.Initiate()
  postgres.Connect("host=localhost port=5432 dbname=tes3mp user=postgres password=postgres connect_timeout=10")
  local res = postgres.QueryAwait("SELECT name FROM players", { "test4" })
  tableHelper.print(effil.dump(res))
end)()
