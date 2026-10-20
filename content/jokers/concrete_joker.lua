SMODS.Joker {
    key = 'concrete_joker',
    loc_txt = {
        name = "Concrete Joker",
        text = {
			"Gives {C:mult}+#1#{} Mult and {C:chips}+#2#{} Chips",
			"for each {C:attention}Stone Card{} in your {C:attention}full deck",
			"{C:inactive}Currently: {C:mult}+#3#{C:inactive} Mult {C:chips}+#4#{C:inactive} Chips",
        },
    },
    rarity = 2,
    cost = 6,
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 4, y = 2 },
    blueprint_compat = true,
    perishable_compat = true,
	discovered = true,
    config = {
        extra = {
            mult = 10,
            chips = 25,
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        local stone_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
            end
        end
        return { vars = { card.ability.extra.mult, card.ability.extra.chips, card.ability.extra.mult * stone_tally, card.ability.extra.chips * stone_tally } }
    end,
	
	in_pool = function(self, args)
		return false
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local stone_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_stone') then stone_tally = stone_tally + 1 end
            end
            if stone_tally > 0 then
                return {
                    mult = card.ability.extra.mult * stone_tally,
                    chips = card.ability.extra.chips * stone_tally,
                }
            end
        end
    end,

    abn_artist_credits = {
        artist = "B.b.b.b",
    },
}