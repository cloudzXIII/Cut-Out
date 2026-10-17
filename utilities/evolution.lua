ABN = ABN or {}
ABN.evolutions = {}

function ABN.add_evolution(key, evo, amount, opts)
    opts = opts or {}
    ABN.evolutions[key] = {
        key = key,
        evo = evo,
        amount = amount,
        progress = opts.progress,
        carry = opts.carry,
        per_blind = opts.per_blind,
        on_evolve = opts.on_evolve,
        loc = opts.loc,
    }
end

function ABN.get_evolution(card)
    if not (card and card.config and card.config.center and card.ability) then return nil end
    if card.ability.set ~= 'Joker' then return nil end
    return ABN.evolutions[card.config.center.key]
end

function Card:abn_init_evo()
    if not self.ability.abn_evo and ABN.get_evolution(self) then
        self.ability.abn_evo = { progress = 0, ready = false }
    end
end

function Card:abn_add_progress(n)
    local evo = ABN.get_evolution(self)
    if not evo then return end
    self:abn_init_evo()
    local state = self.ability.abn_evo
    state.progress = state.progress + (n or 1)
    if state.progress >= evo.amount and not state.ready then
        state.ready = true
        card_eval_status_text(self, 'extra', nil, nil, nil,
            { message = localize('k_abn_evo_ready'), colour = G.C.GOLD })
    end
end

function Card:abn_can_evolve()
    local evo = ABN.get_evolution(self)
    if not evo or self.debuff or self.area ~= G.jokers then return false end
    if not G.P_CENTERS[evo.evo] then return false end
    local state = self.ability.abn_evo
    return (state and state.ready) and true or false
end

-- Feed every joker's contexts to its evolution's progress function
local calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    local ret, post = calculate_joker_ref(self, context)
    if not (context.blueprint or context.retrigger_joker_check or context.retrigger_joker or self.debuff) then
        local evo = ABN.get_evolution(self)
        if evo then
            self:abn_init_evo()
            local state = self.ability.abn_evo
            if evo.per_blind and context.setting_blind and not state.ready then
                state.progress = 0
            end
            if evo.progress then
                local n = evo.progress(self, context)
                if type(n) == 'number' and n > 0 then self:abn_add_progress(n) end
            end
        end
    end
    return ret, post
end

local add_to_deck_ref = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    add_to_deck_ref(self, from_debuff)
    self:abn_init_evo()
end

function Card:abn_evolve()
    local evo = ABN.get_evolution(self)
    if not (evo and self:abn_can_evolve()) then return end

    local area = self.area
    stop_use()
    G.CONTROLLER.locks.abn_evolve = true
    if self.children.use_button then self.children.use_button:remove(); self.children.use_button = nil end
    if self.children.sell_button then self.children.sell_button:remove(); self.children.sell_button = nil end

    G.GAME.abn_evolution_total = (G.GAME.abn_evolution_total or 0) + 1
    SMODS.calculate_context({
        abn_evolution = true,
        abn_evolved_card = self,
        abn_evolved_from = evo.key,
        abn_evolved_to = evo.evo,
    })

    -- Snapshot what must survive set_ability
    local kept = {}
    for _, k in ipairs({ 'eternal', 'perishable', 'perish_tally', 'rental', 'pinned' }) do
        kept[k] = self.ability[k]
    end
    for k in pairs(SMODS.Stickers or {}) do kept[k] = self.ability[k] end

    local carried = {}
    for _, k in ipairs(evo.carry or {}) do
        carried[k] = {
            top = self.ability[k],
            extra = type(self.ability.extra) == 'table' and self.ability.extra[k] or nil,
        }
    end

    -- Old values handed to on_evolve
    local old = {
        x_mult = self.ability.x_mult,
        mult = self.ability.mult,
        t_mult = self.ability.t_mult,
        t_chips = self.ability.t_chips,
        extra = type(self.ability.extra) == 'table' and copy_table(self.ability.extra) or self.ability.extra,
    }

    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.2, func = function()
        play_sound('whoosh1')
        self:juice_up(0.3, 0.4)
        return true
    end }))

    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.3, func = function()
        self:start_materialize({ G.C.GOLD }, true)
        play_sound('explosion_release1')
        self:juice_up(0.3, 0.5)

        local was_in_deck = self.added_to_deck
        if was_in_deck then self:remove_from_deck(true) end
        self:set_ability(G.P_CENTERS[evo.evo], true)

        for k, v in pairs(kept) do
            if v ~= nil then self.ability[k] = v end
        end
        for k, v in pairs(carried) do
            if v.top ~= nil then self.ability[k] = v.top end
            if v.extra ~= nil and type(self.ability.extra) == 'table' then self.ability.extra[k] = v.extra end
        end
        if evo.on_evolve then evo.on_evolve(self, old) end
        if was_in_deck and not self.added_to_deck then self:add_to_deck() end

        if area and area.remove_from_highlighted then area:remove_from_highlighted(self) end
        card_eval_status_text(self, 'extra', nil, nil, nil,
            { message = localize('k_abn_evolved'), colour = G.C.GOLD })
        return true
    end }))

    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.3, func = function()
        G.CONTROLLER.locks.abn_evolve = nil
        return true
    end }))
