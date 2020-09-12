-- Load up your custom scripts here! Ideally, your custom scripts will be placed in the scripts/custom folder and then get loaded like this:
--
-- require("custom/yourScript")
--
-- Refer to the Tutorial.md file for information on how to use various event and command hooks in your scripts.


local GUICustom = require("GUICustom")

GUICustom.Resource("urm_test", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Resource" version="1.1">
<Resource type="ResourceSkin" name="URM_TextEdit" size="512 20">
    <Child type="Widget" skin="MW_Box" offset="0 0 512 20" align="Stretch"/>
    <Property key="FontName" value="Default"/>
    <Property key="TextAlign" value="Left VCenter"/>
    <Property key="TextColour" value="#ffff00"/>
    <Child type="TextBox" skin="MW_TextEditClient" offset="4 0 502 18" align="Stretch" name="Client"/>
</Resource>
</MyGUI>
]])

local formLayout = [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="600 200 300 400" name="_Main">
    <UserString key="Anchor" value="150 200"/>
    <UserString key="RelativePosition" value="50 50"/>
    <Widget type="TextBox" skin="ProgressText" position="0 0 300 18" align="Left Top">
        <Property key="TextAlign" value="Left Top"/>
        <Property key="Caption" value="Test"/>
        <UserString key="Bind:Caption" value="cap"/>
    </Widget>
    
    <Widget type="EditBox" skin="MW_TextEdit" position="0 0 300 30" align="HStretch Top">
        <UserString key="Field" value="text"/>
        <Property key="Caption" value="MW"/>
    </Widget>

    <Widget type="EditBox" skin="URM_TextEdit" position="0 0 300 30" align="HStretch Top">
        <UserString key="Field" value="yellow_text"/>
        <Property key="Caption" value="URM"/>
    </Widget>

    <Widget type="ListBox" skin="MW_List" position="0 0 300 200" align="Stretch">
        <UserString key="Field" value="list"/>
        <Property key="AddItem" value="Row 1"/>
        <Property key="AddItem" value="Row 2"/>
        <Property key="AddItem" value="Row 3"/>
    </Widget>

    <Widget type="HBox" align="Center">
        <Widget type="AutoSizedButton" skin="MW_Button" align="Center">
            <Property key="Caption" value="OK"/>
            <UserString key="MouseClick" value="urm_form_ok"/>
            <UserString key="ButtonPressed" value="urm_form_ok"/>
        </Widget>
    </Widget>
</Widget>
</MyGUI>
]]
local formMap = {}
chatCommandHooks.registerCommand("form", function(pid)
    if not formMap[pid] then
        formMap[pid] = GUICustom(pid, formLayout)
    end
    formMap[pid]:Show({
        cap = "TEXTBOX"
    })
end)

local windowLayout = [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="Window" skin="MW_Window" layer="Windows" position="0 0 100 150" name="_Main">
    <UserString key="Anchor" value="100 75"/>
    <UserString key="RelativePosition" value="100 50"/>
    <Property key="Caption" value="HUD"/>

    <Widget type="ListBox" skin="MW_List" position="0 0 100 150" align="Stretch">
        <UserString key="Field" value="list"/>
        <Property key="ActivateOnClick" value="1"/>
        <Property key="AddItem" value="Select 1"/>
        <Property key="AddItem" value="Select 2"/>
        <UserString key="MouseClick" value="urm_window_list"/>
    </Widget>
</Widget>
</MyGUI>
]]
local windowMap = {}
chatCommandHooks.registerCommand("window", function(pid)
    if windowMap[pid] then
        windowMap[pid]:Toggle()
    else
        windowMap[pid] = GUICustom(pid, windowLayout, true)
        windowMap[pid]:Show()
    end
end)

local clockLayout = [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="Window" skin="HUD_Box_NoTransp" layer="HUD" position="0 0 100 50" name="_Main">
    <UserString key="Anchor" value="50 50"/>
    <UserString key="RelativePosition" value="50 100"/>
    <Widget type="TextBox" skin="ProgressText" position="0 0 100 50" align="Left Top">
        <Property key="Caption" value="00:00:00"/>
        <UserString key="Bind:Caption" value="time"/>
    </Widget>
</Widget>
</MyGUI>
]]

local clockMap = {}
local clockIntervals = {}
chatCommandHooks.registerCommand("clock", function(pid)
    if not clockMap[pid] then
        clockMap[pid] = GUICustom(pid, clockLayout, true)
        clockMap[pid]:Show({
            time = os.date("%X")
        })
    else
        clockMap[pid]:Toggle()
    end
    if clockMap[pid]:Visible() then
        if not clockIntervals[pid] then
            clockIntervals[pid] = timers.Interval(1000, function()
                clockMap[pid]:Update({
                    time = os.date("%X")
                })
            end)
        end
    elseif clockIntervals[pid] then
        timers.Stop(clockIntervals[pid])
        clockIntervals[pid] = nil
    end
end)


customEventHooks.registerHandler("OnGUICustom", function(eventStatus, pid, idGui, event, data, fields)
    if event == "urm_form_ok" then
        if formMap[pid] then
            tes3mp.SendMessage(
                pid,
                "Form: \n" .. tableHelper.getPrintableTable(formMap[pid]:Fields()) .. "\n"
            )
            formMap[pid]:Hide()
        end
    elseif event == "urm_window_list" then
        if windowMap[pid] then
            tes3mp.SendMessage(
                pid,
                "Window: \n" .. tableHelper.getPrintableTable(windowMap[pid]:Fields()) .. "\n"
            )
        end
    end
end)
