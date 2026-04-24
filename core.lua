OD = OD or {}

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})

OD.pool_count = SMODS.load_file("lib/pool_count.lua")()
SMODS.load_file("lib/hooks.lua")()
SMODS.load_file("lib/collection.lua")()

for _, a in ipairs({
	{ key = "joker", path = "joker_essence.png" },
	{ key = "tarot", path = "tarot_essence.png" },
	{ key = "planet", path = "planet_essence.png" },
	{ key = "spectral", path = "spectral_essence.png" },
	{ key = "booster", path = "booster_essence.png" },
	{ key = "voucher", path = "voucher_essence.png" },
	{ key = "soul_essence", path = "soul_essence.png" },
	{ key = "black_hole_essence", path = "black_hole_essence.png" },
	{ key = "omnificence_deck", path = "omnificence_deck.png" },
}) do
	SMODS.Atlas({ key = a.key, path = a.path, px = 71, py = 95 })
end

local object_files = {
	"objects/jokers/joker_essence.lua",
	"objects/jokers/joker_essence_common.lua",
	"objects/jokers/joker_essence_uncommon.lua",
	"objects/jokers/joker_essence_rare.lua",
	"objects/consumables/tarot_essence.lua",
	"objects/consumables/planet_essence.lua",
	"objects/consumables/spectral_essence.lua",
	"objects/consumables/soul_essence.lua",
	"objects/consumables/black_hole_essence.lua",
	"objects/backs/omnificence_deck.lua",
	"objects/boosters/booster_essence.lua",
	"objects/vouchers/voucher_essence.lua",
	"objects/tags/tag_essence.lua",
}

for _, path in ipairs(object_files) do
	SMODS.load_file(path)()
end
