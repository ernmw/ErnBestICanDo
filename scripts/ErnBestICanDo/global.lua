--[[
ErnBestICanDo for OpenMW.
Copyright (C) Erin Pentecost 2026

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

-- This file is in charge of tracking and exposing path information.
-- Interact with it via the interface it exposes.

local MOD_NAME = require("scripts.ErnBestICanDo.ns")

local tradingNPCs = {}

local function onBarterStart(data)
    tradingNPCs[data.player.id] = data
end

local function onBarterEnd(data)
    tradingNPCs[data.player.id] = nil
end

local function limitGold(data)
    local inventory = data.npc.type.inventory(data.npc)
    local gold = inventory:find("gold_001")
    if not gold then
        print("no gold!")
        return
    end
    -- https://en.uesp.net/wiki/Morrowind_Mod:Alphabetical_Function_List
    -- inventory gold != barter gold.
    print("found gold: " .. tostring(gold.count))
    if gold.count > data.maxGold then
        print("removing excess gold (" .. tostring(gold.count) .. ") down to max: " .. tostring(data.maxGold))
        gold:remove(gold.count - data.maxGold)
    end
end

local function onUpdate(dt)
    for _, npc in pairs(tradingNPCs) do
        if npc then
            limitGold(npc)
        end
    end
end

return {
    eventHandlers = {
        [MOD_NAME .. "onBarterStart"] = onBarterStart,
        [MOD_NAME .. "onBarterEnd"] = onBarterEnd,
    },
    engineHandlers = {
        onUpdate = onUpdate,
    }
}
