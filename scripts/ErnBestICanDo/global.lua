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
local core     = require("openmw.core")
local async    = require("openmw.async")


if require("openmw.core").API_REVISION < 111 then
    error("OpenMW 0.51 or newer is required!")
    return
end

-- 24.0
local resetTime = core.getGMST("fBarterGoldResetDelay")

local persist = {
    originalValuesMap = {},
}

local resetCallback = async:registerTimerCallback("resetCallback", function(data)
    local npc = data.npc
    local originalGold = data.originalGold
    print("Restoring gold for " .. npc.recordId .. " to " .. tostring(originalGold))
    npc.type.setBarterGold(npc, originalGold)
end)

local function ensureTimer(npc)
    local originalGold = persist.originalValuesMap[npc.id]
    if originalGold then
        async:newGameTimer(resetTime * 60 * 60, resetCallback, {
            npc = npc,
            originalGold = persist.originalValuesMap[npc.id],
        })
    end
end

local function limitGold(data)
    local currentGold = data.npc.type.getBarterGold(data.npc)

    if not currentGold then
        return
    end

    -- save off original amount before we start messing with it.
    if not persist.originalValuesMap[data.npc.id] then
        persist.originalValuesMap[data.npc.id] = currentGold
    end
    local originalGold = persist.originalValuesMap[data.npc.id]

    if currentGold > originalGold or currentGold > data.maxGold then
        print(data.npc.recordId .. "- current: " ..
            tostring(currentGold) ..
            ", original: " .. tostring(originalGold) .. ", max: " .. tostring(data.maxGold))
        data.npc.type.setBarterGold(data.npc, math.min(originalGold, data.maxGold))
        -- notify player to re-open window
        data.player:sendEvent(MOD_NAME .. "onReOpenBarterWindow", {
            target = data.npc,
        })
    end
end

local function onBarterStart(data)
    if not data.npc then
        error("no npc in data")
        return
    end

    ensureTimer(data.npc)
    limitGold(data)
end

local function onLoad(data)
    if data then
        persist = data
    end
end
local function onSave()
    return persist
end

return {
    eventHandlers = {
        [MOD_NAME .. "onBarterStart"] = onBarterStart,
    },
    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
    }
}
