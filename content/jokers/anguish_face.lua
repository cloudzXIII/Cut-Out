--Coded by Okronix
SMODS.Joker {
    key = 'anguish_face',
    loc_txt = {
        name = "Anguish Face",
        text = {
            {
                "Played {C:attention}face{} cards",
                "give {C:abn_eternal}+#1#{} Amperage",
                "when scored",
            }
        }
    },

    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 9, y = 0 },

    rarity = 2,
    cost = 5,

    discovered = false,
    blueprint_compat = true,

    config = {
        extra = {
            amp = 5
        }
    },

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.amp
            }
        }
    end,


    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                return {
                    amp = card.ability.extra.amp,
                }
            end
        end
    end,

    abn_artist_credits = {
        artist = "Weasel.922",
    },
}
