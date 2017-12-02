TableHelper = require("tableHelper")

local InterfaceManager = {}

InterfaceManager.ID = TableHelper.enum {
    "LOGIN",
    "REGISTER",
    "PLAYERSLIST",
    "CELLSLIST"
}

InterfaceManager.showLogin = function(player)
    player:getGUI():passwordDialog(InterfaceManager.ID.LOGIN, "Enter your password:", "")
end

InterfaceManager.showRegistration = function(player)
    player:getGUI():passwordDialog(InterfaceManager.ID.REGISTER, "Create new password:",
        "Warning: the server owner will be able to read your password, so you should use a unique one for each server.")
end

return InterfaceManager
