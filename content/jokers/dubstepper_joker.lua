SMODS.Joker {
    key = 'dubstepper_joker',
    loc_txt = {
        name = "Dubstepper Joker",
        text = {
            {
                "All held {C:attention}Tonality{} cards",
                "gain {C:attention}+#1#{} charge after",
                "defeating a {C:attention}Boss Blind{}",
            },
            {
                "If this Joker has {C:attention}Aura{} the first",
                "time one of your Jokers gives {C:mult}+Mult{}",
                "each hand convert it into {C:abn_eternal}Amperage{}",
            }
        }
    },
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 6, y = 1 },
    rarity = 3,
    cost = 8,
    discovered = false,
    blueprint_compat = false,
    config = {
        extra = {
            converted = false,
            charge = 1,
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.charge } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            card.ability.extra.converted = false
        end

        if context.end_of_round and context.main_eval and not context.blueprint
            and G.GAME.blind and G.GAME.blind.boss then

            local amount = card.ability.extra.charge
            local text = "+" .. amount .. " Charge" .. (amount == 1 and "" or "s")

            for _, c in ipairs(G.consumeables.cards) do
                if c.config.center.set == "tonality"
                    and c.ability.extra and c.ability.extra.uses then
                    c.ability.extra.uses = c.ability.extra.uses + amount
                    card_eval_status_text(c, 'extra', nil, nil, nil, {
                        message = text,
                        colour = G.C.ATTENTION,
                    })
                    c:juice_up(0.3, 0.5)
                end
            end
        end
    end,

    abn_artist_credits = {
        artist = "Gud",
    },
}

local calc_individual_ref = SMODS.calculate_individual_effect
SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    if (key == 'mult' or key == 'h_mult' or key == 'mult_mod')
        and not from_edition
        and scored_card and scored_card.ability and scored_card.ability.set == 'Joker'
        and G.jokers then

        for _, j in ipairs(G.jokers.cards) do
            if j.config.center.key == 'j_cutout_dubstepper_joker'
                and not j.ability.extra.converted then

                local has_aura = false
                for k, v in pairs(j.ability) do
                    if v and FN_is_aura(k) then has_aura = true break end
                end

                if has_aura then
                    j.ability.extra.converted = true

                    effect.mult = nil
                    effect.h_mult = nil
                    effect.mult_mod = nil
                    effect.message = nil

                    key = 'amp'
                    break
                end
            end
        end
    end
    return calc_individual_ref(effect, scored_card, key, amount, from_edition)
end