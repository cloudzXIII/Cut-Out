SMODS.Joker {
    key = 'clean_chad',
    atlas = 'CUTOUTJokerEvolutions',
    pos = { x = 9, y = 6 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    discovered = true,
 
    -- only obtained by evolving a Hanging Chad
    in_pool = function(self)
        return false
    end,
 
    config = { extra = { repetitions = 2 } },
 
    abn_artist_credits = {
        artist = "Dogg-Fly"
    },
 
    loc_txt = {
        name = "Clean Chad",
        text = {
            "Retrigger {C:attention}first{} and {C:attention}last{} played card",
            "{C:attention}#1#{} additional times"
        }
    },
 
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.repetitions,
            }
        }
    end,
 
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            local times = 0
 
            if context.other_card == context.scoring_hand[1] then
                times = times + card.ability.extra.repetitions
            end
 
            if context.other_card == context.scoring_hand[#context.scoring_hand] then
                times = times + card.ability.extra.repetitions
            end
 
            if times > 0 then
                return {
                    repetitions = times,
                }
            end
        end
    end,
}
 