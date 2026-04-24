SMODS.Consumable {
    key = "planet",
    set = "Planet",
    atlas = "planet",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 3,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { OD.pool_count.consumables('Planet') } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    OD.open_collection_menu('Planet', OD.pool_count.filter_consumables('Planet'))
                    return true
                end,
            }))
        end
    end,
}
