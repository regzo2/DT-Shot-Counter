mod = get_mod("shot_counter")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local UISettings = require("scripts/settings/ui/ui_settings")

local PenanceSniffer = {}
local templates = {}

mod.on_setting_changed = function()
    for id, setting in pairs(mod.template_settings) do
        templates[id] = {}
        templates[id].enabled = mod:get(setting.setting_id)
        templates[id].min_ammo = setting.min
        templates[id].max_ammo = setting.max
        local shot_type = mod:get(setting.shot_type)
        if shot_type then
            templates[id].shot_type = shot_type
        else 
            templates[id].shot_type = "min"
        end
    end
end

mod.on_setting_changed()

local ammo_store = {}

mod:hook("HudElementPlayerWeapon", "_set_clip_amount", function(func, element, current, total_max_amount, ...) 
    local item = element._data.item
    local template = item and item.__master_item and item.__master_item.weapon_template

    if not item or element._ability_type or not templates[template] or not templates[template].enabled then
        return func(element, current, total_max_amount, ...)
    end

    ammo_store[item.name] = ammo_store[item.name] or {}
    local ammo_cost = templates[template].shot_type == "max" and templates[template].min_ammo or templates[template].max_ammo
    local clip_data = element._slot_component and element._slot_component.__data[1]

    if templates[template].shot_type == "dynamic" and clip_data then
        local clip = clip_data.current_ammunition_clip
        if clip then
            local previous_clip = ammo_store[item.name].previous_clip
            ammo_cost = previous_clip and previous_clip - clip or templates[template].min_ammo
            ammo_store[item.name].previous_clip = clip 
        end
    end

    if ammo_cost and ammo_cost > 0 and ammo_cost < 15 then
        ammo_store[item.name].cost = ammo_cost
    end

    func(element, math.floor(current / (ammo_store[item.name].cost or 1)), total_max_amount, ...)
end)

mod:hook("HudElementPlayerWeapon", "_set_ammo_amount", function(func, element, amount, total, ...) 
    local item = element._data.item
    local template = item and item.__master_item and item.__master_item.weapon_template
    if not item or item and template and templates[template] and not templates[template].enabled then
        func(element, amount, total, ...)
        return
    end
    local ammo_cost = ammo_store[item.name] and ammo_store[item.name].cost or 1
    if not amount or not total then
        func(element, amount, total)
        return
    end
    func(element, math.floor(amount/ammo_cost) or amount, math.floor(total/ammo_cost) or total)
end)
