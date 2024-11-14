local mod = get_mod("shot_counter")
local UISettings = require("scripts/settings/ui/ui_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local PATTERNS = UISettings.weapon_patterns

mod.pattern_settings = {}

create_pattern_widgets = function()
    local widget_table = {}
    for id, pattern in pairs(PATTERNS) do
        local name = pattern and pattern.marks and pattern.marks[1] and pattern.marks[1].name
        local weapon_template = WeaponTemplates[name]

        local has_min_max_ammo = false
        local has_expensive_ammo = false
        for _, action in pairs(weapon_template.actions) do
            if action.ammunition_usage_min and action.ammunition_usage_max then
                has_min_max_ammo = true
                has_expensive_ammo = true
                goto ammo_exit
            end
            if action.ammunition_usage and action.ammunition_usage > 1 then
                has_expensive_ammo = true
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

        if is_ranged and has_expensive_ammo then
            widget_table[#widget_table+1] =
            {
                setting_id    = "enable_" .. id,
                type          = "checkbox",
                default_value = true,
            }
            if has_min_max_ammo then
            widget_table[#widget_table+1] = 
                {
                    setting_id = "shot_type_" .. id,
                    type = "dropdown",
                    default_value = "dynamic",
                    options = {
                        { text = "base_dynamic_ammo", value = "dynamic" },
                        { text = "base_max_ammo", value = "min" },
                        { text = "base_min_ammo", value = "max" },
                    },
                }
            end
            mod.pattern_settings[id] = {}
            mod.pattern_settings[id].setting_id = "enable_" .. id
            mod.pattern_settings[id].shot_type = "shot_type_" .. id
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
