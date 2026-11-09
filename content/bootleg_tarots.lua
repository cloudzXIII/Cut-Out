SMODS.ConsumableType{
    key = 'Bootleg',
    collection_rows = {5,5},
    primary_colour = HEX("8372da"),
    secondary_colour = HEX("8372da"),
	text_colour = HEX("ddc4ff"),
    loc_txt = {
        collection = 'Bootleg Tarots',
        name = 'Bootleg Tarots',
        undiscovered = {
            name = 'Not Discovered',
            text = {"Purchase or use", "this card in an", "unseeded run to", "learn what it does"}
        }
    },
    shop_rate = 0,
}

SMODS.Atlas({
  key = "CUTOUTBootlegs",
  path = "consumables/bootleg.png",
  px = 71,
  py = 95,
})

SMODS.Consumable {
    key = 'Law',
    set = 'Bootleg',
    atlas = 'CUTOUTBootlegs',
    pos = { x = 8, y = 0 },
    loc_txt = {
        name = 'Law',
        text = {
            "Turn {C:attention}#1#{} random {C:attention}non-enhanced{}",
            "cards into {C:attention}Zig-Zag{} Cards",
        }
    },
    config = { extra = { cards = 2 } },
	hidden = true,
    soul_set = "Tarot",
    soul_rate = 0.03,

    abn_artist_credits = {
        artist = "NiceCream"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cutout_Zigzag
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.cards) then return false end
        for _, playing_card in ipairs(G.hand.cards) do
            if not next(SMODS.get_enhancements(playing_card)) then
                return true
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local eligible = {}
        for _, playing_card in ipairs(G.hand.cards) do
            if not next(SMODS.get_enhancements(playing_card)) then
                table.insert(eligible, playing_card)
            end
        end

        local targets = {}
        for _ = 1, math.min(card.ability.extra.cards, #eligible) do
            local picked, picked_index = pseudorandom_element(eligible, pseudoseed('abn_law'))
            table.insert(targets, picked)
            table.remove(eligible, picked_index)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', 1.15 - (i - 1) / #targets * 0.3)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    target:set_ability(G.P_CENTERS.m_cutout_Zigzag)
                    return true
                end
            }))
        end

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', 0.85 + (i - 1) / #targets * 0.3, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

SMODS.Consumable {
    key = 'Planet',
    set = 'Bootleg',
    atlas = 'CUTOUTBootlegs',
    pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'Planet',
        text = {
            "Turn {C:attention}#1#{} random {C:attention}modded suit{} cards",
            "into {C:spades}Spades{} with {C:attention}Spare{} enhancement",
        }
    },
    config = { extra = { cards = 3 } },
	hidden = true,
    soul_set = "Tarot",
    soul_rate = 0.03,
	
	abn_artist_credits = {
        artist = "NiceCream"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cutout_Spare
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.cards) then return false end
        for _, playing_card in ipairs(G.hand.cards) do
            local suit = SMODS.Suits[playing_card.base.suit]
            if suit and suit.mod and not SMODS.has_no_suit(playing_card) then
                return true
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local eligible = {}
        for _, playing_card in ipairs(G.hand.cards) do
            local suit = SMODS.Suits[playing_card.base.suit]
            if suit and suit.mod and not SMODS.has_no_suit(playing_card) then
                table.insert(eligible, playing_card)
            end
        end

        local targets = {}
        for _ = 1, math.min(card.ability.extra.cards, #eligible) do
            local picked, picked_index = pseudorandom_element(eligible, pseudoseed('abn_planet'))
            table.insert(targets, picked)
            table.remove(eligible, picked_index)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', 1.15 - (i - 1) / #targets * 0.3)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.change_base(target, 'Spades')
                    target:set_ability(G.P_CENTERS.m_cutout_Spare)
                    return true
                end
            }))
        end

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', 0.85 + (i - 1) / #targets * 0.3, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

SMODS.Consumable {
    key = 'Planet',
    set = 'Bootleg',
    atlas = 'CUTOUTBootlegs',
    pos = { x = 9, y = 0 },
    loc_txt = {
        name = 'Planet',
        text = {
            "Turn {C:attention}#1#{} random {C:attention}modded{} cards",
            "in hand into {C:spades}Spades{} and give each",
            "a {C:attention}Spare Card{} enhancement",
        }
    },
    config = { extra = { cards = 3 } },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cutout_Spare
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.cards) then return false end
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then return true end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }

        local eligible = {}
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then table.insert(eligible, playing_card) end
            end
        end

        local targets = {}
        for _ = 1, math.min(card.ability.extra.cards, #eligible) do
            local picked, picked_index = pseudorandom_element(eligible, pseudoseed('abn_planet'))
            table.insert(targets, picked)
            table.remove(eligible, picked_index)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', 1.15 - (i - 1) / #targets * 0.3)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.change_base(target, 'Spades')
                    target:set_ability(G.P_CENTERS.m_cutout_Spare)
                    return true
                end
            }))
        end

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', 0.85 + (i - 1) / #targets * 0.3, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

