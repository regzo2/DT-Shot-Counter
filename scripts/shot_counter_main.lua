mod = get_mod("shot_counter")
local WeaponTemplate = require("scripts/utilities/weapon/weapon_template")
local WeaponStats = require("scripts/utilities/weapon_stats")
local Weapon = require("scripts/extension_systems/weapon/weapon")

local PenanceSniffer = {}
local enabled_patterns = {}

mod.on_setting_changed = function()
    for id, setting_id in pairs(mod.patterns) do
        enabled_patterns[id] = mod:get(setting_id)
    end
end

mod.on_setting_changed()

local ammo_store = {}

mod:hook("HudElementPlayerWeapon", "_set_clip_amount", function(func, element, current, total_max_amount, ...) 
    local item = element._data.item
    if item and element._ability_type then
        func(element, current, total_max_amount, ...)
        return
    end
    if item.parent_pattern and not enabled_patterns[item.parent_pattern] then
        func(element, current, total_max_amount, ...)
        return
    end
    local slot_component = element._slot_component
    if not slot_component then
        func(element, current, total_max_amount, ...)
        return
    end
    local data = slot_component.__data[1]
    if not data then
        func(element, current, total_max_amount, ...)
        return
    end
    local clip = data.current_ammunition_clip
    if not clip then
        func(element, current, total_max_amount, ...)
        return
    end

    local reserve = data.current_ammunition_reserve
    local reserve_max = data.max_ammunition_reserve

    if not ammo_store[item.name] then
        ammo_store[item.name] = {}
    end
 
    local previous_clip = ammo_store[item.name].clip or clip
    local ammo_cost = math.abs(previous_clip - clip) or 1

    if ammo_cost > 0 and ammo_cost < 15 then
        ammo_store[item.name].cost = ammo_cost
    end
    local prev_cost = ammo_store[item.name] and ammo_store[item.name].cost or 1
    func(element, math.floor(current/prev_cost) or current, total_max_amount, ...)
    ammo_store[item.name].clip = clip
end)

mod:hook("HudElementPlayerWeapon", "_set_ammo_amount", function(func, element, amount, total, ...) 
    local item = element._data.item
    if item and item.parent_pattern and not enabled_patterns[item.parent_pattern] then
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
