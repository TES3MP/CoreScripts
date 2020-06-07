local request = {}

-- Type enum
request.CONNECT = 1
request.DISCONNECT = 2
request.QUERY = 3
request.QUERY_NUMERICAL_INDICES = 4

function request.Connect(connectionString)
    return {
        type = request.CONNECT,
        sql = connectionString
    }
end

function request.Disconnect()
    return {
        type = request.DISCONNECT
    }
end

function request.Query(sql, parameters)
    return {
        type = request.QUERY,
        sql = sql or "",
        parameters = parameters or {}
    }
end

function request.QueryNumerical(sql, parameters)
    return {
        type = request.QUERY_NUMERICAL_INDICES,
        sql = sql or "",
        parameters = parameters or {}
    }
end

return request
