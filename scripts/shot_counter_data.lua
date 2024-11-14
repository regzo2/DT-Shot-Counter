local mod = get_mod("shot_counter")
local UISettings = require("scripts/settings/ui/ui_settings")
local MasterItems = require("scripts/backend/master_items")
local Weapon = require("scripts/extension_systems/weapon/weapon")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local PATTERNS = UISettings.weapon_patterns

mod.patterns = {}

create_pattern_widgets = function()
    local widget_table = {}
    for id, pattern in pairs(PATTERNS) do
        local name = pattern and pattern.marks and pattern.marks[1] and pattern.marks[1].name
        local weapon_template = WeaponTemplates[name]

        local has_min_ammo = false
        for _, action in pairs(weapon_template.actions) do
            if action.ammunition_usage_min or action.ammunition_usage and action.ammunition_usage > 1 then
                has_min_ammo = true
                goto ammo_exit
            end
        end
        ::ammo_exit::
        local is_ranged = false
        for _, keyword in pairs(weapon_template.keywords) do
            if keyword and keyword == "ranged" then
                is_ranged = true
                goto ranged_exit
            end
        end
        ::ranged_exit::
        if is_ranged and has_min_ammo then
            widget_table[#widget_table+1] =
            {
                setting_id    = "enable_" .. id,
                type          = "checkbox",
                default_value = true,
            }
            mod.patterns[id] = "enable_" .. id
        end
    end
    return widget_table
end

return 
{
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id  = "group_pattern",
                type        = "group",
                sub_widgets = create_pattern_widgets()
            },
        },
    },
}
