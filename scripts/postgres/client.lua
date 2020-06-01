local effil = require("effil")
local Request = require("postgres.request")

local DB = {}

DB.thread = nil

function DB.ThreadWork(input, output)
  local status, err = pcall(function()
    require("postgres.thread")
    Run(input, output)
  end)
  if err then
    print(err)
    output:push(effil.table{
      id = 0,
      message = effil.table{
        error = err
      }
    })
  end
end

function DB.Initiate()
  DB.thread = threadHandler.CreateThread(DB.ThreadWork)
end

function DB.ProcessResponse(res)
  if res.error then
    tes3mp.LogMessage(enumerations.log.ERROR, "[Postgres] [[" .. res.error .. "]]")
  elseif res.log then
    tes3mp.LogMessage(enumerations.log.INFO, "[Postgres] [[" .. res.log .. "]]")
  end
end

function DB.Send(action, sql, parameters, callback)
  threadHandler.Send(
    DB.thread,
    Request.form(
      action,
      sql or "",
      parameters or {}
    ),
    function(res)
      DB.ProcessResponse(res)
      if callback ~= nil then
        callback(res)
      end
    end
  )
end

function DB.SendAwait(action, sql, parameters)
  local res = threadHandler.SendAwait(
    DB.thread,
    Request.form(
      action,
      sql or "",
      parameters or {}
    )
  )
  DB.ProcessResponse(res)
  return res
end

function DB.Connect(connectString, callback)
  DB.Send(Request.CONNECT, connectString, callback)
end

function DB.ConnectAwait(connectString)
  return DB.SendAwait(Request.CONNECT, connectString)
end

function DB.Disconnect(callback)
  DB.Send(Request.DISCONNECT, callback)
end

function DB.DisconnectAwait()
  return DB.SendAwait(Request.DISCONNECT)
end

function DB.Query(sql, parameters, callback, numericalIndices)
  if numericalIndices then
    DB.Send(Request.QUERY_NUMERICAL_INDICES, sql, parameters, callback)
  else
    DB.Send(Request.QUERY, sql, parameters, callback)
  end
end

function DB.QueryAwait(sql, parameters, numericalIndices)
  if numericalIndices then
    return DB.SendAwait(Request.QUERY_NUMERICAL_INDICES, sql, parameters)
  else
    return DB.SendAwait(Request.QUERY, sql, parameters)
  end
end

return DB
