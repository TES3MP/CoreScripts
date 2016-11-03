GUI = {}
GUI.LOGIN = 0
GUI.REGISTER = 1

GUI.ShowLogin = function(pid)
    tes3mp.InputDialog(pid, GUI.LOGIN, "Enter your password:")
end

GUI.ShowRegister = function(pid)
    tes3mp.InputDialog(pid, GUI.REGISTER, "Create new password:")
end

return GUI
