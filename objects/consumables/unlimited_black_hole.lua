SMODS.Consumable {
    key = "black_hole",
    set = "Spectral",
    atlas = "unlimited_black_hole",
    pos = { x = 0, y = 0 },
    cost = 4,
    unlocked = true,
    discovered = true,
    can_use = function(self, card)
        return true
    end,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.consumables('Planet') } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            G.GAME.used_jokers['c_uc_black_hole'] = true
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    UC.open_collection_menu('BlackHole')
                    return true
                end,
            }))
        end
    end,
}
