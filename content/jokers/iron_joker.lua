SMODS.Joker {
    key = 'iron_joker',
    loc_txt = {
        name = "Iron Joker",
        text = {
			{
				"Scoring cards give {X:mult,C:white}X#1#{} Mult for each",
				"{C:attention}Steel Card{} held in hand",
			},
			{
				"This Joker gives {X:mult,C:white}X#2#{} Mult for each",
				"{C:attention}Steel Card{} in your {C:attention}full deck",
				"{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult)",
			},
        },
    },
    rarity = 2,
    cost = 6,
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 3, y = 2 },
    blueprint_compat = true,
    perishable_compat = true,
	discovered = true,
    config = {
        extra = {
            card_xmult = 1.5,
            deck_xmult = 0.2,
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
        local steel_tally = 0
        if G.playing_cards then
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_steel') then steel_tally = steel_tally + 1 end
            end
        end
        return { vars = { card.ability.extra.card_xmult, card.ability.extra.deck_xmult, 1 + card.ability.extra.deck_xmult * steel_tally } }
    end,
	
	in_pool = function(self, args)
		return false
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local steel_held = 0
            for _, held in ipairs(G.hand.cards) do
                if SMODS.has_enhancement(held, 'm_steel') then steel_held = steel_held + 1 end
            end
            if steel_held > 0 then
                return {
                    xmult = card.ability.extra.card_xmult ^ steel_held,
                }
            end
        end

        if context.joker_main then
            local steel_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_steel') then steel_tally = steel_tally + 1 end
            end
            if steel_tally > 0 then
                return {
                    xmult = 1 + card.ability.extra.deck_xmult * steel_tally,
                }
            end
        end
    end,

    abn_artist_credits = {
        artist = "B.b.b.b",
    },
}