end

G.FUNCS.abn_evolve = function(e)
    e.config.ref_table:abn_evolve()
end

G.FUNCS.abn_can_evolve = function(e)
    if (G.play and #G.play.cards > 0)
        or G.CONTROLLER.locked
        or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)
        or not e.config.ref_table:abn_can_evolve() then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = G.C.GOLD
        e.config.button = 'abn_evolve'
    end
end

local use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local retval = use_and_sell_buttons_ref(card)
    if card.area and card.area == G.jokers and ABN.get_evolution(card) then
        local evolve = { n = G.UIT.C, config = { h = 0.6, align = "cr" }, nodes = {
            { n = G.UIT.C, config = { ref_table = card, align = "cr", maxw = 1.25, padding = 0.1, r = 0.08,
                minw = 1.25, hover = true, shadow = true, colour = G.C.GOLD, one_press = true,
                button = 'abn_evolve', func = 'abn_can_evolve' }, nodes = {
                { n = G.UIT.C, config = { align = "tm" }, nodes = {
                    { n = G.UIT.R, config = { align = "cm" }, nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                        { n = G.UIT.T, config = { text = localize('b_abn_evolve'), colour = G.C.UI.TEXT_LIGHT,
                            scale = 0.35, shadow = true } },
                    } },
                } },
            } },
        } }
        local col = retval and retval.nodes and retval.nodes[1] and retval.nodes[1].nodes
            and retval.nodes[1].nodes[2]
        if col then
            col.nodes = col.nodes or {}
            table.insert(col.nodes, evolve)
        end
    end
    return retval
end

local card_update_ref = Card.update
function Card:update(dt)
    card_update_ref(self, dt)
    if G.STAGE == G.STAGES.RUN and ABN.get_evolution(self) then
        self:abn_init_evo()
        local ready = self:abn_can_evolve()
        if ready and not self.abn_evo_jiggle then
            juice_card_until(self, function(c) return c:abn_can_evolve() end, true)
            self.abn_evo_jiggle = true
        elseif not ready then
            self.abn_evo_jiggle = false
        end
    end
end

local gen_ability_table_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(vars_only)
    ABN.tooltip_card = self
    return gen_ability_table_ref(self, vars_only)
end

function ABN.evo_tooltip(_c)
    local evo = ABN.evolutions[_c.key]
    if not evo then return end
    local progress = 0
    local card = ABN.tooltip_card
    if card and card.config and card.config.center == _c and card.ability and card.ability.abn_evo then
        progress = card.ability.abn_evo.progress
    end
    return { key = 'abn_evo_' .. _c.key, set = 'Other', vars = { math.min(progress, evo.amount), evo.amount } }
end


local function abn_parse_lines(lines)
    local parsed = {}
    for _, line in ipairs(type(lines) == 'table' and lines or { lines }) do
        parsed[#parsed + 1] = loc_parse_string(line)
    end
    return parsed
end

local init_localization_ref = init_localization
function init_localization()
    init_localization_ref()
    local loc = G.localization
    loc.misc.dictionary.b_abn_evolve = "EVOLVE"
    loc.misc.dictionary.k_abn_evolved = "Evolved!"
    loc.misc.dictionary.k_abn_evo_ready = "Ready!"
    for key, evo in pairs(ABN.evolutions) do
        if evo.loc then
            loc.descriptions.Other['abn_evo_' .. key] = {
                name = evo.loc.name,
                text = evo.loc.text,
                name_parsed = abn_parse_lines(evo.loc.name),
                text_parsed = abn_parse_lines(evo.loc.text),
            }
        end
    end
end

---------------------------------------------------------------------------
-- Evolutions
---------------------------------------------------------------------------

-- Glass Joker -> Reflective Joker: break 2 Glass Cards in the same blind
ABN.add_evolution('j_glass', 'j_cutout_reflective_joker', 2, {
    per_blind = true,
    loc = {
        name = "Evolution",
        text = {
            "Break {C:attention}#2#{} Glass Cards",
            "in the same blind",
            "{C:inactive}(Currently {C:attention}#1#{C:inactive}/#2#)",
        },
    },
    progress = function(card, context)
        if context.remove_playing_cards then
            local n = 0
            for _, c in ipairs(context.removed or {}) do
                if c.shattered then n = n + 1 end
            end
            return n
        end
    end,
    on_evolve = function(card, old)
        card.ability.extra.xmult = old.x_mult or 1
    end,
})