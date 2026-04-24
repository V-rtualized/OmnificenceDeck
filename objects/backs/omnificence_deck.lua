SMODS.DrawStep {
    key = 'uc_omnificence_back_shader',
    order = 5,
    conditions = { vortex = false, facing = 'back' },
    func = function(self)
        if not (G.GAME and self.back) then return end
        local game_back = G.GAME[self.back]
        if not (game_back and game_back.effect and game_back.effect.center) then return end
        if game_back.effect.center.key ~= 'b_uc_omnificence' then return end
        if not (self.area and self.area.config.type == 'deck' and self.rank == 1) then return end

        self.children.back:draw_shader('booster', nil, self.ARGS.send_to_shader)
    end,
}

SMODS.Back {
    key = "omnificence",
    atlas = "unlimited_deck",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
}
