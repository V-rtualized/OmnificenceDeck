SMODS.Booster {
    key = "booster",
    atlas = "booster",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 4,
    config = { extra = 3, choose = 1 },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.boosters() } }
    end,
}
