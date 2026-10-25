ABN = ABN or {}

-- Hands each vanilla Joker mentions (vanilla Jokers don't have a center.calculate to watch).
-- Modded Jokers are detected automatically at runtime, but can also be listed here with ABN.mention_hands.
ABN.joker_mentioned_hands = ABN.joker_mentioned_hands or {}

function ABN.mention_hands(joker_key, hands)
    ABN.joker_mentioned_hands[joker_key] = hands
end

ABN.mention_hands('j_jolly', { 'Pair' })
ABN.mention_hands('j_sly', { 'Pair' })
ABN.mention_hands('j_duo', { 'Pair' })
ABN.mention_hands('j_zany', { 'Three of a Kind' })
ABN.mention_hands('j_wily', { 'Three of a Kind' })
ABN.mention_hands('j_trio', { 'Three of a Kind' })
ABN.mention_hands('j_family', { 'Four of a Kind' })
ABN.mention_hands('j_mad', { 'Two Pair' })
ABN.mention_hands('j_clever', { 'Two Pair' })
ABN.mention_hands('j_trousers', { 'Two Pair' })
ABN.mention_hands('j_crazy', { 'Straight' })
ABN.mention_hands('j_devious', { 'Straight' })
ABN.mention_hands('j_order', { 'Straight' })
ABN.mention_hands('j_runner', { 'Straight' })
ABN.mention_hands('j_shortcut', { 'Straight' })
ABN.mention_hands('j_superposition', { 'Straight' })
ABN.mention_hands('j_droll', { 'Flush' })
ABN.mention_hands('j_crafty', { 'Flush' })
ABN.mention_hands('j_tribe', { 'Flush' })
ABN.mention_hands('j_four_fingers', { 'Flush', 'Straight' })
ABN.mention_hands('j_seance', { 'Straight Flush' })

-- Jokers whose hand changes: give a function that takes the Joker card and returns a hand name (or a list of them)
ABN.mention_hands('j_todo_list', function(joker) return joker.ability.to_do_poker_hand end)

-- Runtime detection: wrap every modded Joker's calculate. If the Joker reads
-- context.scoring_name and then returns an effect, that hand counts as
-- "mentioned" by that Joker.
local function abn_mark_mentioned(joker_key, hand_name)
    if not G.GAME then return end
    G.GAME.abn_mention_seen = G.GAME.abn_mention_seen or {}
    G.GAME.abn_mention_seen[joker_key] = G.GAME.abn_mention_seen[joker_key] or {}
    G.GAME.abn_mention_seen[joker_key][hand_name] = true
end

local function abn_wrap_joker_calculate(center)
    local orig = center.calculate
    center.abn_wrapped = true
    center.calculate = function(self, card, context)
        if type(context) ~= 'table' or context.blueprint or type(context.scoring_name) ~= 'string' then
            return orig(self, card, context)
        end
        local read = false
        local proxy = setmetatable({}, {
            __index = function(_, k)
                if k == 'scoring_name' then read = true end
                return context[k]
            end,
            __newindex = function(_, k, v) context[k] = v end,
        })
        local ret, post = orig(self, card, proxy)
        if read and ret ~= nil and (type(ret) ~= 'table' or next(ret) ~= nil) then
            abn_mark_mentioned(self.key, context.scoring_name)
        end
        return ret, post
    end
end

function ABN.wrap_all_joker_calculates()
    for _, center in pairs(G.P_CENTERS) do
        if center.set == 'Joker' and type(center.calculate) == 'function'
            and not center.abn_wrapped and center.original_key ~= 'improvise_outfit' then
            abn_wrap_joker_calculate(center)
        end
    end
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    ABN.wrap_all_joker_calculates()
    return start_run_ref(self, args)
end

-- True if any owned Joker mentions the given poker hand
function ABN.hand_mentioned_by_joker(hand_name)
    if not (G.jokers and G.jokers.cards) then return false end
    local seen = G.GAME and G.GAME.abn_mention_seen
    for _, joker in ipairs(G.jokers.cards) do
        local center = joker.config and joker.config.center
        if center and not joker.debuff then
            local hands = ABN.joker_mentioned_hands[center.key]
            if type(hands) == 'function' then
                hands = hands(joker)
                if type(hands) == 'string' then hands = { hands } end
            end
            if hands then
                for _, h in ipairs(hands) do
                    if h == hand_name then return true end
                end
            end
            if seen and seen[center.key] and seen[center.key][hand_name] then
                return true
            end
        end
    end
    return false
end

SMODS.Joker {
    key = 'improvise_outfit',
    loc_txt = {
        name = "Improvise Outfit",
        text = {
			{
				"Whenever you score a hand mentioned by a {C:attention}Joker{}",
				"gain its {C:attention}base{} {C:mult}Mult{} as {C:attention}Asc. Power{}",
			},
			{
				"This Joker gains {C:mult}+#1#{} Mult if",
				"played hand contains a {C:attention}Two Pair{}",
				"{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)",
			},
        },
    },
    rarity = 2,
    cost = 6,
    atlas = 'CUTOUTJokerSheet1',
    pos = { x = 1, y = 2 },
    blueprint_compat = true,
    perishable_compat = false,
	discovered = true,
    config = {
        extra = {
            mult = 0,
            mult_add = 2,
        }
    },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_add, card.ability.extra.mult } }
    end,
	
	in_pool = function(self, args)
		return false
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            if next(context.poker_hands['Two Pair']) then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_add
                return {
                    message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                    colour = G.C.MULT,
                }
            end
        end

        if context.joker_main then
            local ret = { mult = card.ability.extra.mult }
            local hand = G.GAME.hands[context.scoring_name]
            if hand and (context.scoring_name == 'Two Pair' or ABN.hand_mentioned_by_joker(context.scoring_name)) then
                ret.asc = hand.mult
            end
            return ret
        end
    end,

    abn_artist_credits = {
        artist = "Mini Bit",
    },
}