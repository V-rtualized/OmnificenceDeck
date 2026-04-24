SMODS.Consumable {
	key = "playing_card",
	set = "Spectral",
	no_collection = true,
	in_pool = function() return false end,
	atlas = "playing_card",
	pos = { x = 0, y = 0 },
	cost = 0,
	unlocked = true,
	discovered = true,
	can_use = function(self, card) return true end,
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
}
