-- UC.open_collection_menu(card_type, filter_func)
-- Opens a paginated collection browser for the given card type.
-- card_type: "Joker"|"Tarot"|"Planet"|"Spectral"|"Voucher"|"Booster Pack"|"Tag"|"BlackHole"
-- filter_func: optional function(center) -> bool; only matching cards are shown
--              (ignored for "BlackHole", which builds its own filtered pool)
--
-- "BlackHole" pool: filtered planets + vanilla c_black_hole at the end.
-- Selecting a planet levels that hand type N times (N = planet count in pool).
-- Selecting vanilla Black Hole levels every hand by 1.

-- Schedules removal of the price tag UIBox for cards that are free.
-- Must run after create_shop_card_ui's 0.43s event.
local function remove_price_tag(card)
    G.E_MANAGER:add_event(Event({
        trigger = 'after', delay = 0.5, blocking = false, blockable = false,
        func = function()
            if card.removed then return true end
            if card.children.price then
                card.children.price:remove()
                card.children.price = nil
            end
            return true
        end,
    }))
end

local CONFIGS = {
    Joker = {
        pool_key = 'Joker',
        rows = {5},
        args = {
            h_mod = 0.95,
            no_materialize = true,
            modify_card = function(card, center)
                card.sticker = get_joker_win_sticker(center)
                card._uc_collection = true
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        },
    },
    Tarot = {
        pool_key = 'Tarot',
        rows = {5, 6},
        args = {
            modify_card = function(card, center)
                card._uc_collection = true
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        },
    },
    Planet = {
        pool_key = 'Planet',
        rows = {6, 6},
        args = {
            modify_card = function(card, center)
                card._uc_collection = true
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        },
    },
    Spectral = {
        pool_key = 'Spectral',
        rows = {4, 5},
        args = {
            modify_card = function(card, center)
                card._uc_collection = true
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        },
    },
    Voucher = {
        pool_key = 'Voucher',
        rows = {4, 4},
        args = {
            area_type = 'voucher',
            modify_card = function(card, center, i, j)
                card.ability.order = i + (j - 1) * 4
                card._uc_collection = true
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        },
    },
    ['Booster Pack'] = {
        pool_key = 'Booster',
        rows = {4, 4},
        args = {
            h_mod = 1.3,
            w_mod = 1.25,
            card_scale = 1.27,
            modify_card = function(card, center)
                card._uc_collection = true
                card:set_cost()
                create_shop_card_ui(card)
            end,
        },
    },
}

local TAG_COLS = 6

