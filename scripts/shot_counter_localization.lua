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

for id, pattern in pairs(PATTERNS) do
    loc["enable_" .. id] = {}
    loc["enable_" .. id][Managers.localization._language] = Localize(pattern.display_name)
    loc["shot_type_" .. id] = {}
    for lang, localized in pairs(loc.base_shot_type) do
        loc["shot_type_" .. id][lang] = localized
    end
end

return loc