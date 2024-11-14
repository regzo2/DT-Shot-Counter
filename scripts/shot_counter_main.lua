mod = get_mod("shot_counter")
local WeaponTemplates = require("scripts/settings/equipment/weapon_templates/weapon_templates")
local UISettings = require("scripts/settings/ui/ui_settings")
local PATTERNS = UISettings.weapon_patterns

local PenanceSniffer = {}
local patterns = {}

mod.on_setting_changed = function()
    for id, setting in pairs(mod.pattern_settings) do
        patterns[id] = {}
        patterns[id].enabled = mod:get(setting.setting_id)
        local shot_type = mod:get(setting.shot_type)
        if shot_type then
            patterns[id].shot_type = shot_type
        else 
            patterns[id].shot_type = "min"
        end
    end

    for id, pattern in pairs(PATTERNS) do
        local name = pattern and pattern.marks and pattern.marks[1] and pattern.marks[1].name
        local weapon_template = WeaponTemplates[name]
        for __, action in pairs(weapon_template.actions) do

            if not patterns[id] then
                goto continue
            end

            if not patterns[id].min_ammo then
                patterns[id].min_ammo = 1000
            end

            if not patterns[id].max_ammo then
                patterns[id].max_ammo = 0
            end

            if action.ammunition_usage_min and action.ammunition_usage_max then
                if patterns[id].min_ammo > action.ammunition_usage_min then
                    patterns[id].min_ammo = action.ammunition_usage_min
                end
                if patterns[id].max_ammo < action.ammunition_usage_max then
                    patterns[id].max_ammo = action.ammunition_usage_max
                end
            end
            if action.ammunition_usage then
                if patterns[id].min_ammo > action.ammunition_usage then
                    patterns[id].min_ammo = action.ammunition_usage
                end
                if patterns[id].max_ammo < action.ammunition_usage then
                    patterns[id].max_ammo = action.ammunition_usage
                end
            end
            
            ::continue::
        end
    end
end

mod.on_setting_changed()

local ammo_store = {}

local count = 0

mod:hook("HudElementPlayerWeapon", "_set_clip_amount", function(func, element, current, total_max_amount, ...) 
    local item = element._data.item
    if item and element._ability_type then
        func(element, current, total_max_amount, ...)
        return
    end
    local pattern = item.parent_pattern
    if pattern and not patterns[pattern] then
        func(element, current, total_max_amount, ...)
        return
    end
    local ammo_cost = patterns[pattern].min_ammo
    if not ammo_store[item.name] then
        ammo_store[item.name] = {}
    end
    if patterns[pattern].shot_type == "dynamic" then
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
        ammo_store[item.name].clip = data.current_ammunition_clip
        if not ammo_store[item.name].clip then
            func(element, current, total_max_amount, ...)
            return
        end

        local clip = ammo_store[item.name].clip
        if ammo_store[item.name].previous_clip then
            local previous_clip = ammo_store[item.name].previous_clip
            ammo_cost = math.abs(previous_clip - clip) or 1 
        end    
    elseif patterns[pattern].shot_type == "min" then
        mod:echo("MAX: " .. patterns[pattern].max_ammo)
        ammo_cost = patterns[pattern].max_ammo
    end

    if ammo_cost and ammo_cost > 0 and ammo_cost < 15 then
        mod:echo(ammo_cost .. " " .. count)
        count = count+1   
        ammo_store[item.name].cost = ammo_cost
    end
    local prev_cost = ammo_store[item.name] and ammo_store[item.name].cost or 1
    if patterns[pattern].shot_type == "dynamic" then
        ammo_store[item.name].previous_clip = ammo_store[item.name].clip
    end
    func(element, math.floor(current/prev_cost) or current, total_max_amount, ...)
end)

mod:hook("HudElementPlayerWeapon", "_set_ammo_amount", function(func, element, amount, total, ...) 
    local item = element._data.item
    if item and item.parent_pattern and not patterns[item.parent_pattern] then
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
