SMODS.Consumable({
	key = "tarot",
	no_collection = true,
	set = "Tarot",
	atlas = "tarot",
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 3,
	unlocked = true,
	discovered = true,
	can_use = function(self, card) return true end,
	loc_vars = function(self, info_queue, card)
		return { vars = { OD.pool_count.consumables('Tarot') } }
	end,
	calculate = function(self, card, context)
		if context.buying_self then
			card:start_dissolve()
			G.E_MANAGER:add_event(Event({
				func = function()
					OD.open_collection_menu('Tarot', OD.pool_count.filter_consumables('Tarot'))
					return true
				end,
			}))
		end
	end,
})
