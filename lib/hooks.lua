-- Resolved at load time so the prefixed G.ASSET_ATLAS key is available at runtime
local _pc_atlas_key = (SMODS.current_mod and SMODS.current_mod.prefix or 'omnificence') .. '_playing_card'

-- Maps card set types to their OD replacement keys
local OD_CARD_MAP = {
    Joker    = 'j_omnificence_joker',
    Tarot    = 'c_omnificence_tarot',
    Planet   = 'c_omnificence_planet',
    Spectral = 'c_omnificence_spectral',
}

-- Maps vanilla tag key_append sources to rarity-specific joker essence keys
local JOKER_ESSENCE_BY_SOURCE = {
    uta = 'j_omnificence_joker_uncommon',
    rta = 'j_omnificence_joker_rare',
}

local function od_active()
    return G.GAME and G.GAME.modifiers and G.GAME.modifiers.omnificence
end

-- Mark Base/Enhanced playing cards in packs/shop as suit/rank choices.
-- The card keeps its natural appearance (enhancement, edition, seal visible);
-- use_card intercepts it so the player picks suit and rank before it goes to deck.
local orig_SMODS_create_card = SMODS.create_card
function SMODS.create_card(t)
    if od_active() and (t.area == G.pack_cards or t.area == G.shop_jokers)
        and (t.set == 'Base' or t.set == 'Enhanced') then
        local _card = orig_SMODS_create_card(t)
        _card._od_pc_choice = true
        -- Replace the random suit/rank face with the placeholder image
        local pc_atlas = G.ASSET_ATLAS[_pc_atlas_key]
        if pc_atlas and _card.children and _card.children.front then
            _card.children.front.atlas = pc_atlas
            _card.children.front:set_sprite_pos({x = 0, y = 0})
        end
        return _card
    end
    return orig_SMODS_create_card(t)
end

-- Mirror vanilla's soul-spawn probability checks so the RNG sequence is preserved.
-- We consume the same pseudorandom values that vanilla would, then pass a forced_key
-- into orig_create_card so vanilla's own check is skipped (guarded by not forced_key).
local function check_soul_spawn(_type, soulable)
    if not soulable then return nil end
    local od_key = nil
    if (_type == 'Tarot' or _type == 'Spectral' or _type == 'Tarot_Planet') and
        not (G.GAME.used_jokers['c_omnificence_soul'] and not SMODS.showman('c_omnificence_soul')) then
        if pseudorandom('soul_'..(_type)..G.GAME.round_resets.ante) > 0.997 then
            od_key = 'c_omnificence_soul'
        end
    end
    if (_type == 'Planet' or _type == 'Spectral') and
        not (G.GAME.used_jokers['c_omnificence_black_hole'] and not SMODS.showman('c_omnificence_black_hole')) then
        if pseudorandom('soul_'..(_type)..G.GAME.round_resets.ante) > 0.997 then
            od_key = 'c_omnificence_black_hole'
        end
    end
    return od_key
end

-- Replace jokers/consumables in shop slots and pack openings
local orig_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if area and not forced_key and od_active() and (area == G.shop_jokers or area == G.pack_cards) then
        local od_key = check_soul_spawn(_type, soulable)
        if not od_key then
            if _type == 'Joker' then
                od_key = JOKER_ESSENCE_BY_SOURCE[key_append] or OD_CARD_MAP['Joker']
            else
                od_key = OD_CARD_MAP[_type]
            end
        end
        if od_key then
            return orig_create_card(_type, area, legendary, _rarity, skip_materialize, false, od_key, key_append)
        end
    end
    return orig_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

-- Replace shop booster packs with OD booster
local orig_get_pack = get_pack
function get_pack(_key, _type)
    if _key == 'shop_pack' and od_active() then
        return G.P_CENTERS['p_omnificence_booster']
    end
    return orig_get_pack(_key, _type)
end

