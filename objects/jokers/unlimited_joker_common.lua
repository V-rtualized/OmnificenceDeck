SMODS.Joker {
    key = "joker_common",
    atlas = "joker",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.jokers(1) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    UC.open_collection_menu('Joker', UC.pool_count.filter_jokers(1))
                    return true
                end,
            }))
        end
    end,
}