local function apply_filter(base_pool, filter_func)
    if not filter_func then return base_pool end
    local result = {}
    for _, v in ipairs(base_pool) do
        if filter_func(v) then result[#result + 1] = v end
    end
    return result
end

local function build_tag_collection(filter_func)
    local tag_pool = {}
    for _, v in pairs(G.P_TAGS) do
        local mod_ok = not G.ACTIVE_MOD_UI or (v.mod and v.mod.id == G.ACTIVE_MOD_UI.id)
        if not v.no_collection and mod_ok and (not filter_func or filter_func(v)) then
            tag_pool[#tag_pool + 1] = v
        end
    end
    table.sort(tag_pool, function(a, b) return a.order < b.order end)

    local num_rows = math.max(1, math.ceil(#tag_pool / TAG_COLS))
    local tag_matrix = {}
    for i = 1, num_rows do tag_matrix[i] = {} end

    local to_alert = {}
    for k, v in ipairs(tag_pool) do
        local temp_tag = Tag(v.key, true)
        if not v.discovered then temp_tag.hide_ability = true end
        local tag_ui, tag_sprite = temp_tag:generate_UI()
        local row = math.ceil((k - 1) / TAG_COLS + 0.001)
        local col = 1 + ((k - 1) % TAG_COLS)
        tag_matrix[row][col] = {n = G.UIT.C, config = {align = "cm", padding = 0.1}, nodes = {tag_ui}}
        if v.discovered and not v.alerted then
            to_alert[#to_alert + 1] = tag_sprite
        end
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            for _, sprite in ipairs(to_alert) do
                sprite.children.alert = UIBox{
                    definition = create_UIBox_card_alert(),
                    config = {align = "tri", offset = {x = 0.1, y = 0.1}, parent = sprite},
                }
                sprite.children.alert.states.collide.can = false
            end
            return true
        end,
    }))

    local row_nodes = {}
    for i = 1, num_rows do
        row_nodes[#row_nodes + 1] = {n = G.UIT.R, config = {align = "cm"}, nodes = tag_matrix[i]}
    end

    return create_UIBox_generic_options({
        back_func = 'exit_overlay_menu',
        contents = {
            {n = G.UIT.C, config = {align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05}, nodes = {
                {n = G.UIT.C, config = {align = "cm"}, nodes = {
                    {n = G.UIT.R, config = {align = "cm"}, nodes = row_nodes},
                }},
            }},
        },
    })
end

function UC.open_collection_menu(card_type, filter_func)
    assert(type(card_type) == 'string', "UC.open_collection_menu: card_type must be a string")

    if card_type == 'Tag' then
        G.FUNCS.overlay_menu{definition = build_tag_collection(filter_func)}
        return
    end

    if card_type == 'BlackHole' then
        local planet_filter = UC.pool_count.filter_consumables('Planet')
        local planets = apply_filter(G.P_CENTER_POOLS['Planet'], planet_filter)
        local planet_count = #planets

        local pool = {}
        for _, c in ipairs(planets) do pool[#pool+1] = c end
        local bh = G.P_CENTERS['c_black_hole']
        if bh then pool[#pool+1] = bh end

        local args = {
            back_func = 'exit_overlay_menu',
            modify_card = function(card, center)
                card._uc_collection      = true
                card._uc_bh_select       = true
                card._uc_bh_planet_count = planet_count
                card.cost = 0
                create_shop_card_ui(card)
                remove_price_tag(card)
            end,
        }

        local rows = {6, 6}

        local prev_overlay = G.OVERLAY_MENU
        G.OVERLAY_MENU = prev_overlay or true
        local definition = SMODS.card_collection_UIBox(pool, rows, args)
        G.OVERLAY_MENU = prev_overlay

        if G.your_collection then
            for _, area in pairs(G.your_collection) do
                area._uc_collection = true
            end
        end

        G.FUNCS.overlay_menu{definition = definition}
        return
    end

    local config = CONFIGS[card_type]
    assert(config, "UC.open_collection_menu: unknown card_type '" .. card_type .. "'")

    local pool = apply_filter(G.P_CENTER_POOLS[config.pool_key], filter_func)

    -- shallow-copy args and rows so SMODS.card_collection_UIBox can't mutate config state
    local args = {}
    for k, v in pairs(config.args or {}) do args[k] = v end
    args.back_func = args.back_func or 'exit_overlay_menu'

    local rows = {}
    for i, v in ipairs(config.rows) do rows[i] = v end

    -- Set overlay flag before building the UIBox so collection display cards don't
    -- populate G.GAME.used_jokers (card.lua only skips that update when G.OVERLAY_MENU is truthy,
    -- but the UIBox argument is evaluated before overlay_menu sets the flag).
    local prev_overlay = G.OVERLAY_MENU
    G.OVERLAY_MENU = prev_overlay or true
    local definition = SMODS.card_collection_UIBox(pool, rows, args)
    G.OVERLAY_MENU = prev_overlay

    -- Tag the CardAreas so our can_highlight/add_to_highlighted hooks enable click-to-highlight
    if G.your_collection then
        for _, area in pairs(G.your_collection) do
            area._uc_collection = true
        end
    end

    G.FUNCS.overlay_menu{definition = definition}
end

