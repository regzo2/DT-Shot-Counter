local mod = get_mod("shot_counter")
local UISettings = require("scripts/settings/ui/ui_settings")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local PATTERNS = UISettings.weapon_patterns

mod.template_settings = {}

create_pattern_widgets = function()
    local widget_table = {}
    for _, pattern in pairs(PATTERNS) do
        for _, template in pairs(pattern.marks) do
            local id = template.name
            local weapon_template = WeaponTemplates[id]

            if not weapon_template then
                --mod:dtf(WeaponTemplates, "Templatessssss", 1)
                goto continue
            end

            local min = 1000
            local max = 0

            for __, action in pairs(weapon_template.actions) do
                if action.ammunition_usage_min and action.ammunition_usage_max then
                    if min > action.ammunition_usage_min then
                        min = action.ammunition_usage_min
                    end
                    if max < action.ammunition_usage_max then
                        max = action.ammunition_usage_max
                    end
                end
                if action.ammunition_usage then
                    if min > action.ammunition_usage then
                        min = action.ammunition_usage
                    end
                    if max < action.ammunition_usage then
                        max = action.ammunition_usage
                    end
                end
            end

            local has_ammo_range = (max - min) ~= 0 and (max - min) ~= -1000 or max > 1

            local is_ranged = false
            for _, keyword in pairs(weapon_template.keywords) do
                if keyword and keyword == "ranged" then
                    is_ranged = true
                    goto ranged_exit
                end
            end
            ::ranged_exit::

            if is_ranged and has_ammo_range then
                widget_table[#widget_table+1] =
                {
                    setting_id    = "enable_" .. id,
                    type          = "checkbox",
                    default_value = true,
                }
                if (max-min) > 0 then
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
                mod.template_settings[id] = {}
                mod.template_settings[id].setting_id = "enable_" .. id
                mod.template_settings[id].shot_type = "shot_type_" .. id
                mod.template_settings[id].min = min
                mod.template_settings[id].max = max
                mod.template_settings[id].has_ammo_range = has_ammo_range
            end
            ::continue::
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
