SMODS.Consumable {
    key = "soul",
    no_collection = true,
    set = "Spectral",
    atlas = "soul_essence",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 4,
    unlocked = true,
    discovered = true,
    can_use = function(self, card)
        return #G.jokers.cards < G.jokers.config.card_limit or card.area == G.jokers
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { OD.pool_count.jokers(4) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            G.GAME.used_jokers['c_omnificence_soul'] = true
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    OD.open_collection_menu('Joker', OD.pool_count.filter_jokers(4))
                    return true
                end,
            }))
        end
    end,
}
