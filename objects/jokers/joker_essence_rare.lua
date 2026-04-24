SMODS.Joker {
    key = "joker_rare",
    no_collection = true,
    atlas = "joker",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { OD.pool_count.jokers(3) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            OD._joker_essence_edition = card.edition
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    OD.open_collection_menu('Joker', OD.pool_count.filter_jokers(3))
                    return true
                end,
            }))
        end
    end,
}
