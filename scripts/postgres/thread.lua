local effil = require("effil")
local Request = require("postgres.request")
local luasql = require("luasql.postgres").postgres()
local connection

function Run(inputChannel, outputChannel)
  input = inputChannel
  output = outputChannel
  while true do
    local inp = input:pop()
    ProcessInput(inp)
  end
end

function PrepareParameters(parameters)
  local n = #parameters
  for i = 1, n do
    parameters[i] = connection:escape(tostring(parameters[i]))
  end
  return parameters
end

function ProcessInput(inp)
  local message = ProcessRequest(inp.message)
  output:push(effil.table{
    id = inp.id,
    message = message
  })
end

function PrepareQuery(sql, parameters)
  if #parameters == 0 then
    return sql
  end
  local sI = 1
  local sT = 1
  local pI = 1
  local sN = #sql
  local pN = #parameters
  local result = {}
  local escaped = false

  print(parameters[pI])

  while sI <= sN and pI <= pN do
    local ch = sql:sub(sI, sI)
    if ch == '?' and not escaped then
      table.insert(result, sql:sub(sT, sI - 1))
      table.insert(result, "'" .. parameters[pI] .. "'")
      pI = pI + 1
      sT = sI + 1
    end
    if ch == '\\' then
      escaped = not escaped
    else
      escaped = false
    end
    sI = sI + 1
  end

  -- no ? in the query
  if sT == 1 then
    return sql
  end
  table.insert(result, sql:sub(sT))
  return table.concat(result)
end

function ProcessRequest(req)
  if req.type == Request.CONNECT then
    connection = assert(luasql:connect(req.sql))
    return effil.table{
      log = "Successfully connected!"
    }
  elseif req.type == Request.DISCONNECT then
    connection:close()
    return effil.table{
      log = "Disconnected!"
    }
  elseif req.type == Request.QUERY or req.type == Request.QUERY_NUMERICAL_INDICES then
    PrepareParameters(req.parameters)
    local query = PrepareQuery(req.sql, req.parameters)
    local cur, err = connection:execute(query)
    if err then
      return effil.table{
        error = err
      }
    end
    
    if type(cur) == "number" then
      return effil.table{
        log = sql,
        count = cur,
        rows = {},
        types = {}
      }
    end

    local types = cur:getcoltypes()
    local count = cur:numrows()
    local rows = effil.table()
    local modestring = "a"
    if req.type == Request.QUERY_NUMERICAL_INDICES then
      modestring = "n"
    end
    for i = 1,count do
      rows[i] = cur:fetch({}, modestring)
    end
    cur:close()

    return effil.table{
      log = sql,
      count = count,
      rows = rows,
      types = types
    }
  end
end
