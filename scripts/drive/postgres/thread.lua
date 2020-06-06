local effil = require("effil")
local Request = require("drive.postgres.request")
local luasql = require("luasql.postgres").postgres()
local threadHandler = require('threadHandler')

math.randomseed(os.time())

local connection
local connectionString

local RECONNECT_LIMIT = 5
local reconnectCounter = 0

function Run(input, output)
    threadHandler.ReceiveMessages(input, output, ProcessRequest)
end

function ProcessRequest(req)
    if req.type == Request.CONNECT then
        connectionString = req.sql
        reconnectCounter = 0
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
        while err do
            if Reconnect(err) then
                cur, err = connection:execute(query)
            else
                return effil.table{
                    error = err
                }
            end
        end
        
        reconnectCounter = 0
        
        if type(cur) == "number" then
            return effil.table{
                log = req.sql,
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
        for i = 1, count do
            rows[i] = cur:fetch({}, modestring)
        end
        cur:close()
        
        return effil.table{
            log = req.sql,
            count = count,
            rows = rows,
            types = types
        }
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
        if #p > 100 then
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
    
    while sI <= sN and pI <= pN do
        local ch = sql:sub(sI, sI)
        if ch == '?' and not escaped then
            table.insert(result, sql:sub(sT, sI - 1))
            table.insert(result, parameters[pI])
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

function Reconnect(err)
    local fl = err:find("PostgreSQL: no connection to the server") ~= nil
    if fl then
        reconnectCounter = reconnectCounter + 1
        if reconnectCounter > RECONNECT_LIMIT then
            error("Failed to reconnect!")
        end
        connection = luasql:connect(connectionString)
    end
    return fl
end

return Run
