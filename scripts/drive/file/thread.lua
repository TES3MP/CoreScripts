local threadHandler = require('threadHandler')
local request = require('drive.file.request')

local lib = nil
local home = nil

function Run(input, output)
    threadHandler.ReceiveMessages(input, output, ProcessRequest)
end

function ProcessRequest(req)
    if req.type == request.INIT then
        -- Lua's default io library for input/output can't open Unicode filenames on Windows,
        -- which is why on Windows it's replaced by TES3MP's io2 (https://github.com/TES3MP/Lua-io2)
        if req.content == 'Windows' then
            lib = require('io2')
        else
            lib = io
        end
        home = req.path
        return {
            log = "Successfully initiated"
        }
    elseif req.type == request.SAVE then
        local file = lib.open(home .. req.path, 'w+b')
        if file then
            file:write(req.content)
            file:close()
            return {
                content = true
            }
        else
            return {
                content = false,
                error = "Failed to load the file " .. req.path
            }
        end
    elseif req.type == request.LOAD then
        local file = lib.open(home .. req.path, 'r')
        if file then
            local content = file:read("*all")
            file:close()
            return {
                content = content
            }
        else
            return {
                content = nil,
                error = "Failed to save the file " .. req.path
            }
        end
    end
end

return Run
