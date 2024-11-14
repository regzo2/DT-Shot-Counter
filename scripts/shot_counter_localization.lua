local mod = get_mod("shot_counter")

local UISettings = require("scripts/settings/ui/ui_settings")
local MasterItems = require("scripts/backend/master_items")
local Weapon = require("scripts/extension_systems/weapon/weapon")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local LocalizationManager = require("scripts/managers/localization/localization_manager")
local PATTERNS = UISettings.weapon_patterns

local loc = {
    mod_name = {
        en = "Shot Counter",
    },
    mod_description = {
        en = "Shows the shots left on a weapon that uses more than one ammo per shot.",
    },
    group_pattern = {
        en = "Weapon Patterns"
    }
}

for id, pattern in pairs(PATTERNS) do
    loc["enable_" .. id] = {}
    loc["enable_" .. id][Managers.localization._language] = Localize(pattern.display_name)
end

return loc