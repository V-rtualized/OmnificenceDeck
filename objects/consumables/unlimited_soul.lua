SMODS.Consumable {
    key = "soul",
    set = "Spectral",
    atlas = "unlimited_soul",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 4,
    unlocked = true,
    discovered = true,
    can_use = function(self, card)
        return #G.jokers.cards < G.jokers.config.card_limit or card.area == G.jokers
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.jokers(4) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            G.GAME.used_jokers['c_uc_soul'] = true
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    UC.open_collection_menu('Joker', UC.pool_count.filter_jokers(4))
                    return true
                end,
            }))
        end
    end,
}