SMODS.Consumable {
    key = 'Stellar',
    set = 'Bootleg',
    atlas = 'CUTOUTBootlegs',
    pos = { x = 7, y = 1 },
    loc_txt = {
        name = 'Stellar',
        text = {
            "Turn {C:attention}#1#{} random {C:attention}modded{} cards",
            "into {C:diamonds}Diamonds{} with {C:attention}Tallied{} enhancement",
        }
    },
    config = { extra = { cards = 3 } },
	hidden = true,
    soul_set = "Tarot",
    soul_rate = 0.03,

    abn_artist_credits = {
        artist = "Vega"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cutout_Tallied
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.cards) then return false end
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then return true end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }

        local eligible = {}
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then table.insert(eligible, playing_card) end
            end
        end

        local targets = {}
        for _ = 1, math.min(card.ability.extra.cards, #eligible) do
            local picked, picked_index = pseudorandom_element(eligible, pseudoseed('abn_stellar'))
            table.insert(targets, picked)
            table.remove(eligible, picked_index)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', 1.15 - (i - 1) / #targets * 0.3)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.change_base(target, 'Diamonds')
                    target:set_ability(G.P_CENTERS.m_cutout_Tallied)
                    return true
                end
            }))
        end

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', 0.85 + (i - 1) / #targets * 0.3, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}

SMODS.Consumable {
    key = 'Sol',
    set = 'Bootleg',
    atlas = 'CUTOUTBootlegs',
    pos = { x = 9, y = 1 },
    loc_txt = {
        name = 'Sol',
        text = {
            "Turn {C:attention}#1#{} random {C:attention}modded{} cards",
            "into {C:hearts}Hearts{} with {C:attention}Ample{} enhancement",
        }
    },
    config = { extra = { cards = 3 } },
	hidden = true,
    soul_set = "Tarot",
    soul_rate = 0.03,

    abn_artist_credits = {
        artist = "Vega"
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_cutout_Ample
        return { vars = { card.ability.extra.cards } }
    end,

    can_use = function(self, card)
        if not (G.hand and G.hand.cards) then return false end
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then return true end
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local vanilla_suits = { Hearts = true, Diamonds = true, Clubs = true, Spades = true }
        local vanilla_ranks = {
            ['2'] = true, ['3'] = true, ['4'] = true, ['5'] = true, ['6'] = true, ['7'] = true, ['8'] = true,
            ['9'] = true, ['10'] = true, Jack = true, Queen = true, King = true, Ace = true,
        }

        local eligible = {}
        for _, playing_card in ipairs(G.hand.cards) do
            if not SMODS.has_no_suit(playing_card) then
                local is_modded = not vanilla_suits[playing_card.base.suit] or not vanilla_ranks[playing_card.base.value]
                if playing_card.config.center.original_mod then is_modded = true end
                if playing_card.edition and G.P_CENTERS[playing_card.edition.key] and G.P_CENTERS[playing_card.edition.key].original_mod then
                    is_modded = true
                end
                if playing_card.seal and G.P_SEALS[playing_card.seal] and G.P_SEALS[playing_card.seal].original_mod then
                    is_modded = true
                end
                if is_modded then table.insert(eligible, playing_card) end
            end
        end

        local targets = {}
        for _ = 1, math.min(card.ability.extra.cards, #eligible) do
            local picked, picked_index = pseudorandom_element(eligible, pseudoseed('abn_sol'))
            table.insert(targets, picked)
            table.remove(eligible, picked_index)
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('card1', 1.15 - (i - 1) / #targets * 0.3)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        delay(0.2)

        for _, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    SMODS.change_base(target, 'Hearts')
                    target:set_ability(G.P_CENTERS.m_cutout_Ample)
                    return true
                end
            }))
        end

        for i, target in ipairs(targets) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    target:flip()
                    play_sound('tarot2', 0.85 + (i - 1) / #targets * 0.3, 0.6)
                    target:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
}
