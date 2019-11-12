tableHelper = require("tableHelper")
require("utils")

local contentFixer = {}

local deadlyItems = { "keening", "sunder" }
local fixesByCell = {}

-- Delete the chargen boat and associated guards and objects
fixesByCell["-1, -9"] = { delete =  { 268178, 297457, 297459, 297460, 299125 }}
fixesByCell["-2, -9"] = { delete = { 172848, 172850, 172852, 289104, 297461, 397559 }}
fixesByCell["-2, -10"] = { delete = { 297463, 297464, 297465, 297466 }}

-- Delete the census papers and unlock the doors
fixesByCell["Seyda Neen, Census and Excise Office"] = { delete = { 172859 }, unlock = { 119513, 172860 }}

function contentFixer.FixCell(pid, cellDescription)

    if fixesByCell[cellDescription] ~= nil then

        for packetType, refNumArray in pairs(fixesByCell[cellDescription]) do

            tes3mp.ClearObjectList()
            tes3mp.SetObjectListPid(pid)
            tes3mp.SetObjectListCell(cellDescription)

            for arrayIndex, refNum in ipairs(refNumArray) do
                tes3mp.SetObjectRefNum(refNum)
                tes3mp.SetObjectMpNum(0)
                tes3mp.SetObjectRefId("")
                if packetType == "unlock" then tes3mp.SetObjectLockLevel(0) end
                tes3mp.AddObject()
            end

            if packetType == "delete" then
                tes3mp.SendObjectDelete()
            elseif packetType == "unlock" then
                tes3mp.SendObjectLock()
            end
        end
    end
end

-- Unequip items that damage the player when worn
--
-- Note: Items with constant damage effects like Whitewalker and the Mantle of Woe
--       are already unequipped by default in the TES3MP client, so this only needs
--       to account for scripted items that are missed there
--
function contentFixer.UnequipDeadlyItems(pid)

    local itemsFound = 0

    for arrayIndex, itemRefId in pairs(deadlyItems) do
        if tableHelper.containsKeyValue(Players[pid].data.equipment, "refId", itemRefId, true) then
            local itemSlot = tableHelper.getIndexByNestedKeyValue(Players[pid].data.equipment, "refId", itemRefId, true)
            Players[pid].data.equipment[itemSlot] = nil
            itemsFound = itemsFound + 1
        end
    end

    if itemsFound > 0 then
        Players[pid]:QuicksaveToDrive()
        Players[pid]:LoadEquipment()
    end
end

return contentFixer
