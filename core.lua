UC = UC or {}
UC.pool_count = SMODS.load_file("lib/pool_count.lua")()
SMODS.load_file("lib/hooks.lua")()
SMODS.load_file("lib/collection.lua")()

for _, a in ipairs({
	{ key = "joker", path = "unlimited_joker.png" },
	{ key = "tarot", path = "unlimited_tarot.png" },
	{ key = "planet", path = "unlimited_planet.png" },
	{ key = "spectral", path = "unlimited_spectral.png" },
	{ key = "booster", path = "unlimited_booster.png" },
	{ key = "voucher", path = "unlimited_voucher.png" },
	{ key = "unlimited_soul", path = "unlimited_soul.png" },
	{ key = "unlimited_black_hole", path = "unlimited_black_hole.png" },
	{ key = "unlimited_deck", path = "unlimited_deck.png" },
}) do
	SMODS.Atlas({ key = a.key, path = a.path, px = 71, py = 95 })
end

local object_files = {
	"objects/jokers/unlimited_joker.lua",
	"objects/jokers/unlimited_joker_common.lua",
	"objects/jokers/unlimited_joker_uncommon.lua",
	"objects/jokers/unlimited_joker_rare.lua",
	"objects/consumables/unlimited_tarot.lua",
	"objects/consumables/unlimited_planet.lua",
	"objects/consumables/unlimited_spectral.lua",
	"objects/consumables/unlimited_soul.lua",
	"objects/consumables/unlimited_black_hole.lua",
	"objects/backs/omnificence_deck.lua",
	"objects/boosters/unlimited_booster.lua",
	"objects/vouchers/unlimited_voucher.lua",
	"objects/tags/unlimited_tag.lua",
}

for _, path in ipairs(object_files) do
	SMODS.load_file(path)()
end
