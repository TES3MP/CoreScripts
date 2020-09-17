-- Load up your custom scripts here! Ideally, your custom scripts will be placed in the scripts/custom folder and then get loaded like this:
--
-- require("custom/yourScript")
--
-- Refer to the Tutorial.md file for information on how to use various event and command hooks in your scripts.


local GUICustom = require("GUICustom")

--require('custom.defaultResource')

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
</Resource>
</MyGUI>
]])

GUICustom.Layout("urm_mp", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="0 0 300 400" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget position="0 10 300 30" type="MPTextBox" skin="ProgressText">
        <Property key="Caption" value="Normal"/>
        <Property key="TextColour@Focus" value="#ff0000"/>
        <Property key="TextColour@FocusLost" value="#ffffff"/>
        <Property key="Caption@Focus" value="NORMAL"/>
        <Property key="Caption@FocusLost" value="Normal"/>
        <Property key="Caption@MouseDoubleClick" value=""/>
    </Widget>
    <Widget position="0 50 300 30" type="MPEditBox" skin="URM_TextEdit">
        <Property key="Field" value="yellow_text"/>
        <Property key="=Caption" valuea="cap"/>
        <Property key="@TextChange" value="urm_change"/>
        <Property key="@Accept" value="urm_accept"/>
    </Widget>
    <Widget type="MPComboBox" skin="MW_ComboBox" position="0 100 300 80">
        <Property key="Field" value="combo"/>
        <Property key="AddItem" value="Combo 1"/>
        <Property key="AddItem" value="Combo 2"/>
        <Property key="AddItem" value="Combo 3"/>
        <Property key="@Change" value="urm_combo_change"/>
        <Property key="@Accept" value="urm_combo_accept"/>
    </Widget>
    <Widget type="MPListBox" skin="MW_List" position="0 150 300 100">
        <Property key="Field" value="list"/>
        <Property key="AddItem" value="Row 1"/>
        <Property key="AddItem" value="Row 2"/>
        <Property key="AddItem" value="Row 3"/>
        <Property key="AddItem@Accept" value="new..."/>
        <Property key="@Select" value="urm_list_select"/>
        <Property key="@Accept" value="urm_list_accept"/>
        <Property key="@Scroll" value="urm_list_scroll"/>
    </Widget>
    <Widget position="0 260 0 0" type="MPAutoSizedButton" skin="MW_Button" align="Bottom">
        <Property key="Caption" value="OK"/>
        <Property key="TextPadding" value="30 10"/>
        <Property key="TextPadding@Focus" value="50 20"/>
        <Property key="TextPadding@FocusLost" value="30 10"/>
        <Property key="Caption@MouseDown" value="ALRIGHT"/>
        <Property key="Caption@MouseUp" value="OK"/>
        <Property key="Caption@MouseClick" value="LOADING..."/>
        <Property key="@MouseClick" value="urm_mp_ok"/>
    </Widget>
</Widget>
</MyGUI>
]])
local mp
chatCommandHooks.registerCommand("mp", function(pid)
    mp = GUICustom(pid, "urm_mp")
    mp:Show({
        cap = "TEXTBOX"
    })
end)

GUICustom.Layout("urm_progress", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="0 0 600 400" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget position="50 100 250 100" type="MPProgressBar" skin="MW_Progress_Red" name="Health">
        <Property key="Range" value="100"/>
        <Property key="=RangePosition" value="value"/>
        <Property key="RangePosition@Focus" value="75"/>
        <Property key="RangePosition@FocusLost" value="25"/>
        <Property key="RangePosition@MouseDown" value="50"/>
        <Property key="@Focus" value="focus"/>
        <Property key="@FocusLost" value="focuslost"/>
        <Property key="@MouseDown" value="mouseDown"/>
    </Widget>
</Widget>
</MyGUI>
]])
local progress
local value = 0
chatCommandHooks.registerCommand("progress", function(pid)
    if not progress then progress = GUICustom(pid, "urm_progress") end
    progress:Show{
        value = value
    }
    timers.Interval(100, function()
        value = value + 1
        if(value > 100) then value = 0 end
        progress:Update{
            value = value
        }
    end)
end)

GUICustom.Layout("urm_scroll", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="0 0 600 400" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget type="ScrollView" skin="MW_ScrollView" position="8 160 507 170" align="Left Top" name="SpellArea">
        <Property key="CanvasAlign" value="Left"/>

        <Widget type="MWSpell" skin="MW_StatName" position="0 21 121 56">
            <Property key="Caption" value="Key"/>
            <Property key="ItemResizingPolicy" value="Fill"/>
        </Widget>
    </Widget>>
</Widget>
</MyGUI>
]])
local scroll
chatCommandHooks.registerCommand("scroll", function(pid)
    if not scroll then scroll = GUICustom(pid, "urm_scroll") end
    scroll:Toggle()
end)

