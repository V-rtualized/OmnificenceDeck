SMODS.DrawStep {
    key = 'omnificence_back_shader',
    order = 5,
    conditions = { vortex = false, facing = 'back' },
    func = function(self)
        if not (G.GAME and self.back) then return end
        local game_back = G.GAME[self.back]
        if not (game_back and game_back.effect and game_back.effect.center) then return end
        if game_back.effect.center.key ~= 'b_omnificence_omnificence' then return end

        self.children.back:draw_shader('booster', nil, {(self.ID or 1) % 97 / 10.0, 0}, true)
    end,
}

SMODS.Back {
    key = "omnificence",
    atlas = "omnificence_deck",
    pos = { x = 0, y = 0 },
    unlocked = true,
    discovered = true,
    apply = function(self)
        G.GAME.modifiers.omnificence = true
    end,
}
