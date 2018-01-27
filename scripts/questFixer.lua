tableHelper = require("tableHelper")
require("utils")

local questFixer = {}

local refNumDeletionsByCell = {}
-- Delete Socucius Ergalla
refNumDeletionsByCell["Seyda Neen, Census and Excise Office"] = { 119636 }
-- Delete the chargen boat and associated guards and objects
refNumDeletionsByCell["-1, -9"] = { 268178, 297457, 297459, 297460, 299125 }
refNumDeletionsByCell["-2, -9"] = { 172848, 172850, 172852, 289104, 297461, 397559 }
refNumDeletionsByCell["-2, -10"] = { 297463, 297464, 297465, 297466 }

local deadlyItems = { "keening" }

function questFixer.FixCell(pid, cellDescription)

    if refNumDeletionsByCell[cellDescription] ~= nil then

        tes3mp.InitializeEvent(pid)
        tes3mp.SetEventCell(cellDescription)

        for arrayIndex, refNum in pairs(refNumDeletionsByCell[cellDescription]) do
            tes3mp.SetObjectRefNumIndex(refNum)
            tes3mp.SetObjectMpNum(0)
            tes3mp.SetObjectRefId("")
            tes3mp.AddWorldObject()
        end

        tes3mp.SendObjectDelete()
    end
end

function questFixer.ValidateCellChange(pid)

    local cell = tes3mp.GetCell(pid)

    if cell == "Seyda Neen, Census and Excise Office" then
        tes3mp.MessageBox(pid, -1, "Everything from the default character generation is currently broken in multiplayer. You'll have to avoid that area for now.")
        return false
    end

    return true
end

function questFixer.UnequipDeadlyItems(pid)

    local itemsFound = 0

    for arrayIndex, itemRefId in pairs(deadlyItems) do
        if tableHelper.containsKeyValue(Players[pid].data.equipment, "refId", itemRefId, true) then
            local itemSlot = tableHelper.getIndexByNestedKeyValue(Players[pid].data.equipment, "refId", itemRefId, true)
            tableHelper.print(Players[pid].data.equipment)
            Players[pid].data.equipment[itemSlot] = nil
            tableHelper.print(Players[pid].data.equipment)
            itemsFound = itemsFound + 1
        end
    end

    if itemsFound > 0 then
        Players[pid]:Save()
        Players[pid]:LoadEquipment()
    end
end

return questFixer
