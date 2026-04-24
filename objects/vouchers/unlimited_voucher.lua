SMODS.Voucher {
    key = "voucher",
    atlas = "voucher",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    cost = 10,
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.vouchers() } }
    end,
}
