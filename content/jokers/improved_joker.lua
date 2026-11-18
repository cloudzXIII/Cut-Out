SMODS.Joker {
    key = 'improved_joker',
    atlas = 'CUTOUTJokerEvolutions',
    pos = { x = 0, y = 0 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    discovered = true,
 
    -- only obtained by evolving a Joker
    in_pool = function(self)
        return false
    end,
 
    config = { extra = { mult = 8, } },
 
    abn_artist_credits = {
        artist = "Moodlich"
    },
 
    loc_txt = {
        name = "Improved Joker",
        text = {
            "{C:mult}+#1#{} Mult whenever a {C:attention}Joker{} triggers"
        }
    },
 
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.mult,
            }
        }
    end,
 
    calculate = function(self, card, context) 
        if context.post_trigger and context.other_card ~= card then
            return {
                mult = card.ability.extra.mult,
                card = card
            }
        end
    end,
}
