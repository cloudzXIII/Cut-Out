SMODS.Joker {
    key = 'reflective_joker',
	loc_txt = {
        name = "Reflective Joker",
        text = {
		  {
			"{C:green}#1# in #2#{} chance for scoring cards",
			"to turn into {C:attention}Glass{} cards",
		  },
		  {
			"When a {C:attention}Glass{} card breaks this Joker",
			"gains {C:gold}+#3#{} Asc. Power and {X:mult,C:white}X#4#{} Mult",
			"{C:inactive}Currently:{} {C:gold}+#5#{} {C:inactive}Asc. Power{} {X:mult,C:white}X#6#{} {C:inactive}Mult{}"
		  },
		}
    },
    rarity = 2,
    cost = 0,
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 0, y = 2 },
    blueprint_compat = true,
    perishable_compat = false,
	discovered = true,
    config = {
        extra = {
            odds = 7,
            asc = 0,
            asc_gain = 0.5,
            x_mult = 1,
            x_mult_gain = 0.75,
        }
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds)
        return { vars = { numerator, denominator, card.ability.extra.asc_gain, card.ability.extra.x_mult_gain, card.ability.extra.asc, card.ability.extra.x_mult } }
    end,
	
	in_pool = function(self, args)
		return false
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local converted = false
            for _, scored in ipairs(context.scoring_hand) do
                if not SMODS.has_enhancement(scored, 'm_glass')
                    and SMODS.pseudorandom_probability(card, 'abn_reflective_joker', 1, card.ability.extra.odds) then
                    converted = true
                    scored:set_ability(G.P_CENTERS.m_glass, nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored:juice_up()
                            return true
                        end
                    }))
                end
            end
            if converted then
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.ATTENTION,
                }
            end
        end

        if context.remove_playing_cards and not context.blueprint then
            local shattered = 0
            for _, removed in ipairs(context.removed) do
                if removed.shattered then
                    shattered = shattered + 1
                end
            end
            if shattered > 0 then
                card.ability.extra.asc = card.ability.extra.asc + card.ability.extra.asc_gain * shattered
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain * shattered
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.ATTENTION,
                }
            end
        end

        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult,
                asc = card.ability.extra.asc,
            }
        end
    end,

    abn_artist_credits = {
        artist = "Technotoad64",
    },
}