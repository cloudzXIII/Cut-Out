if (SMODS.Mods["Fortlatro"] or {}).can_load then

    -- Any chips this card would give are also given as mult
    do
        local scie_alter = SMODS.calculate_individual_effect
        local eval_card_alter = eval_card

        local chip_to_mult = {
            chips = 'mult',
            h_chips = 'h_mult',
            chip_mod = 'mult_mod',
        }

        local function has_aura(c)
            return c and c.ability and c.ability.cutout_Alter_Aura
        end

        local function is_joker(c)
            return c and c.ability and c.ability.set == 'Joker'
        end

        -- Playing cards / editions: convert when the effect is scored on the aura card itself.
        -- Jokers are handled in eval_card below (their effects get scored on other cards).
        function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition)
            local ret = scie_alter(effect, scored_card, key, amount, from_edition)

            local mult_key = chip_to_mult[key]
            if mult_key and type(amount) == 'number' and has_aura(scored_card) and not is_joker(scored_card) then
                scie_alter(effect, scored_card, mult_key, amount, from_edition)
            end
            return ret
        end

        -- Walk an effect table (and nested `extra` tables), adding mult alongside chips
        local function add_mult(eff, depth)
            if type(eff) ~= 'table' or depth > 8 then return end
            for chip_key, mult_key in pairs(chip_to_mult) do
                local v = eff[chip_key]
                if type(v) == 'number' then
                    eff[mult_key] = (type(eff[mult_key]) == 'number' and eff[mult_key] or 0) + v
                end
            end
            if eff.extra then add_mult(eff.extra, depth + 1) end
        end

        function eval_card(card, context)
            local ret, post = eval_card_alter(card, context)
            if is_joker(card) and has_aura(card) and type(ret) == 'table' then
                add_mult(ret.jokers, 0)
                add_mult(ret.retriggers, 0)
            end
            return ret, post
        end
    end

    SMODS.Sticker {
        key = 'Alter_Aura',
        set = 'aura',
        atlas = 'alt',
        pos = { x = 0, y = 0 },
        badge_colour = G.C.PURPLE,
        
        loc_txt = {
            name = 'Alter Aura',
            label = 'Alter Aura',
            text = {
                'When this would give {C:chips}Chips{}',
                '{C:attention}ALSO{} give {C:attention}equal{} {C:mult}Mult{}',
            },
        },

        loc_vars = function(self, info_queue, card)
            return { vars = {} }
        end,

        draw = function(self, card)
            local notilt = nil
            if card.area and card.area.config.type == "deck" then
                notilt = true
            end
            if not G.shared_stickers["cutout_Alter_Aura2"] then
                G.shared_stickers["cutout_Alter_Aura2"] =
                    Sprite(0, 0, G.CARD_W, G.CARD_H, G.ASSET_ATLAS["cutout_alt"], { x = 999, y = 999 })
            end

            if G.shared_stickers[self.key] then
                G.shared_stickers[self.key].role.draw_major = card
                G.shared_stickers[self.key]:draw_shader("dissolve", nil, nil, notilt, card.children.center)
            end

            G.shared_stickers["cutout_Alter_Aura2"].role.draw_major = card

            card.hover_tilt = card.hover_tilt / 2
            G.shared_stickers["cutout_Alter_Aura2"]:draw_shader("dissolve", nil, nil, notilt, card.children.center)
            G.shared_stickers["cutout_Alter_Aura2"]:draw_shader(
                "holo",
                nil,
                card.ARGS.send_to_shader,
                notilt,
                card.children.center
            )
            card.hover_tilt = card.hover_tilt * 2
        end,
        abn_artist_credits = {
            artist = "Tatsu",
        },
    }

    SMODS.ConsumableType {
        key = 'Microverse',
        collection_rows = { 5, 5 },
        shop_rate = 0.4, 
        primary_colour = HEX('006666'),
        secondary_colour = HEX('006666'), 
        text_colour = HEX('ce96ec'),
        loc_txt = {
            collection = 'Microverse Cards',
            name = 'Microverse',
            undiscovered = {
                name = 'Not Discovered',
                text = { 'Find this card in a', 'Booster Pack to learn', 'what it does' }
            }
        }
    }

    SMODS.Atlas({
        key = "Microverse",
        path = "consumables/microverse_cards.png",
        px = 71,
        py = 95,
    })

    SMODS.Consumable {
        key = 'QuantumFlux',
        set = 'Microverse',
        atlas = 'Microverse',
        pos = {x = 0, y = 0},
        loc_txt = {
            name = 'Microverse',
            text = {
                'Apply the {C:purple}Alter Aura{}',
                'to {C:attention}#1#{} selected {C:attention}Card{}/{C:attention}Joker{}'
            }
        },

        config = {
            extra = {
                cards = 1,
            }
        },

        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = { key = "cutout_Alter_Aura", set = "Other", vars = {} }
            return {
                vars = {
                    card.ability.extra.cards
                }
            }
        end,

        can_use = function(self, card)
            if card.ability and card.ability.extra then
                local n = #G.hand.highlighted + #G.jokers.highlighted
                return n >= 1 and n <= card.ability.extra.cards
            end
            return false
        end,

        use = function(self, card, area, copier)
            local highlightedCards = {}

            for _, category in ipairs({
                G.hand.highlighted,
                G.jokers.highlighted,
            }) do
                for i = 1, #category do
                    table.insert(highlightedCards, category[i])
                end
            end

            for i = 1, math.min(#highlightedCards, card.ability.extra.cards) do
                local c = highlightedCards[i]
                fn_add_aura(c, "cutout_Alter_Aura")
            end
        end,
        abn_artist_credits = {
            artist = "spikeberd",
        },
    }

end