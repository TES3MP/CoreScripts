TableHelper = require("tableHelper")

local InterfaceManager = {}

InterfaceManager.ID = TableHelper.enum {
    "LOGIN",
    "REGISTER",
    "PLAYERSLIST",
    "CELLSLIST"
}

InterfaceManager.showLogin = function(callback, player)
    player:getGUI():passwordDialog(callback, "Enter your password:", "")
end

InterfaceManager.showRegistration = function(callback, player)
    player:getGUI():passwordDialog(callback, "Create new password:",
        "Warning: the server owner will be able to read your password, so you should use a unique one for each server.")
end

return InterfaceManager