GUICustom.Layout("urm_multilist", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="0 0 600 400" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget type="MultiListBox" skin="MultiListBox" position="3 28 250 85" align="HStretch Top" name="multilist">
        <Widget type="MultiListItem" skin="" position="0 21 121 56">
            <Property key="Caption" value="Key"/>
            <Property key="ItemResizingPolicy" value="Fill"/>
        </Widget>
        <Widget type="MultiListItem" skin="" position="121 21 121 56">
            <Property key="Caption" value="Value"/>
            <Property key="ItemResizingPolicy" value="Fill"/>
        </Widget>
    </Widget>
</Widget>
</MyGUI>
]])
local mlist
chatCommandHooks.registerCommand("mlist", function(pid)
    if not mlist then mlist = GUICustom(pid, "urm_multilist") end
    mlist:Toggle()
end)

GUICustom.Layout("urm_form", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="VBox" skin="HUD_Box_NoTransp" layer="Windows" position="0 0 300 400" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget type="MPTextBox" skin="ProgressText" position="0 0 300 18" align="Left Top">
        <Property key="TextAlign" value="Left Top"/>
        <Property key="Caption" value="Test"/>
        <Property key="=Caption" value="cap"/>
    </Widget>
    
    <Widget type="MPEditBox" skin="MW_TextEdit" position="0 0 300 30" align="HStretch Top">
        <Property key="Field" value="text"/>
        <Property key="Caption" value="MW"/>
    </Widget>

    <Widget type="MPEditBox" skin="URM_TextEdit" position="0 0 300 30" align="HStretch Top">
        <Property key="Field" value="yellow_text"/>
        <Property key="Caption" value="URM"/>
    </Widget>

    <Widget type="MPListBox" skin="MW_List" position="0 0 300 200" align="Stretch">
        <Property key="Field" value="list"/>
        <Property key="AddItem" value="Row 1"/>
        <Property key="AddItem" value="Row 2"/>
        <Property key="AddItem" value="Row 3"/>
    </Widget>

    <Widget type="HBox" align="Center">
        <Widget type="MPAutoSizedButton" skin="MW_Button" align="Center">
            <Property key="Caption" value="OK"/>
            <Property key="@MouseClick" value="urm_form_ok"/>
            <Property key="@ButtonPressed" value="urm_form_ok"/>
        </Widget>
    </Widget>
</Widget>
</MyGUI>
]])
local formMap = {}
chatCommandHooks.registerCommand("form", function(pid)
    if not formMap[pid] then
        formMap[pid] = GUICustom(pid, "urm_form")
    end
    formMap[pid]:Show({
        cap = "TEXTBOX"
    })
end)

GUICustom.Layout("urm_window", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="Window" skin="MW_Window" layer="Windows" position="0 0 100 150" name="_Main">
    <UserString key="Anchor" value="1 0.5"/>
    <UserString key="RelativePosition" value="1 0.5"/>
    <Property key="Caption" value="HUD"/>

    <Widget type="MPListBox" skin="MW_List" position="0 0 100 150" align="Stretch">
        <Property key="Field" value="list"/>
        <Property key="ActivateOnClick" value="1"/>
        <Property key="AddItem" value="Select 1"/>
        <Property key="AddItem" value="Select 2"/>
        <Property key="@MouseClick" value="urm_window_list"/>
    </Widget>
</Widget>
</MyGUI>
]])
local windowMap = {}
chatCommandHooks.registerCommand("window", function(pid)
    if windowMap[pid] then
        windowMap[pid]:Toggle()
    else
        windowMap[pid] = GUICustom(pid, "urm_window", true)
        windowMap[pid]:Show()
    end
end)

GUICustom.Layout("urm_clock", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="Window" skin="HUD_Box_NoTransp" layer="HUD" position="0 0 100 50" name="_Main">
    <UserString key="Anchor" value="0.5 1"/>
    <UserString key="RelativePosition" value="0.5 1"/>

    <Widget type="MPTextBox" skin="ProgressText" position="0 0 100 50" align="Left Top">
        <Property key="Caption" value="00:00:00"/>
        <Property key="=Caption" value="time"/>
    </Widget>
</Widget>
</MyGUI>
]])

