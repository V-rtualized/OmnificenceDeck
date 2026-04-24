SMODS.Joker {
    key = "joker_rare",
    atlas = "joker",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.jokers(3) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    UC.open_collection_menu('Joker', UC.pool_count.filter_jokers(3))
                    return true
                end,
            }))
        end
    end,
}
