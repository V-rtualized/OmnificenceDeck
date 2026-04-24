SMODS.Booster {
    key = "booster",
    no_collection = true,
    atlas = "booster",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 4,
    config = { extra = 3, choose = 1 },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { OD.pool_count.boosters() } }
    end,
}