local clockMap = {}
local clockIntervals = {}
chatCommandHooks.registerCommand("clock", function(pid)
    if not clockMap[pid] then
        clockMap[pid] = GUICustom(pid, "urm_clock", true)
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

GUICustom.Layout("urm_book", [[
<?xml version="1.0" encoding="UTF-8"?>
<MyGUI type="Layout">
<Widget type="Window" skin="" layer="JournalBooks" align="Left Top" position="0 0 584 398" name="_Main">
    <UserString key="Anchor" value="0.5 0.5"/>
    <UserString key="RelativePosition" value="0.5 0.5"/>

    <Widget type="MPImageBox" skin="ImageBox" position="-71 0 728 398" align="Left Top" name="JImage">
        <Property key="ImageTexture" value="textures\tx_menubook.dds"/>

        <Widget type="Widget" position="71 0 584 398" align="Left Top">
            <Widget type="MPImageBox" skin="ImageBox" position="40 358 48 32" name="TakeButton">
                <Property key="ImageTexture" value="textures\tx_menubook_take_idle.dds"/>
                <Property key="ImageTexture@Focus" value="textures\tx_menubook_take_over.dds"/>
                <Property key="ImageTexture@FocusLost" value="textures\tx_menubook_take_idle.dds"/>
                <Property key="ImageTexture@MouseDown" value="textures\tx_menubook_take_pressed.dds"/>
                <Property key="ImageTexture@MouseUp" value="textures\tx_menubook_take_idle.dds"/>
                <Property key="TextureRect" value="0 0 48 32"/>
                <Property key="@MouseClick" value="urm_book_take"/>
            </Widget>

            <Widget type="MPImageBox" skin="ImageBox" position="205 358 48 32" name="PrevPageBTN">
                <Property key="ImageTexture" value="textures\tx_menubook_prev_idle.dds"/>
                <Property key="ImageTexture@Focus" value="textures\tx_menubook_prev_over.dds"/>
                <Property key="ImageTexture@FocusLost" value="textures\tx_menubook_prev_idle.dds"/>
                <Property key="ImageTexture@MouseDown" value="textures\tx_menubook_prev_pressed.dds"/>
                <Property key="ImageTexture@MouseUp" value="textures\tx_menubook_prev_idle.dds"/>
                <Property key="TextureRect" value="0 0 48 32"/>
            </Widget>
            <Widget type="MPImageBox" skin="ImageBox" position="330 358 48 32" name="NextPageBTN">
                <Property key="ImageTexture" value="textures\tx_menubook_next_idle.dds"/>
                <Property key="ImageTexture@Focus" value="textures\tx_menubook_next_over.dds"/>
                <Property key="ImageTexture@FocusLost" value="textures\tx_menubook_next_idle.dds"/>
                <Property key="ImageTexture@MouseDown" value="textures\tx_menubook_next_pressed.dds"/>
                <Property key="ImageTexture@MouseUp" value="textures\tx_menubook_next_idle.dds"/>
                <Property key="TextureRect" value="0 0 48 32"/>
            </Widget>

            <Widget type="MPImageBox" skin="ImageBox" position="488 358 48 32" name="CloseButton">
                <Property key="ImageTexture" value="textures\tx_menubook_close_idle.dds"/>
                <Property key="ImageTexture@Focus" value="textures\tx_menubook_close_over.dds"/>
                <Property key="ImageTexture@FocusLost" value="textures\tx_menubook_close_idle.dds"/>
                <Property key="ImageTexture@MouseDown" value="textures\tx_menubook_close_pressed.dds"/>
                <Property key="ImageTexture@MouseUp" value="textures\tx_menubook_close_idle.dds"/>
                <Property key="@MouseClick" value="urm_bool_close"/>
                <Property key="TextureRect" value="0 0 48 32"/>
            </Widget>

            <Widget type="MPTextBox" skin="NormalText" position="30 358 250 16" name="LeftPageNumber">
                <Property key="FontName" value="Journalbook Magic Cards"/>
                <Property key="TextColour" value="0 0 0"/>
                <Property key="TextAlign" value="Center"/>
                <Property key="NeedMouse" value="false"/>
            </Widget>
            <Widget type="MPTextBox" skin="NormalText" position="310 358 250 16" name="RightPageNumber">
                <Property key="FontName" value="Journalbook Magic Cards"/>
                <Property key="TextColour" value="0 0 0"/>
                <Property key="TextAlign" value="Center"/>
                <Property key="NeedMouse" value="false"/>
            </Widget>
            <Widget type="Widget" skin="" position="310 15 250 328" name="RightPage"/>
        </Widget>
    </Widget>

    <Widget type="MPEditBox" skin="MW_TextEdit" position="40 10 240 340">
        <Property key="Multiline" value="1"/>
        <Property key="WordWrap" value="1"/>
        <Property key="TextAlign" value="Left Top"/>
        <Property key="TextColour" value="0 0 0"/>
        <Property key="Field" value="left_page"/>
        <Property key="Caption" value="TEST TEXT LONG TEST TEXT BLA BLA"/>
    </Widget>
</Widget>
</MyGUI>
]])
local bookMap = {}
chatCommandHooks.registerCommand("book", function(pid)
    if not bookMap[pid] then
        bookMap[pid] = GUICustom(pid, "urm_book")
        bookMap[pid]:Show()
    else
        bookMap[pid]:Toggle()
    end
end)

customEventHooks.registerHandler("OnGUICustom", function(eventStatus, pid, idGui, event, data, fields)
    tes3mp.SendMessage(
        pid,
        table.concat{
            "=====",
            "Event: " .. event .. "\n",
            "Data: " .. data .. "\n",
            "Fields: " .. tableHelper.getPrintableTable(fields) .. "\n"
        }
    )
    if event == "urm_form_ok" then
        if formMap[pid] then
            formMap[pid]:Hide()
        end
    elseif event == "urm_mp_ok" then
        if mp then
            timers.Timeout(1000, function()
                mp:Hide()
                mp = nil
            end)
        end
    end
end)
