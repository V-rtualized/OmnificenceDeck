SMODS.Tag {
    key = "tag",
    atlas = "tags",
    prefix_config = { atlas = false },
    pos = { x = 3, y = 4 },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { UC.pool_count.tags() } }
    end,
    apply = function(self, tag, _context)
        if _context.type ~= 'immediate' then return end
        tag:yep('+', G.C.PURPLE, function()
            UC.open_collection_menu('Tag', UC.pool_count.filter_tags())
            return true
        end)
        tag.triggered = true
        return { tag = tag }
    end,
}
