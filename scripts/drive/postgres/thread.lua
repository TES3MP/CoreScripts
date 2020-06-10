local effil = require('effil')
local request = require("drive.postgres.request")
local luasql = require("luasql.postgres").postgres()
local threadHandler = require('threadHandler')

local ESCAPE_LIMIT = 1000
local RECONNECT_LIMIT = 5
local RECONNECT_INTERVAL = 200 -- 200 milliseconds

math.randomseed(os.time())

local connection
local connectionString
local reconnectCounter = 0

function Run(input, output)
    threadHandler.ReceiveMessages(input, output, ProcessRequest)
end

function ProcessRequest(req)
    if req.type == request.CONNECT then
        connectionString = req.sql
        reconnectCounter = 0
        connection = assert(luasql:connect(req.sql))
        return {
            log = "Successfully connected!"
        }
    elseif req.type == request.DISCONNECT then
        connection:close()
        return {
            log = "Disconnected!"
        }
    elseif req.type == request.QUERY or req.type == request.QUERY_NUMERICAL_INDICES then
        local status, err = pcall(function() PrepareParameters(req.parameters) end)
        if not status then
            return {
                error = err
            }
        end
        local query = PrepareQuery(req.sql, req.parameters)
        local cur, err = connection:execute(query)
        while err do
            if Reconnect(err) then
                cur, err = connection:execute(query)
            else
                return {
                    error = err
                }
            end
        end
        reconnectCounter = 0
        
        if type(cur) == "number" then
            return {
                log = req.sql,
                count = cur,
                rows = {},
                types = {}
            }
        else
            local types = cur:getcoltypes()
            local count = cur:numrows()
            local rows = {}
            local modestring = "a"
            if req.type == request.QUERY_NUMERICAL_INDICES then
                modestring = "n"
            end
            for i = 1, count do
                rows[i] = cur:fetch({}, modestring)
            end
            cur:close()
            
            return {
                log = req.sql,
                count = count,
                rows = rows,
                types = types
            }
        end
    end
end

local aStart = string.byte('a')
local aEnd = string.byte('x')
local aSize = aEnd - aStart + 1
local tagLength = 10

function GenerateEscapeTag()
    local characters = {'$'}
    for i = 1, tagLength do
        local byte = math.random(aSize) + aStart
        table.insert(characters, string.char(byte))
    end
    table.insert(characters, '$')
    return table.concat(characters)
end

local escapeTag = GenerateEscapeTag()

function Escape(str)
    while str:find(escapeTag) do
        escapeTag = GenerateEscapeTag()
    end
    return table.concat({
        escapeTag,
        str,
        escapeTag
    })
end

function PrepareParameters(parameters)
    local n = #parameters
    for i = 1, n do
        local p = tostring(parameters[i])
        if #p > ESCAPE_LIMIT then
            parameters[i] = Escape(p)
        else
            parameters[i] = "'" .. connection:escape(p) .. "'"
        end
    end
    return parameters
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
    local hasParameters = false
    
    while sI <= sN and pI <= pN do
        local ch = sql:sub(sI, sI)
        if ch == '?' and not escaped then
            hasParameters = true
            table.insert(result, sql:sub(sT, sI - 1))
            table.insert(result, parameters[pI])
            pI = pI + 1
            sT = sI + 1
        end
        if ch == '\\' then
            if escaped then
                table.insert(result, sql:sub(sT, sI - 1))
                sT = sI + 1
            end
            escaped = not escaped
        else
            escaped = false
        end
        sI = sI + 1
    end
    
    -- no ? in the query
    if not hasParameters then
        return sql
    end
    table.insert(result, sql:sub(sT))
    return table.concat(result)
end

function Reconnect(err)
    local fl = err:find("PostgreSQL: no connection to the server") ~= nil
    if fl then
        connection = luasql:connect(connectionString)
        reconnectCounter = reconnectCounter + 1
        while not connection do
            connection = luasql:connect(connectionString)
            reconnectCounter = reconnectCounter + 1
            if reconnectCounter >= RECONNECT_LIMIT then
                break
            end
            effil.sleep(reconnectCounter * RECONNECT_INTERVAL) -- increase reconnect delays over time
        end
        if reconnectCounter > RECONNECT_LIMIT then
            error("Failed to reconnect!")
        end
    end
    return fl
end

return Run
