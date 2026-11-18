SMODS.Joker {
    key = 'stand_up',
    atlas = 'CUTOUTJokerEvolutions',
    pos = { x = 3, y = 1 },
    rarity = 2,
    cost = 6,
    blueprint_compat = true,
    discovered = true,
 
    -- only obtained by evolving a Hack
    in_pool = function(self)
        return false
    end,
 
    config = { extra = { repetitions = 1 } },
 
    abn_artist_credits = {
        artist = "Okronix"
    },
 
    loc_txt = {
        name = "Stand-Up",
        text = {
            "{C:attention}Retrigger{} each played",
            "{C:attention}2{}, {C:attention}3{}, {C:attention}4{}, {C:attention}5{}, {C:attention}6{}, {C:attention}7{}, {C:attention}8{} and {C:attention}9{}",
            "{C:attention}#1#{} additional time"
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
        if context.repetition and context.cardarea == G.play and not SMODS.has_no_rank(context.other_card) then
            local rank_id = context.other_card:get_id()
            if rank_id >= 2 and rank_id <= 9 then
                return {
                    repetitions = card.ability.extra.repetitions,
                }
            end
        end
    end,
}
 