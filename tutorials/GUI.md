# GUI

There are two ways to interact with GUI included in CoreScripts:
* [MenuHelper](#menuhelper) a template system, allows you to link many menus together, and makes it straightforward to split complicated GUI into modules
* [guiHelper](#guihelper) a simpler and lower level option, provides an `Async` version of every primitive `tes3mp` GUI function

## MenuHelper

>TODO: a more detailed writeup

You can find some examples in [default crafting](../scripts/menu/defaultCrafting.lua) and [advanced example](../scripts/menu/advancedExample.lua).

## guiHelper

* `guiHelper.MessageBox(pid, label)` not much different than `tes3mp.MessageBox`, provided only for the sake of uniformity
* `guiHelper.CustomMessageBoxAsync(pid, buttons, label)` returns index of the pressed button in `buttons`  
  * `buttons` is an "array" of button labels  
  *  `label` is the text displayed above the buttons
* `guiHelper.InputDialogAsync(pid, label, note)` returns the input text
  `
* `guiHelper.PasswordDialogAsync(pid, label, note)`
* `guiHelper.ListBoxAsync(pid, rows, label)`

A basic example, showcasing the ability to chain one GUI call after another:
```Lua
local function msg(pid, str)
    tes3mp.SendMessage(pid, tostring(str) .. "\n")
end
local function command(pid, cmd)
    async.Wrap(function()
        guiHelper.MessageBox(pid, "LABEL")
        local rows = {
            "line 1",
            "line 2",
            "meh",
            "what if \t that"
        }
        local res = guiHelper.ListBoxAsync(pid, rows, "LABEL")
        msg(pid, "Row: " .. (rows[res or 0] or "NIL"))
        local buttons = {"A", "B", "C"}
        msg(pid, "Button: " .. buttons[guiHelper.CustomMessageBoxAsync(pid, buttons, "LABEL")])
        msg(pid, "Input: " .. guiHelper.InputDialogAsync(pid, "LABEL", "NOTE"))
        msg(pid, "Pass: " .. guiHelper.PasswordDialogAsync(pid, "LABEL", "NOTE"))
    end)
end

customCommandHooks.registerCommand("gui", command)
```
If you attempted something similar with synchronous `tes3mp` GUI functions, only the last call would do anything, as there can only be one GUI active per player at a time. This code will instead wait for each GUI element to resolve, before calling the next one.