-- Replace blind-skip tags with OD tag essence
local orig_get_next_tag_key = get_next_tag_key
function get_next_tag_key(append)
    if od_active() and not G.FORCE_TAG then
        return 'tag_omnificence_tag'
    end
    return orig_get_next_tag_key(append)
end

-- Replace shop voucher with OD voucher
local orig_add_voucher_to_shop = SMODS.add_voucher_to_shop
function SMODS.add_voucher_to_shop(key, dont_save)
    if od_active() then
        return orig_add_voucher_to_shop('v_omnificence_voucher', dont_save)
    end
    return orig_add_voucher_to_shop(key, dont_save)
end

-- Force cost = 0 for OD placeholder joker and booster (shown as '??')
local orig_Card_set_cost = Card.set_cost
function Card:set_cost()
    orig_Card_set_cost(self)
    local ck = self.config and self.config.center_key
    if od_active() and (ck == 'j_omnificence_joker' or ck == 'p_omnificence_booster') then
        self.cost = 0
    end
end

-- Replace the price tag with '??' for OD placeholder joker and booster
local orig_create_shop_card_ui = create_shop_card_ui
function create_shop_card_ui(card, _type, area)
    orig_create_shop_card_ui(card, _type, area)
    local ck = card.config and card.config.center_key
    if not od_active() or (ck ~= 'j_omnificence_joker' and ck ~= 'p_omnificence_booster') then return end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.5,
        blocking = false,
        blockable = false,
        func = function()
            if card.removed then return true end
            if card.children.price then
                card.children.price:remove()
                card.children.price = UIBox{
                    definition = {
                        n = G.UIT.ROOT,
                        config = {minw = 0.6, align = 'tm', colour = darken(G.C.BLACK, 0.2), shadow = true, r = 0.05, padding = 0.05, minh = 1},
                        nodes = {{
                            n = G.UIT.R,
                            config = {align = "cm", colour = lighten(G.C.BLACK, 0.1), r = 0.1, minw = 1, minh = 0.55, emboss = 0.05, padding = 0.03},
                            nodes = {{n = G.UIT.T, config = {text = "??", colour = G.C.MONEY, shadow = true, scale = 0.5}}},
                        }},
                    },
                    config = {
                        align = "tm",
                        offset = {x = 0, y = card.ability.set == 'Booster' and 0.5 or 0.38},
                        major = card,
                        bond = 'Weak',
                        parent = card,
                    }
                }
            end
            return true
        end,
    }))
end

-- Clear pack-inject flag if the overlay is dismissed without a selection
local orig_exit_overlay_menu = G.FUNCS.exit_overlay_menu
G.FUNCS.exit_overlay_menu = function(e)
    OD._pack_inject = nil
    return orig_exit_overlay_menu(e)
end

-- Omnificence stake is always selectable regardless of deck win history;
-- all stakes are always selectable when the Omnificence deck is selected.
local orig_check_applied_stakes = SMODS.check_applied_stakes
function SMODS.check_applied_stakes(stake, deck)
    if stake and stake.key == 'stake_omnificence_omnificence' then return true end
    if G.GAME and G.GAME.viewed_back
        and G.GAME.viewed_back.effect
        and G.GAME.viewed_back.effect.center
        and G.GAME.viewed_back.effect.center.key == 'b_omnificence_omnificence' then
        return true
    end
    return orig_check_applied_stakes(stake, deck)
end

-- Allow collection CardAreas to support click-to-highlight (one card at a time)
local orig_can_highlight = CardArea.can_highlight
function CardArea:can_highlight(card)
    if self._od_collection then return true end
    return orig_can_highlight(self, card)
end

local orig_add_to_highlighted = CardArea.add_to_highlighted
function CardArea:add_to_highlighted(card, silent)
    if not self._od_collection then
        return orig_add_to_highlighted(self, card, silent)
    end
    -- Limit 1: evict previous highlight before adding new one
    if self.highlighted[1] then
        self:remove_from_highlighted(self.highlighted[1])
    end
    self.highlighted[1] = card
    -- Direct set instead of card:highlight(true) to avoid creating use_button on jokers/consumables
    card.highlighted = true
    if not silent then play_sound('cardSlide1') end
