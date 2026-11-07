SMODS.ConsumableType{
    key = 'Simulation',
    collection_rows = {5,5},
    primary_colour = HEX("1b4471"),
    secondary_colour = HEX("1b4471"),
    loc_txt = {
        collection = 'Simulation Cards',
        name = 'Simulation Cards',
        undiscovered = {
            name = 'Not Discovered',
            text = {"Purchase or use", "this card in an", "unseeded run to", "learn what it does"}
        }
    },
    shop_rate = 0,
}

SMODS.Atlas({
  key = "CUTOUTSimulations",
  path = "consumables/simulation_cards.png",
  px = 71,
  py = 95,
})

SMODS.Consumable {
    key = 'Hivemind',
    set = 'Simulation',
    atlas = 'CUTOUTSimulations',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'Hivemind',
        text = {
            "Choose a {C:attention}Joker{} of {C:common}Common{}-{C:rare}Rare{} rarity",
            "{C:attention}reroll{} all other Jokers to match its {C:attention}rarity{}",
        }
    },
    config = { extra = {} },
	
	abn_artist_credits = {
        artist = "Tatsu"
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    can_use = function(self, card)
        if G.jokers and G.jokers.highlighted and #G.jokers.highlighted == 1 then
            local rarity = G.jokers.highlighted[1].config.center.rarity
            return rarity == 1 or rarity == 2 or rarity == 3
        end
        return false
    end,

    use = function(self, card, area, copier)
        local chosen = G.jokers.highlighted[1]
        local chosen_rarity = chosen.config.center.rarity

        local targets = {}
        for _, joker in ipairs(G.jokers.cards) do
            if joker ~= chosen and not joker.ability.eternal then
                table.insert(targets, joker)
            end
        end

        for _, joker in ipairs(G.jokers.highlighted) do
            joker.highlighted = false
        end
        G.jokers.highlighted = {}

        for _, target_joker in ipairs(targets) do
            local saved_edition = target_joker.edition and copy_table(target_joker.edition) or nil
            local saved_seal = target_joker.seal

            local saved_stickers = {}
            for _, sticker in ipairs(SMODS.Sticker.obj_buffer) do
                if target_joker.ability[sticker] then
                    saved_stickers[sticker] = {
                        val = target_joker.ability[sticker],
                        perish_tally = target_joker.ability.perish_tally,
                    }
                end
            end

            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    target_joker:juice_up(0.5, 0.5)

                    local idx = 1
                    for i, joker in ipairs(G.jokers.cards) do
                        if joker == target_joker then idx = i; break end
                    end

                    local replacement = create_card('Joker', G.jokers, nil, chosen_rarity, nil, nil, nil, 'abn_hivemind')

                    target_joker:remove()

                    if saved_edition then
                        replacement:set_edition(saved_edition, true, true)
                    end
                    if saved_seal then
                        replacement:set_seal(saved_seal, true, true)
                    end
                    for sticker_key, sticker_data in pairs(saved_stickers) do
                        replacement:add_sticker(sticker_key, true)
                        if sticker_key == 'perishable' and sticker_data.perish_tally then
                            replacement.ability.perish_tally = sticker_data.perish_tally
                        end
                    end

                    replacement:add_to_deck()
                    G.jokers:emplace(replacement)

                    table.remove(G.jokers.cards, #G.jokers.cards)
                    table.insert(G.jokers.cards, math.min(idx, #G.jokers.cards + 1), replacement)

                    G.jokers:set_ranks()
                    replacement:juice_up(0.6, 0.6)
                    return true
                end
            }))
        end
    end,
}

SMODS.Consumable {
    key = 'Superiority',
    set = 'Simulation',
    atlas = 'CUTOUTSimulations',
    pos = { x = 4, y = 0 },
    loc_txt = {
        name = 'Superiority',
        text = {
            "Force {C:attention}Evolves{} all held Jokers",
            "Jokers with {C:attention}Vanilla{} {C:dark_edition}Editions{}",
			"gain random {C:attention}Modded{} {C:dark_edition}Editions{}",
        }
    },
    config = { extra = {} },

    abn_artist_credits = {
        artist = "Tatsu"
    },

    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,

    can_use = function(self, card)
        if not (G.jokers and #G.jokers.cards > 0) then return false end

        local has_modded_edition = false
        for _, edition in ipairs(G.P_CENTER_POOLS.Edition) do
            if edition.mod then has_modded_edition = true; break end
        end

        for _, joker in ipairs(G.jokers.cards) do
            if ABN.get_evolution(joker) and not joker.debuff then
                return true
            end
            local key = joker.edition and joker.edition.key
            local center = key and G.P_CENTERS[key]
            if has_modded_edition and center and not center.mod and key ~= 'e_base' then
                return true
            end
        end
        return false
    end,

    use = function(self, card, area, copier)
        local modded_editions = {}
        for _, edition in ipairs(G.P_CENTER_POOLS.Edition) do
            if edition.mod then
                table.insert(modded_editions, edition.key)
            end
        end

        local targets = {}
        for _, joker in ipairs(G.jokers.cards) do
            table.insert(targets, joker)
        end

        for _, joker in ipairs(targets) do
            if ABN.get_evolution(joker) and not joker.debuff then
                joker:abn_init_evo()
                joker.ability.abn_evo.ready = true
                joker:abn_evolve()
            end

            local key = joker.edition and joker.edition.key
            local center = key and G.P_CENTERS[key]
            if #modded_editions > 0 and center and not center.mod and key ~= 'e_base' then
                local new_edition = pseudorandom_element(modded_editions, pseudoseed('abn_superiority'))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        joker:set_edition(new_edition, true, true)
                        joker:juice_up(0.5, 0.5)
                        play_sound('card1')
                        return true
                    end
                }))
            end
        end
    end,
}
