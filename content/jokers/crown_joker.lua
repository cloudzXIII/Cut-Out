--Coded by Okronix
SMODS.Joker {
    key = 'crown_joker',
    loc_txt = {
        name = "Crown Joker",
        text = {
            {
                "Played {C:attention}Steel face{} cards",
                "give {C:abn_eternal}+#1#{} Amperage",
                "when scored",
            },
            {
                "{C:attention}Steel face{} cards",
                "{C:attention}held{} in hand give",
                "{C:attention}+#2#{} Modulate",
            }
        }
    },

    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 2, y = 1 },

    rarity = 2,
    cost = 6,

    discovered = false,
    blueprint_compat = true,

    config = {
        extra = {
            amp = 5,
            mod = 5
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amp,
                card.ability.extra.mod
            }
        }
    end,


    calculate = function(self, card, context)
        if context.individual then
            if context.other_card:is_face() and SMODS.has_enhancement(context.other_card, "m_steel") then
                if context.cardarea == G.play then
                    return {
                        amp = card.ability.extra.amp,
                    }
                elseif context.cardarea == G.hand then
                    return {
                        modulate = card.ability.extra.mod
                    }
                end
            end
        end
    end,

    abn_artist_credits = {
        artist = "Okronix",
    },
}
