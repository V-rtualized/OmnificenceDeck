local STAKE_KEY = "stake_omnificence_omnificence"

local orig_get_stake_sprite = get_stake_sprite
function get_stake_sprite(_stake, _scale)
	local sprite = orig_get_stake_sprite(_stake, _scale)
	if G.P_CENTER_POOLS.Stake[_stake] and G.P_CENTER_POOLS.Stake[_stake].key == STAKE_KEY then
		sprite.draw = function(_sprite)
			_sprite.ARGS.send_to_shader = _sprite.ARGS.send_to_shader or {}
			_sprite.ARGS.send_to_shader[1] = G.TIMERS.REAL / 5 + 1.5
			_sprite.ARGS.send_to_shader[2] = 0
			Sprite.draw_shader(_sprite, "dissolve")
			Sprite.draw_shader(_sprite, "booster", nil, _sprite.ARGS.send_to_shader)
		end
	end
	return sprite
end

SMODS.Stake({
	key = "omnificence",
	atlas = "omnificence_stake",
	pos = { x = 0, y = 0 },
	above_stake = "stake_gold",
	applied_stakes = { "stake_gold" },
	unlocked = true,
	modifiers = function()
		G.GAME.modifiers.omnificence = true
	end,
})
