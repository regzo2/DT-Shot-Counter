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
        en = "Scales ammo counters based on the amount of ammo per shot.",
    },
    group_pattern = {
        en = "Weapon Patterns"
    },
    base_shot_type = {
        en = ""
    },
    base_min_ammo = {
        en = "Minimum Shot Count"
    },
    base_max_ammo = {
        en = "Maximum Shot Count"
    },
    base_dynamic_ammo = {
        en = "Dynamic Shot Count"
    },
}

for _, pattern in pairs(PATTERNS) do
    for _, mark in pairs(pattern.marks) do
        local id = mark.name
        loc["enable_" .. id] = {}
        loc["enable_" .. id][Managers.localization._language] = Localize("loc_weapon_family_" .. mark.name) .. " " .. Localize("loc_weapon_mark_" .. mark.name)
        loc["shot_type_" .. id] = {}
        for lang, localized in pairs(loc.base_shot_type) do
            loc["shot_type_" .. id][lang] = localized
        end
    end
end

return loc