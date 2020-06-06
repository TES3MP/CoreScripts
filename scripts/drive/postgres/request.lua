local effil = require("effil")
local Request = {}

-- Type enum
Request.CONNECT = 1
Request.DISCONNECT = 2
Request.QUERY = 3
Request.QUERY_NUMERICAL_INDICES = 4

Request.currentId = 0

function Request.form(type, sql, parameters)
    Request.currentId = Request.currentId + 1
    return effil.table{
        id = Request.currentId,
        type = type,
        sql = sql,
        parameters = parameters
    }
end

return Request
