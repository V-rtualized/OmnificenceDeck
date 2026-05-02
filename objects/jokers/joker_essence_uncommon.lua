SMODS.Joker {
    key = "joker_uncommon",
    no_collection = true,
    atlas = "joker",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { OD.pool_count.jokers(2) } }
    end,
    calculate = function(self, card, context)
        if context.buying_self then
            OD._joker_essence_edition   = card.edition
            OD._joker_essence_abilities = {
                eternal     = card.ability.eternal,
                perishable  = card.ability.perishable,
                perish_tally = card.ability.perish_tally,
                rental      = card.ability.rental,
            }
            card:start_dissolve()
            G.E_MANAGER:add_event(Event({
                func = function()
                    OD.open_collection_menu('Joker', OD.pool_count.filter_jokers(2))
                    return true
                end,
            }))
        end
    end,
}
