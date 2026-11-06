SMODS.Joker {
    key = 'musa_paradisiaca',
    rarity = 2,
    atlas = 'CUTOUTJokerEvolutions',
    pos = { x = 7, y = 6 },
    cost = 6,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    config = { extra = { mult = 15, odds = 6 } },

    loc_txt = {
        name = 'Musa Paradisiaca',
        text = {
            "When {C:attention}Blind is selected{} place a {C:green}Platano{} {C:attention}Sticker{}",
			"on a random other {C:attention}Joker{}",
			"{C:red}+#1#{} Mult",
            "{C:green}#2# in #3#{} chance this card",
            "is {C:mult}destroyed{} at end of round",
        }
    },

    abn_artist_credits = {
        artist = "Szymii"
    },

    loc_vars = function(self, info_queue, card)
		info_queue[#info_queue + 1] = { key = 'abn_platano', set = 'Other', vars = { 2, 1, 4 } }
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'abn_musa_paradisiaca')
        return { vars = { card.ability.extra.mult, numerator, denominator } }
    end,
	
	-- only obtained by evolving a Joker
    in_pool = function(self)
        return false
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end

        if context.setting_blind and not context.blueprint then
            local candidates = {}
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= card and not joker.ability.abn_platano then
                    table.insert(candidates, joker)
                end
            end
            if #candidates > 0 then
                local target = pseudorandom_element(candidates, pseudoseed('abn_musa_platano'))
                target:add_sticker('abn_platano', true)
                target:juice_up(0.5, 0.5)
            end
        end

        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if SMODS.pseudorandom_probability(card, 'abn_musa_paradisiaca', 1, card.ability.extra.odds) then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                G.jokers:remove_card(card)
                                card:remove()
                                card = nil
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return { message = localize('k_extinct_ex') }
            else
                return { message = localize('k_safe_ex') }
            end
        end
    end,
}