end

G.FUNCS.od_select_tag = function(e)
    local tag_key = e.config.ref_table.key
    G.E_MANAGER:add_event(Event({func = function()
        G.FUNCS.exit_overlay_menu()
        return true
    end}))
    G.E_MANAGER:add_event(Event({func = function()
        add_tag(Tag(tag_key))
        return true
    end}))
    G.E_MANAGER:add_event(Event({func = function()
        for i = 1, #G.GAME.tags do
            G.GAME.tags[i]:apply_to_run({type = 'immediate'})
        end
        for i = 1, #G.GAME.tags do
            if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
        end
        return true
    end}))
end

-- Buy handler for collection jokers and consumables.
-- Creates a fresh card in the game area instead of moving the overlay card,
-- which avoids position/animation issues with overlay-origin cards.
local orig_buy_from_shop = G.FUNCS.buy_from_shop
G.FUNCS.buy_from_shop = function(e)
    local card = e.config.ref_table

    -- Playing card with suit/rank choice pending (purchased from shop)
    if card and card._od_pc_choice then
        local cost = card.cost or 0
        if cost > 0 then
            ease_dollars(-cost)
            inc_career_stat('c_shop_dollars_spent', cost)
        end
        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
        local from_area = card.area
        if from_area then from_area:remove_card(card) end
        OD._playing_card_selection = {
            center_key = card.config.center_key,
            edition    = card.edition,
            seal       = card.seal,
            from_pack  = false,
        }
        G.E_MANAGER:add_event(Event({func = function()
            card:start_dissolve()
            OD.open_collection_menu('PlayingCardSuit')
            return true
        end}))
        return
    end

    if not (card and card._od_collection) then
        return orig_buy_from_shop(e)
    end

    if card._od_pc_suit_select then
        local suit = card._od_pc_suit_select
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.exit_overlay_menu()
            return true
        end}))
        G.E_MANAGER:add_event(Event({func = function()
            OD._playing_card_selection = OD._playing_card_selection or {}
            OD._playing_card_selection.suit = suit
            OD.open_collection_menu('PlayingCardRank')
            return true
        end}))
        return
    end

    if card._od_pc_rank_select then
        local rank      = card._od_pc_rank_select
        local sel       = OD._playing_card_selection or {}
        local front_key = (sel.suit or 'S') .. '_' .. rank
        local from_pack = sel.from_pack
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.exit_overlay_menu()
            return true
        end}))
        G.E_MANAGER:add_event(Event({func = function()
            local front  = G.P_CARDS[front_key]
            local center = G.P_CENTERS[sel.center_key or 'c_base']
            local nc = Card(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W, G.CARD_H, front, center)
            if sel.edition and next(sel.edition) then nc:set_edition(sel.edition) end
            if sel.seal then nc:set_seal(sel.seal); nc.ability.delay_seal = false end
            G.playing_card = (G.playing_card or 0) + 1
            nc.playing_card = G.playing_card
            table.insert(G.playing_cards, nc)
            nc:add_to_deck()
            G.deck:emplace(nc)
            play_sound('card1', 0.8, 0.6)
            play_sound('generic1')
            OD._playing_card_selection = nil
            -- Mirror vanilla pack_choices decrement / pack close logic
            if from_pack then
                if G.GAME.pack_choices and G.GAME.pack_choices > 1 then
                    if G.booster_pack and G.booster_pack.alignment.offset.py then
                        G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                        G.booster_pack.alignment.offset.py = nil
                    end
                    G.GAME.pack_choices = G.GAME.pack_choices - 1
                else
                    G.CONTROLLER.interrupt.focus = true
                    G.FUNCS.end_consumeable(nil, 0.2)
                end
            end
            return true
        end}))
        return
    end

    if card._od_bh_select then
        local center       = card.config.center
        local planet_count = card._od_bh_planet_count or 1
        G.E_MANAGER:add_event(Event({func = function()
            G.FUNCS.exit_overlay_menu()
            return true
        end}))
        G.E_MANAGER:add_event(Event({func = function()
            local temp = Card(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
            if center.set == 'Planet' then
                local hand_type = center.config and center.config.hand_type
                if hand_type and planet_count > 0 then
                    level_up_hand(temp, hand_type, false, planet_count)
                end
            elseif center.key == 'c_black_hole' then
                for k in pairs(G.GAME.hands) do
                    level_up_hand(temp, k, true)
                end
            end
            temp:remove()
            return true
        end}))
        return
    end

    local center_key = card.config.center_key
    local set        = card.ability.set
    local cost       = card.cost or 0
    local sticker    = card.sticker

    -- Capture and clear the flag synchronously so exit_overlay_menu (queued below)
    -- doesn't wipe it before the card-creation event fires.
    local should_inject = OD._pack_inject
        and (set == 'Tarot' or set == 'Planet' or set == 'Spectral')
        and G.pack_cards
    OD._pack_inject = nil

    if cost > 0 then
        ease_dollars(-cost)
        inc_career_stat('c_shop_dollars_spent', cost)
    end
    G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
    if set == 'Joker' then
        G.GAME.current_round.jokers_purchased = G.GAME.current_round.jokers_purchased + 1
    elseif card.config.center.set == 'Planet' then
        inc_career_stat('c_planets_bought', 1)
    elseif card.config.center.set == 'Tarot' then
        inc_career_stat('c_tarots_bought', 1)
    end
    if not card.config.center.discovered then discover_card(card.config.center) end

    G.E_MANAGER:add_event(Event({func = function()
        G.FUNCS.exit_overlay_menu()
        return true
    end}))
    G.E_MANAGER:add_event(Event({func = function()
        if should_inject then
            local nc = create_card(set, G.pack_cards, nil, nil, nil, nil, center_key)
            if sticker then nc.sticker = sticker end
            G.pack_cards:emplace(nc)
            play_sound('card1', 0.8, 0.6)
            play_sound('generic1')
        else
            local target = set == 'Joker' and G.jokers or G.consumeables
            local nc = create_card(set, target, nil, nil, nil, nil, center_key)
            if set == 'Joker' then
                local ess_ed = OD._joker_essence_edition
                OD._joker_essence_edition = nil
                if ess_ed and next(ess_ed) then nc:set_edition(ess_ed) end
            end
            if sticker then nc.sticker = sticker end
            nc:add_to_deck()
            target:emplace(nc)
            play_sound('card1', 0.8, 0.6)
            play_sound('generic1')
            local eval, post = eval_card(nc, {buying_card = true, buying_self = true, card = nc})
            SMODS.trigger_effects({eval, post}, nc)
            SMODS.calculate_context({buying_card = true, card = nc})
            if G.GAME.modifiers.inflation then
                G.GAME.inflation = G.GAME.inflation + 1
                G.E_MANAGER:add_event(Event({func = function()
                    for _, v in pairs(G.I.CARD) do if v.set_cost then v:set_cost() end end
                    return true
                end}))
            end
            G.CONTROLLER:save_cardarea_focus(set == 'Joker' and 'jokers' or 'consumeables')
            G.CONTROLLER:recall_cardarea_focus(set == 'Joker' and 'jokers' or 'consumeables')
        end
        return true
    end}))
end

-- Intercept use/open/redeem for all OD cards before use_card changes any game state.
-- j_omnificence_joker from the shop goes through buy_from_shop → buying_self → calculate instead,
-- but we still need to catch it here for the pack-selection path.
local OD_USE_MAP = {
    j_omnificence_joker           = { menu = 'Joker' },
    j_omnificence_joker_common    = { menu = 'Joker', rarity = 1 },
    j_omnificence_joker_uncommon  = { menu = 'Joker', rarity = 2 },
    j_omnificence_joker_rare      = { menu = 'Joker', rarity = 3 },
    c_omnificence_soul            = { menu = 'Joker', rarity = 4 },
    c_omnificence_black_hole      = { menu = 'BlackHole' },
    c_omnificence_tarot           = { menu = 'Tarot' },
    c_omnificence_planet          = { menu = 'Planet' },
    c_omnificence_spectral        = { menu = 'Spectral' },
    v_omnificence_voucher         = { menu = 'Voucher' },
    p_omnificence_booster         = { menu = 'Booster Pack' },
}

local function make_filter(entry)
    local menu = entry.menu
    if menu == 'Joker' then
        return OD.pool_count.filter_jokers(entry.rarity)
    elseif menu == 'Tarot' or menu == 'Planet' or menu == 'Spectral' then
        return OD.pool_count.filter_consumables(menu)
    elseif menu == 'Voucher' then
        return OD.pool_count.filter_vouchers()
    elseif menu == 'Booster Pack' then
        return OD.pool_count.filter_boosters()
    elseif menu == 'BlackHole' then
        return nil  -- open_collection_menu('BlackHole') builds its own pool
    end
end

local orig_use_card = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
    local card = e.config.ref_table

    -- Intercept playing cards marked for suit/rank choice before vanilla add-to-deck path
    if card and card._od_pc_choice then
        e.config.button = nil
        local from_area = card.area
        if from_area then from_area:remove_card(card) end
        OD._playing_card_selection = {
            center_key = card.config.center_key,
            edition    = card.edition,
            seal       = card.seal,
            from_pack  = (from_area == G.pack_cards),
        }
        G.E_MANAGER:add_event(Event({func = function()
            card:start_dissolve()
            OD.open_collection_menu('PlayingCardSuit')
            return true
        end}))
        return
    end

    local entry = card and OD_USE_MAP[card.config.center_key]
    if not entry then
        if card and card._od_collection then
            if card._od_bh_select then
                local center       = card.config.center
                local planet_count = card._od_bh_planet_count or 1
                G.E_MANAGER:add_event(Event({func = function()
                    G.FUNCS.exit_overlay_menu()
                    return true
                end}))
                G.E_MANAGER:add_event(Event({func = function()
                    local temp = Card(G.ROOM.T.x, G.ROOM.T.h, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                    if center.set == 'Planet' then
                        local hand_type = center.config and center.config.hand_type
                        if hand_type and planet_count > 0 then
                            level_up_hand(temp, hand_type, false, planet_count)
                        end
                    elseif center.key == 'c_black_hole' then
                        for k in pairs(G.GAME.hands) do
                            level_up_hand(temp, k, true)
                        end
                    end
                    temp:remove()
                    return true
                end}))
                return
            end

            -- Collection cards: create a fresh card and run the appropriate action on it
            -- instead of on the overlay card, which avoids crashes from the overlay CardArea
            -- being destroyed while use_card still holds a reference to it.
            local center_key = card.config.center_key
            local set        = card.ability.set
            local cost       = card.cost or 0
            local center     = card.config.center
            G.E_MANAGER:add_event(Event({func = function()
                G.FUNCS.exit_overlay_menu()
                return true
            end}))
            G.E_MANAGER:add_event(Event({func = function()
                if set == 'Voucher' then
                    local nc = create_card(set, G.play, nil, nil, nil, nil, center_key)
                    nc.cost = cost
                    G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
                    draw_card(G.hand, G.play, 1, 'up', true, nc, nil, true)
                    local prev_state = G.STATE
                    nc:redeem()
                    -- Dissolve the card and restore state (use_card normally does this)
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                        nc:start_dissolve()
                        G.E_MANAGER:add_event(Event({func = function()
                            G.STATE = prev_state
                            G.TAROT_INTERRUPT = nil
                            return true
                        end}))
                        return true
                    end}))
                elseif set == 'Booster' then
                    local nc = create_card(set, G.play, nil, nil, nil, nil, center_key)
                    nc.cost = cost
                    nc:set_cost()
                    G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
                    draw_card(G.hand, G.play, 1, 'up', true, nc, nil, true)
                    G.TAROT_INTERRUPT = G.STATE
                    G.GAME.PACK_INTERRUPT = G.STATE
                    -- Mirror vanilla use_card: slide shop off-screen so end_consumeable slides it back
                    if G.shop and not G.shop.alignment.offset.py then
                        G.shop.alignment.offset.py = G.shop.alignment.offset.y
                        G.shop.alignment.offset.y = G.ROOM.T.y + 29
                    end
                    nc:open()
                else -- Tarot, Planet, Spectral
                    local should_inject = OD._pack_inject
                        and (set == 'Tarot' or set == 'Planet' or set == 'Spectral')
                        and G.pack_cards
                    OD._pack_inject = nil
                    if should_inject then
                        if not center.discovered then discover_card(center) end
                        if set == 'Planet' then inc_career_stat('c_planets_bought', 1)
                        elseif set == 'Tarot' then inc_career_stat('c_tarots_bought', 1) end
                        local nc = create_card(set, G.pack_cards, nil, nil, nil, nil, center_key)
                        G.pack_cards:emplace(nc)
                        play_sound('card1', 0.8, 0.6)
                        play_sound('generic1')
                    else
                        local nc = create_card(set, G.consumeables, nil, nil, nil, nil, center_key)
                        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
                        if set == 'Planet' then inc_career_stat('c_planets_bought', 1)
                        elseif set == 'Tarot' then inc_career_stat('c_tarots_bought', 1) end
                        if not center.discovered then discover_card(center) end
                        nc:add_to_deck()
                        G.consumeables:emplace(nc)
                        play_sound('card1', 0.8, 0.6)
                        play_sound('generic1')
                        SMODS.calculate_context({buying_card = true, card = nc})
                    end
                end
                return true
            end}))
            return
        end
        return orig_use_card(e, mute, nosave)
    end

    e.config.button = nil  -- prevent double-fire, mirrors what use_card does first

    local from_area = card.area
    if from_area == G.pack_cards then
        OD._pack_inject = true
    end
    -- Vouchers and boosters haven't had their cost deducted yet (unlike consumables,
    -- which go through buy_from_shop first and are already paid for).
    if from_area == G.shop_vouchers or from_area == G.shop_booster then
        if card.cost and card.cost > 0 then
            ease_dollars(-card.cost)
            inc_career_stat('c_shop_dollars_spent', card.cost)
        end
        G.GAME.round_scores.cards_purchased.amt = G.GAME.round_scores.cards_purchased.amt + 1
        if from_area == G.shop_vouchers then
            G.GAME.used_vouchers[card.config.center_key] = true
            set_voucher_usage(card)
        end
    end

    if not card.config.center.discovered then discover_card(card.config.center) end
    if from_area then from_area:remove_card(card) end

    -- Prevent re-spawning soul/black_hole for cards used from packs (buying_self path handles shop)
    local ck = card.config.center_key
    if ck == 'c_omnificence_soul' or ck == 'c_omnificence_black_hole' then
        G.GAME.used_jokers[ck] = true
    end

    if entry.menu == 'Joker' then
        OD._joker_essence_edition = card.edition
    end
    local filter = make_filter(entry)
    G.E_MANAGER:add_event(Event({
        func = function()
            card:start_dissolve()
            if entry.menu == 'BlackHole' then
                OD.open_collection_menu('BlackHole')
            else
                OD.open_collection_menu(entry.menu, filter)
            end
            return true
        end,
    }))
end
