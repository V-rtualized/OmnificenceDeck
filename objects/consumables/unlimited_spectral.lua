SMODS.Consumable {
    key = "spectral",
    set = "Spectral",
    atlas = "spectral",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 4,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.consumables('Spectral') } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    UC.open_collection_menu('Spectral', UC.pool_count.filter_consumables('Spectral'))
                    return true
                end,
            }))
        end
    end,
}
