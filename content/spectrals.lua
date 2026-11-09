SMODS.Atlas({
  key = "CUTOUTSpectrals",
  path = "specrtal_cards.png",
  px = 71,
  py = 95,
})

SMODS.Consumable {
    key = 'Shaped',
    set = 'Spectral',
    atlas = 'CUTOUTSpectrals',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'Shaped',
        text = {
            "Destroy a selected {C:attention}Ace{}",
            "add {C:attention}#1#{} random {C:attention}Cut-Out{} face cards to your hand",
            "with a random {C:attention}Cut-Out{} {C:dark_edition}enhancement{}",
        }
    },
    config = { extra = { cards = 3 } },
	
	abn_artist_credits = {
        artist = "Okronix"
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.highlighted and #G.hand.highlighted == 1) then return false end
        local target = G.hand.highlighted[1]
        if SMODS.has_no_rank(target) or target:get_id() ~= 14 then return false end
        for _, center in ipairs(G.P_CENTER_POOLS.Enhanced) do
            if center.key:sub(1, 9) == 'm_cutout_' then return true end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]

        local enhancement_keys = {}
        for _, center in ipairs(G.P_CENTER_POOLS.Enhanced) do
            if center.key:sub(1, 9) == 'm_cutout_' then
                table.insert(enhancement_keys, center.key)
            end
        end

        local face_ranks = { 'cutout_Sire', 'cutout_Grace', 'cutout_Duke', 'cutout_Cavalier' }
        local suits = { 'Hearts', 'Diamonds', 'Clubs', 'Spades' }

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                SMODS.calculate_context({ remove_playing_cards = true, removed = { target } })
                if target.ability.name == 'Glass Card' then
                    target:shatter()
                else
                    target:start_dissolve(nil, true)
                end
                return true
            end
        }))

        delay(0.3)

        local created_cards = {}
        for i = 1, card.ability.extra.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local suit_key = pseudorandom_element(suits, pseudoseed('abn_shaped_suit'))
                    local rank_key = pseudorandom_element(face_ranks, pseudoseed('abn_shaped_rank'))
                    local enhancement_key = pseudorandom_element(enhancement_keys, pseudoseed('abn_shaped_enhancement'))

                    local new_card = create_playing_card({
                        front = G.P_CARDS[SMODS.Suits[suit_key].card_key .. '_' .. SMODS.Ranks[rank_key].card_key],
                        center = G.P_CENTERS[enhancement_key],
                    }, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })

                    table.insert(created_cards, new_card)
                    play_sound('card1', 0.9 + i * 0.1)
                    new_card:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                playing_card_joker_effects(created_cards)
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

SMODS.Consumable {
    key = 'Progress',
    set = 'Spectral',
    atlas = 'CUTOUTSpectrals',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Progress',
        text = {
            "Destroy a selected {C:attention}Face{} card",
            "add {C:attention}#1#{} random {C:attention}Double Aces{} to your hand",
            "with a random {C:attention}Cut-Out{} {C:dark_edition}edition{}",
        }
    },
    config = { extra = { cards = 3 } },

    abn_artist_credits = {
        artist = "Okronix"
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.highlighted and #G.hand.highlighted == 1) then return false end
        return G.hand.highlighted[1]:is_face()
    end,

    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]

        local edition_keys = {}
        for key, center in pairs(G.P_CENTERS) do
            if center.set == 'Edition' and key:find('^e_cutout_') then
                table.insert(edition_keys, key)
            end
        end
        table.sort(edition_keys)

        if #edition_keys == 0 then
            sendWarnMessage('Progress: no e_cutout_ editions found in G.P_CENTERS')
            return
        end

        local suits = { 'Hearts', 'Diamonds', 'Clubs', 'Spades' }

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                SMODS.calculate_context({ remove_playing_cards = true, removed = { target } })
                if target.ability.name == 'Glass Card' then
                    target:shatter()
                else
                    target:start_dissolve(nil, true)
                end
                return true
            end
        }))

        delay(0.3)

        local created_cards = {}
        for i = 1, card.ability.extra.cards do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local suit_key = pseudorandom_element(suits, pseudoseed('abn_progress_suit'))
                    local edition_key = pseudorandom_element(edition_keys, pseudoseed('abn_progress_edition'))

                    local new_card = create_playing_card({
                        front = G.P_CARDS[SMODS.Suits[suit_key].card_key .. '_' .. SMODS.Ranks['cutout_AA'].card_key],
                        center = G.P_CENTERS.c_base,
                    }, G.hand, nil, i ~= 1, { G.C.SECONDARY_SET.Spectral })

                    new_card:set_edition(edition_key, true, true)

                    table.insert(created_cards, new_card)
                    play_sound('card1', 0.9 + i * 0.1)
                    new_card:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                playing_card_joker_effects(created_cards)
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}