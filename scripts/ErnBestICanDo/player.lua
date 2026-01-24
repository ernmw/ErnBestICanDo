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
local types    = require('openmw.types')
local core     = require('openmw.core')
local pself    = require("openmw.self")
local util     = require("openmw.util")
local vfs      = require('openmw.vfs')
local aux_util = require('openmw_aux.util')
local settings = require("scripts.ErnBestICanDo.settings")
local async    = require("openmw.async")


local settingCache = {
    constGold = settings.main.constGold,
    mercMultGold = settings.main.mercMultGold
}
settings.main.subscribe(async:callback(function(_, key)
    settingCache[key] = settings.main[key]
end))

local function messageData(npc)
    local mercSkill = pself.type.stats.skills.mercantile(pself).modified
    return {
        npc = npc,
        player = pself,
        maxGold = settingCache.constGold + mercSkill * settingCache.mercMultGold,
    }
end

local function UiModeChanged(data)
    if data.newMode == "Barter" or data.newMode == "Dialogue" then
        core.sendGlobalEvent(MOD_NAME .. "onBarterStart", messageData(data.arg))
    elseif data.oldMode == "Barter" then
        core.sendGlobalEvent(MOD_NAME .. "onBarterEnd", messageData(data.arg))
    end
end

return {
    eventHandlers = {
        UiModeChanged = UiModeChanged
    },
}
