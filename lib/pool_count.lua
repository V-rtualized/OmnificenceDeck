local function in_run()
    return type(G.GAME.used_jokers) == 'table' and type(G.playing_cards) == 'table'
end

local function is_od(v)
    return v.mod and v.mod.id == 'OmnificenceDeck'
end

local function filter_od(pool)
    local result = {}
    for _, k in ipairs(pool) do
        local center = G.P_CENTERS[k] or (G.P_TAGS and G.P_TAGS[k])
        if not center or not is_od(center) then
            result[#result+1] = k
        end
    end
    return result
end

local M = {}

function M.jokers(rarity)
    if in_run() then
        if rarity == 4 then
            return #filter_od(SMODS.get_clean_pool('Joker', nil, true))
        elseif rarity == 1 then
            return #filter_od(SMODS.get_clean_pool('Joker', 'Common'))
        elseif rarity == 2 then
            return #filter_od(SMODS.get_clean_pool('Joker', 'Uncommon'))
        elseif rarity == 3 then
            return #filter_od(SMODS.get_clean_pool('Joker', 'Rare'))
        else
            return #filter_od(SMODS.get_clean_pool('Joker', 'Common'))
                 + #filter_od(SMODS.get_clean_pool('Joker', 'Uncommon'))
                 + #filter_od(SMODS.get_clean_pool('Joker', 'Rare'))
        end
    end
    local n = 0
    for _, v in pairs(G.P_CENTERS) do
        if v.set == 'Joker' and not v.hidden and not is_od(v) then
            if rarity == nil then
                if v.rarity ~= 4 then n = n + 1 end
            elseif v.rarity == rarity then
                n = n + 1
            end
        end
    end
    return n
end

function M.consumables(set)
    if in_run() then
        return #filter_od(SMODS.get_clean_pool(set))
    end
    local n = 0
    for _, v in pairs(G.P_CENTERS) do
        if v.set == set and not v.hidden and not is_od(v) then n = n + 1 end
    end
    return n
end

function M.vouchers()
    if in_run() then
        return #filter_od(SMODS.get_clean_pool('Voucher'))
    end
    local n = 0
    for _, v in pairs(G.P_CENTERS) do
        if v.set == 'Voucher' and not is_od(v) then n = n + 1 end
    end
    return n
end

function M.boosters()
    if in_run() then
        return #filter_od(SMODS.get_clean_pool('Booster'))
    end
    local n = 0
    for _, v in pairs(G.P_CENTERS) do
        if v.set == 'Booster' and not is_od(v) then n = n + 1 end
    end
    return n
end

function M.tags()
    local ante = in_run() and G.GAME.round_resets.ante or nil
    local n = 0
    for _, t in pairs(G.P_TAGS or {}) do
        if not is_od(t) and not t.no_collection
        and not (ante and t.min_ante and t.min_ante > ante) then
            n = n + 1
        end
    end
    return n
end

function M.backs()
    local n = 0
    for _, v in pairs(G.P_CENTERS) do
        if v.set == 'Back' and not is_od(v) then n = n + 1 end
    end
    return n
end

-- Filter functions — return a predicate (center -> bool) using the same pool logic as the count functions above

local RARITY_NAMES = { [1] = 'Common', [2] = 'Uncommon', [3] = 'Rare' }

local function pool_key_set(pool)
    local s = {}
    for _, k in ipairs(pool) do s[k] = true end
    return s
end

function M.filter_jokers(rarity)
    if in_run() then
        if rarity == nil then
            local keys = {}
            for r = 1, 3 do
                for _, k in ipairs(filter_od(SMODS.get_clean_pool('Joker', RARITY_NAMES[r]))) do
                    keys[k] = true
                end
            end
            return function(center) return keys[center.key] end
        end
        local rarity_name = RARITY_NAMES[rarity]
        local legendary = rarity == 4 and true or nil
        local keys = pool_key_set(filter_od(SMODS.get_clean_pool('Joker', rarity_name, legendary)))
        return function(center) return keys[center.key] end
    end
    return function(center)
        if center.set ~= 'Joker' or center.hidden or is_od(center) then return false end
        if rarity == nil then return center.rarity ~= 4 end
        return center.rarity == rarity
    end
end

function M.filter_consumables(set)
    if in_run() then
        local keys = pool_key_set(filter_od(SMODS.get_clean_pool(set)))
        return function(center) return keys[center.key] end
    end
    return function(center)
        return center.set == set and not center.hidden and not is_od(center)
    end
end

function M.filter_vouchers()
    if in_run() then
        local keys = pool_key_set(filter_od(SMODS.get_clean_pool('Voucher')))
        return function(center) return keys[center.key] end
    end
    return function(center)
        return center.set == 'Voucher' and not is_od(center)
    end
end

function M.filter_boosters()
    if in_run() then
        local keys = pool_key_set(filter_od(SMODS.get_clean_pool('Booster')))
        return function(center) return keys[center.key] end
    end
    return function(center)
        return center.set == 'Booster' and not is_od(center)
    end
end

function M.filter_tags()
    local ante = in_run() and G.GAME.round_resets.ante or nil
    return function(tag)
        if is_od(tag) or tag.no_collection then return false end
        if ante and tag.min_ante and tag.min_ante > ante then return false end
        return true
    end
end

return M
