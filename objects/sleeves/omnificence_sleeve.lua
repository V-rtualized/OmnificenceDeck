if not CardSleeves then
	return
end

local SLEEVE_KEY = "sleeve_omnificence_omnificence"

SMODS.Atlas({
	key = "omnificence_sleeve",
	path = "omnificence_sleeve.png",
	px = 71,
	py = 93,
})

SMODS.DrawStep({
	key = "omnificence_sleeve_shader",
	order = 6,
	conditions = { vortex = false, facing = "back" },
	func = function(self)
		if not (self.params and self.params.sleeve_card) then
			return
		end
		if not (self.config and self.config.center and self.config.center.key == SLEEVE_KEY) then
			return
		end
		self.children.back:draw_shader("booster", nil, { (self.ID or 1) % 97 / 10.0, 0 }, true)
	end,
})

local orig_CardArea_draw = CardArea.draw
function CardArea:draw(...)
	orig_CardArea_draw(self, ...)
	if self ~= G.deck then
		return
	end
	if not (G.GAME and G.GAME.selected_sleeve == SLEEVE_KEY) then
		return
	end
	if not self.sleeve_sprite then
		return
	end
	local sprite = self.sleeve_sprite
	sprite.ARGS = sprite.ARGS or {}
	sprite.ARGS.send_to_shader = sprite.ARGS.send_to_shader or {}
	sprite.ARGS.send_to_shader[1] = G.TIMERS.REAL / 5 + 1.5
	sprite.ARGS.send_to_shader[2] = 0
	Sprite.draw_shader(sprite, "booster", nil, sprite.ARGS.send_to_shader)
end

CardSleeves.Sleeve({
	key = "omnificence",
	atlas = "omnificence_sleeve",
	pos = { x = 0, y = 0 },
	unlocked = true,
	apply = function(self)
		G.GAME.modifiers.omnificence = true
	end,
})
