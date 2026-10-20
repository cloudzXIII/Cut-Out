SMODS.Joker {
    key = 'carcinization_joker',
    loc_txt = {
        name = "Carcinization Joker",
        text = {
			{
				"Whenever a {C:attention}Joker{} {C:attention}Evolves{}",
				"this Joker gains {C:gold}+#1#{} Asc. Power",
			},
			{
				"{C:attention}Evolved{} Jokers give {C:abn_modulate}+#2#{} Modulate",
				"{C:inactive}Currently: {C:gold}+#3#{} {C:inactive}Asc. Power",
			},
        },
    },
    rarity = 2,
    cost = 6,
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 5, y = 2 },
    blueprint_compat = true,
    perishable_compat = false,
    config = {
        extra = {
            asc = 0,
            asc_gain = 1,
            modulate = 2,
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.asc_gain, card.ability.extra.modulate, card.ability.extra.asc } }
    end,

    calculate = function(self, card, context)
        if context.abn_evolution and not context.blueprint then
            card.ability.extra.asc = card.ability.extra.asc + card.ability.extra.asc_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.FILTER,
            }
        end

        if context.other_joker and context.other_joker.ability and context.other_joker.ability.abn_evolved then
            return {
                modulate = card.ability.extra.modulate,
                message_card = context.other_joker,
            }
        end

        if context.joker_main then
            if card.ability.extra.asc > 0 then
                return {
                    asc = card.ability.extra.asc,
                }
            end
        end
    end,

    abn_artist_credits = {
        artist = "La Ginger",
    },
}